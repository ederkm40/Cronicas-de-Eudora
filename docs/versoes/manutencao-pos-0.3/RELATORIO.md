# Relatório da manutenção pós-0.3-alpha

| | |
|---|---|
| **Data** | 26/11/2026 |
| **Versão do jogo** | continua 0.3-alpha (sem mudança de equilíbrio, conteúdo ou progressão) |
| **Branch** | `feat/manutencao-e-documento-mestre-03` (a partir do `main` `3d9102c`, que tem a 0.3-alpha do PR #5 e a Wiki do PR #6) |
| **Pull Request** | https://github.com/ederkm40/Cronicas-de-Eudora/pull/7 (inclui também o Documento Mestre de Sistemas) |
| **Prévia** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-7/ (build de produção) |

Os resultados históricos da 0.3-alpha (`docs/versoes/0.3-alpha/RELATORIO.md`) **não foram alterados nem repetidos** aqui. Os números abaixo são desta etapa.

## 1. Ponte de testes na build oficial

- **Problema:** `main.gd` criava a ponte `WebBridge` em toda exportação Web. A ponte ligava com `?teste=1` no endereço e aceitava os comandos `xp`, `hordas`, `invulneravel`, `limpar`, `chefe`, `chefe_vida` e `morrer`. Ou seja, o jogo publicado e as prévias tinham uma ferramenta de QA ativável por qualquer pessoa.
- **Causa:** uma única build servia para publicar e para testar.
- **Solução:** duas builds a partir do mesmo código:
  - **Produção:** preset `Web`, com `exclude_filter` que tira `scripts/web_bridge.gd` do `.pck`. É a única publicada (site oficial e prévias).
  - **QA:** preset novo `Web QA`, com a funcionalidade de exportação `qa`. Só existe no job "Testar e exportar", em `$RUNNER_TEMP/qa`, e nunca é enviada ao job "Publicar".
  - `main.gd` carrega a ponte por caminho (`load`) só quando há as funcionalidades `web` e `qa`. A ponte perdeu o `class_name` e não depende mais do endereço.
  - No CI, `tools/ci/verificar_producao.sh` falha se o `.pck` de produção contiver `scripts/web_bridge`. Ele também confere que o de QA contém, para a verificação não passar por engano.
  - O Playwright roda na QA (todos os testes de jogabilidade) e na produção (`producao.spec.js`).
- **Testes desta etapa (local, Chrome + Xvfb):**
  - `.pck` com o marcador `scripts/web_bridge`: produção 0, QA 3.
  - Playwright na QA: **21 aprovados**, 3 pulados de propósito.
  - Playwright na produção: **11 aprovados**, 1 pulado de propósito. Os testes abrem a página com e sem `?teste=1` e conferem:
    - `window.__eudora` e `window.__eudoraComandos` não existem;
    - uma lista de comandos escrita na página continua intacta 1,5 s depois;
    - o jogo continua rodando.

## 2. Integridade do save

- **Problema:** `MetaProgress._read()` supunha que `estatisticas` e `melhorias` eram objetos. Com um JSON válido mas de estrutura errada, a leitura parava no meio com erro de script e parte dos dados voltava ao padrão, sem aviso.
- **Solução:** validação antes de ler.
  - **Estrutura inválida** (JSON inválido; raiz que não é objeto; `versao` que não é número ou é negativa; `estatisticas` ou `melhorias` que não são objetos): cópia `.corrompido` e progressão nova.
  - **Campo inválido** (tipo errado, negativo, fracionado, nível acima do limite): cópia `.corrompido`. Só aquele campo vira um valor seguro (0, o inteiro abaixo ou o limite); o resto é mantido.
  - Os motivos ficam em `load_issues` e aparecem no console.
  - Versão futura: leitura tolerante, sem salvar por cima.
  - O original só é trocado no próximo salvamento, já com a cópia feita.
  - Campos desconhecidos são mantidos ao salvar.
- **Decisão desta etapa:** um nível acima do limite ou um número negativo **não** apaga o progresso inteiro, só corrige o campo. Assim um erro pequeno não custa todos os Ecos do jogador.
- **Testes (5, em `tests/suites/save_e_joystick.gd`):**
  - 11 estruturas inválidas: cada uma recomeça do zero, com cópia idêntica ao original e o original intacto.
  - 8 campos inválidos ajustados num mesmo arquivo.
  - Campos ausentes e campos desconhecidos mantidos ao salvar.
  - Versão futura com estrutura inválida, sem erro e sem sobrescrever.
  - A partida começa normalmente com um save inválido.
- **Conferência ao contrário:** sem a checagem de estrutura, 2 testes falham.

## 3. Retomada do joystick depois do level-up

- **Problema:** ao abrir o level-up, o joystick "esquecia" o dedo. Se o dedo continuasse na tela, não chegava um novo início de toque e o controle só voltava depois de levantar e tocar de novo.
- **Solução:**
  - O joystick acompanha, também na pausa (`PROCESS_MODE_ALWAYS`), o dedo que já estava nele: onde está e se foi solto. Nesse tempo não gera saída nem gestos.
  - Ao religar, o controle volta a partir da posição atual desse dedo; se ele foi solto, o joystick fica neutro.
  - Toques que começam durante a pausa (como tocar no cartão) não viram joystick.
  - A pausa zera os gestos: um toque curto antes e outro depois não formam um duplo toque, e soltar o dedo mantido não conta como toque curto.
  - Nenhum toque é simulado.
- **Testes (5, na mesma suíte):**
  - retomada com o dedo pressionado (anda na mesma direção, sem esquiva; soltar para);
  - dedo solto durante a pausa (volta neutro; um toque novo funciona);
  - dedo movido durante a pausa (retoma na posição nova);
  - dois level-ups seguidos e mais uma pausa depois;
  - nenhuma esquiva acidental ao redor da pausa.
- **Navegador:** teste novo no Playwright nos 3 perfis, com o dedo mantido e a escolha pelo teclado. Ele confere que o personagem anda 1,5 m em 1 s sem toque novo e que soltar o dedo para o personagem. Aprovado nos 3 perfis.
- **Conferência ao contrário:** com o comportamento antigo (soltar o dedo ao pausar), 3 testes falham.
- **Limite:** depende de o navegador continuar entregando os eventos do dedo durante a pausa. O Chromium entrega; **não foi testado em celular físico**.

## 4. Limpeza

- Removido `scripts/main.gd.orig`: uma sobra do `patch` aplicado na 0.3, que tinha entrado no repositório por engano.
- Procurei `*.orig`, `*.rej`, `*~`, `*.bak`, `*.swp`, `*.tmp`, `*.log`, `*.corrompido` e nomes com "copy/copia/backup/old" entre os arquivos versionados: **nenhum outro encontrado**. Os `.uid` e `.import` foram mantidos.

## Arquivos alterados

| Frente | Arquivos |
|---|---|
| Builds | `export_presets.cfg`, `scripts/main.gd`, `scripts/web_bridge.gd`, `tools/ci/construir_qa.sh` (novo), `tools/ci/verificar_producao.sh` (novo), `.github/workflows/publicar.yml` (só o job "Testar e exportar"), `tools/e2e/playwright.config.js`, `tools/e2e/testes/producao.spec.js` (novo), `tools/e2e/testes/ajudantes.js`, `tools/e2e/testes/jogabilidade.spec.js` |
| Save | `scripts/meta_progress.gd` |
| Joystick | `scripts/floating_joystick.gd` |
| Testes | `tests/suites/save_e_joystick.gd` (novo), `tests/run_tests.gd` (registra a suíte nova; uma suíte que não carrega agora conta como falha em vez de travar o executor) |
| Limpeza | `scripts/main.gd.orig` (removido) |

Sem mudança: equilíbrio, armas, inimigos, chefe, hordas, recompensas, progressão e economia. Os nomes dos checks obrigatórios também não mudaram.

## Testes realizados nesta etapa

| Teste | Resultado | Onde |
|---|---|---|
| `run_tests.gd` (51 testes em 5 suítes) | 51 testes, 4.482 verificações, 0 falhas | local |
| Conferências ao contrário (save e joystick) | 5 testes falham com as correções desfeitas | local |
| Playwright na QA (3 perfis) | 21 aprovados, 3 pulados de propósito | local (Chrome + Xvfb) |
| Playwright na produção (3 perfis) | 11 aprovados, 1 pulado de propósito | local (Chrome + Xvfb) |
| `verificar_producao.sh` | produção 0, QA 3 | local |
| `smoke_test.gd` | SMOKE TEST: OK | local |
| `long_simulation.gd --segundos=300` | OK; CPU por quadro: média 1,37 ms, p99 4,73 ms (sem mudança relevante em relação à 0.3) | local |
| CI do PR #7, commit `845489d` | todos os passos aprovados (gdlint, gdformat, testes do Godot, Wiki, site, exportação das duas builds, verificação da produção, Playwright na QA e na produção, publicação da prévia) | GitHub Actions, execução 45878337769 |

## Problema encontrado durante a etapa

Um commit intermediário desta branch (`421b19a`) tinha um erro de sintaxe na suíte nova (`save_e_joystick.gd`, tipo não inferível). Com isso o executor travava, sem terminar, em vez de falhar. No CI, o passo do `gdformat` já tinha reprovado antes, por outro motivo (aspas num texto), e por isso o travamento não chegou a aparecer lá. O commit `845489d` faz três coisas: corrige a suíte, aplica a formatação e torna o executor robusto (a suíte que não carrega vira uma falha registrada). Os números da tabela acima foram medidos depois dessa correção.

## Limitações que continuam

- Sem teste em celular físico e sem teste com pessoas.
- Destro/canhoto e ajuste do joystick: direção aprovada, não implementada (fora do escopo).
- Equilíbrio do chefe ainda não validado com pessoas.
- O texto da Atração do eco no jogo diz "raio de coleta"; o efeito é no ímã. Não foi alterado: mudar o texto não fazia parte desta etapa.
- A câmera em paisagem mostra pouco mapa na vertical. Também faltam arte final e som.
