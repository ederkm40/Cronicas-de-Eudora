# AGENTS.md — diretrizes para qualquer IA neste repositório

Vale para qualquer ferramenta de IA (Claude Code, ChatGPT, outras). Instruções específicas de uma ferramenta ficam em arquivos próprios, como o `CLAUDE.md`, e não repetem o que está aqui.

## O projeto

**Crônicas de Eudora** é um jogo de hordas isométrico para celular (tela em pé), no estilo *survivors*, com progressão de RPG de ação. Godot 4.7.2, GDScript, renderizador Compatibility, exportação Web sem threads, publicado no GitHub Pages.

- Jogo oficial: https://ederkm40.github.io/Cronicas-de-Eudora/
- Wiki oficial: https://ederkm40.github.io/Cronicas-de-Eudora/wiki/
- Prévias de Pull Request: `https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-<número>/`

**O GitHub é a fonte de verdade.** Nenhuma IA deve depender da própria memória. Antes de agir, leia:

1. `docs/IA/ESTADO_ATUAL.md`: onde o projeto está agora.
2. `docs/IA/CONTINUIDADE.md`: como assumir o trabalho.
3. `docs/IA/MAPA_DO_PROJETO.md`: onde fica cada coisa.
4. `docs/TECNICO.md`: como o jogo funciona.
5. `docs/ROADMAP.md`: o que vem a seguir.

O proprietário não programa. Escreva em **português do Brasil**, em linguagem simples.

## Divisão de responsabilidades

| Quem | Faz | Arquivos que mantém |
|---|---|---|
| **Claude Code** | Desenvolve o jogo: sistemas, armas, melhorias, inimigos, interface, efeitos, áudio, correções, desempenho, testes, builds, infraestrutura | `scripts/`, `scenes/`, `tests/`, `tools/`, `.github/`, `project.godot`, `export_presets.cfg`, `docs/TECNICO.md`, `docs/IA/*`, `docs/versoes/*/RELATORIO.md`, novas decisões em `docs/decisoes/`, `wiki-src/assets/` e `wiki-src/site.json` (só a parte técnica) |
| **ChatGPT** | Acompanha as entregas, analisa Pull Requests, escreve e atualiza a Wiki, o changelog editorial e o histórico; revisa relatórios; confere se a Wiki corresponde ao jogo | `wiki-src/**/*.md`, `docs/CHANGELOG.md`, seção "Revisão editorial" dos relatórios, organização de `docs/decisoes/README.md` |
| **Proprietário** | Decide prioridades, testa as prévias, aprova e faz o merge dos Pull Requests | — |

Regras para não haver conflito:

- Cada IA edita **os próprios arquivos**. Se precisar mudar um arquivo da outra, explique o motivo no Pull Request.
- O Claude Code **não reescreve conteúdo editorial** do ChatGPT (artigos da Wiki, changelog). Se um fato técnico mudou, ele registra a mudança em `docs/IA/ENTREGA_PARA_CHATGPT.md`, e o ChatGPT atualiza os textos.
- O ChatGPT **não altera código, testes ou workflows**. Se encontrar um erro técnico, descreve no Pull Request.
- O ChatGPT **não trabalha em segundo plano**: o proprietário leva o link do Pull Request até ele.
- Nenhuma IA espera pela outra para continuar o próprio trabalho.

## Fluxo de cada etapa

1. O Claude Code cria uma branch (`etapa-<versão>-<nome>`, ou `infra/<nome>` para infraestrutura) a partir do `main`.
2. Implementa, testa e atualiza a documentação técnica, o relatório da versão e `docs/IA/ENTREGA_PARA_CHATGPT.md`.
3. Abre o Pull Request para o `main`, **sem fazer merge**.
4. O GitHub Actions testa, exporta e publica a **prévia jogável** em `/previews/pr-<N>/`, e comenta o endereço no PR.
5. O proprietário leva o PR ao ChatGPT, que atualiza a Wiki e o changelog **na mesma branch**. Cada commit atualiza a prévia sozinho.
6. O proprietário testa a prévia e aprova. O merge publica a versão oficial e apaga a prévia.

## Regras técnicas (não negociáveis)

- Godot **4.7.2** (fixado em `GODOT_VERSION` no workflow), GDScript, Compatibility, Web **sem threads**. Sem C#.
- Prioridade mobile. Objetos repetidos (inimigos, projéteis, orbes, efeitos no chão) em **arrays + MultiMesh**, nunca um nó por objeto. Sem sombras em tempo real; use `BlobShadow`.
- Armas: definição em `WeaponCatalog`, estado em `Arsenal`, execução num nó por arma; dano sempre por `EnemyManager.damage(índice, dano, arma)` para as estatísticas ficarem certas. Inimigos e chefe vivem no `EnemyManager` (decisão 0010).
- Controle com um dedo: joystick flutuante, ataque automático, esquiva por duplo toque no joystick. Sem botões de ataque ou de esquiva.
- Sistemas de jogo **pausáveis** por padrão. O level-up e a vitória usam `SceneTree.paused`.
- O save (`user://progresso.json`, `MetaProgress`) tem versão. Mudou o formato: aumente `VERSION`, escreva a migração e o teste.
- Melhorias recalculadas a partir da base em `Upgrades.refresh()`.
- GDScript passa no `gdlint` (regras padrão do gdtoolkit 4.5.0, sem exceções). Todo arquivo `.gd` criado ou alterado segue o `gdformat`. O código antigo não é reformatado em massa.
- Tudo em texto. Commite os `.uid` e `.import` gerados pelo Godot. Não commite `.godot/`, `build/`, arquivos temporários, saves ou credenciais.
- Pastas sem conteúdo do jogo (`docs/`, `tools/`, `wiki-src/`) têm `.gdignore`, para não entrarem no `.pck`.

## Regras de honestidade

- **Não declare um teste aprovado sem rodá-lo.** Registre comando e resultado.
- **Não diga que algo foi testado em celular físico** se não foi.
- **Não apresente conteúdo planejado como existente.** Na Wiki, use o estado `{PLANEJADO}`.
- Não invente personagens, armas, inimigos, itens ou números. Os números vêm do código.
- Não afirme que uma prévia está no ar sem verificar. O workflow verifica e informa no comentário do PR.

## Custo zero

O proprietário **não autoriza despesas**. Use só: GitHub Free, GitHub Pages, GitHub Actions com runners `ubuntu-latest` padrão, Godot, Python, Node.js, ferramentas gratuitas de código aberto e recursos do navegador.

Não use: Codespaces, runners pagos ou maiores, serviços de navegadores na nuvem (BrowserStack, LambdaTest etc.), hospedagem ou domínios pagos, bancos de dados externos, APIs pagas, serviços externos de Wiki, plugins com assinatura, tokens pessoais (PAT) ou credenciais extras, ou qualquer coisa que possa gerar cobrança.

### Dependências: desenvolvimento × jogo publicado

| Tipo | Regra | Exemplos |
|---|---|---|
| **De desenvolvimento** (testes, lint, build) | Permitidas **só no CI**, gratuitas, de código aberto, com **versão exata fixada** (`requirements-ci.txt`, `tools/e2e/package-lock.json`). Instaladas em ambiente temporário do runner, nunca no computador do proprietário | gdtoolkit 4.5.0, Playwright 1.65.1 + Chromium |
| **Do jogo publicado** (o que roda no navegador de quem joga) | **Nenhuma dependência externa.** Nada de CDN, biblioteca de terceiros ou serviço externo | — |

Pastas de ferramentas (`tools/`, `docs/`, `wiki-src/`) têm `.gdignore` e nunca entram no `.pck`.

## Comandos de verificação

Todos rodam no GitHub Actions, no job "Testar e exportar". Localmente, só se as ferramentas estiverem disponíveis.

```bash
gdlint scripts tests                                 # estilo e sintaxe do GDScript (gdtoolkit 4.5.0)
gdformat --check <arquivos .gd alterados>            # formatação dos arquivos alterados
godot --headless --path . --import
godot --headless --path . --fixed-fps 60 --script res://tests/run_tests.gd        # "TESTES: OK" (suítes em tests/suites/)
godot --headless --path . --fixed-fps 60 --script res://tests/smoke_test.gd       # "SMOKE TEST: OK"
godot --headless --path . --fixed-fps 60 --script res://tests/long_simulation.gd -- --segundos=300   # "SIMULAÇÃO LONGA: OK"
godot --headless --path . --fixed-fps 60 --script res://tests/balance_simulation.gd -- --modo=partida   # equilíbrio (fora do CI)
python3 tools/wiki/test_wiki.py                      # Wiki
python3 tools/site/test_montar_site.py               # montagem do site
python3 tools/wiki/build_wiki.py --saida build/wiki  # gerar a Wiki localmente
cd tools/e2e && npm ci && E2E_DIR=<exportação> xvfb-run -a npx playwright test   # navegador
```

No CI, os scripts do Godot rodam por `tools/ci/rodar_godot.sh`, que também falha se o log tiver erro de script. Os testes de navegador abrem o jogo com `?teste=1` (ponte `scripts/web_bridge.gd`).

Os checks obrigatórios da `main` são **`Testar e exportar`** e **`Publicar`**. Não renomeie esses jobs nem crie um terceiro job obrigatório sem combinar com o proprietário.
