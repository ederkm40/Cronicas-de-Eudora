# Relatório da infraestrutura: ferramentas de QA e testes de navegador

| | |
|---|---|
| **Data** | 26/11/2026 |
| **Versão do jogo** | continua 0.2-alpha (sem mudança de gameplay) |
| **Branch** | `infra/ferramentas-qa-web` (a partir do `main` `1b6c65c`) |
| **Commits** | `7abd5fb`, `005ba4e`, `72ba09f` (diagnóstico temporário no runner, removido depois), `5ed07c4` (estilo do GDScript), `7ad9076` (ferramentas e workflow), `951c63f` (formulários e Xvfb), mais o commit de documentação |
| **Pull Request** | https://github.com/ederkm40/Cronicas-de-Eudora/pull/4 |
| **Prévia do jogo** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-4/ |
| **Prévia da Wiki** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-4/wiki/ |

## Objetivo

Aumentar a qualidade dos testes sem custo e sem mudar o jogo: verificar o GDScript (sintaxe e estilo) e testar a versão Web exportada num navegador real, em computador e em celular emulado. Também facilitar relatos pelo navegador, com formulários do GitHub.

## Funcionalidades implementadas

- **GDScript Toolkit 4.5.0** (`requirements-ci.txt`, com todas as dependências fixadas) num ambiente virtual temporário do runner:
  - `gdlint scripts tests`, com as regras padrão, sem `gdlintrc` e sem exceções;
  - `gdformat --check` só nos `.gd` adicionados ou alterados desde o ponto comum com o commit-base (`tools/ci/verificar_gdscript.sh`).
- **Playwright Test 1.65.1** em `tools/e2e/` (`package.json` e `package-lock.json` exatos, `npm ci`), só Chromium. Os testes abrem o jogo exportado servido em `127.0.0.1:8060`, em 3 perfis (computador 1366 × 768; Pixel 7 em pé 412 × 915; Pixel 7 deitado 915 × 412), e verificam:
  - motor iniciado (`#status` removido);
  - "Godot Engine v4.7.2" no console;
  - WebGL 2;
  - arquivos essenciais com 200 e nenhuma falha de rede;
  - canvas visível, dentro da tela e ocupando a janela;
  - imagem em movimento;
  - nenhum erro de JavaScript;
  - toque e orientação nos perfis de celular.
- **Renderizador:** o Chromium roda no `xvfb-run` com `--use-angle=gl`, o que dá Mesa/llvmpipe.
- **Evidências:** screenshot e trace só em falha, guardados por 7 dias.
- **Node.js 22** com `actions/setup-node` (e cache do npm). O teste de busca da Wiki em JavaScript passou a ser obrigatório no CI (`EXIGIR_NODE=1` faz falhar se faltar o Node).
- **Formulários:** 5 formulários de Issue (`bug_report`, `feature_request`, `gameplay_feedback`, `mobile_performance`, `wiki_documentation`), usando só rótulos que já existem (`bug`, `enhancement`, `documentation`), e o `PULL_REQUEST_TEMPLATE.md`.

## Funcionalidades alteradas

- **Job `testar` ("Testar e exportar"):** novas etapas, na ordem: checkout com histórico completo → Godot → Python + gdtoolkit → Node 22 + Playwright e Chromium → `gdlint` → `gdformat --check` → testes do jogo → testes Python → exportação → servidor HTTP temporário → Playwright → evidências (só em falha) → montagem para o `Publicar`. Os nomes dos jobs e dos checks obrigatórios foram mantidos.
- **Sem mudança** nos jobs `publicar` e `remover-previa`, no `gh-pages`, na publicação oficial, nas prévias nem na limpeza.

## Correções de estilo (sem mudança de lógica)

O `gdlint` encontrou 48 problemas no código existente:

| Regra | Quantidade |
|---|---|
| `max-line-length` | 34 |
| `class-definitions-order` | 13 |
| `max-returns` | 1 |

Correções feitas:

- Constantes movidas para antes das variáveis.
- Comentários longos passados para a linha de cima.
- Textos longos de `print` divididos em duas partes.
- `Upgrades.describe_next` reescrita com um único `return` e uma função auxiliar `_percent_change`. O texto gerado foi conferido nas 67 combinações (6 melhorias × níveis 0 a 10, mais um id inexistente) e é **idêntico** ao anterior.
- Os 9 arquivos tocados foram formatados pelo `gdformat` 4.5.0 do próprio runner.

Os outros 5 arquivos antigos que não seguem o `gdformat` **não foram reformatados**: hud, floating_joystick, xp_orbs, main e progression.

## Compatibilidade verificada antes de integrar

- **gdtoolkit 4.5.0:** o parser leu sem erro os 15 arquivos GDScript do projeto (Godot 4.7.2). Execução de diagnóstico 45830499131.
- **Playwright:** a versão estável no npm era a 1.65.1, e o `package-lock.json` foi gerado no runner.
- **Runner `ubuntu-latest`:** tem `xvfb` e `libgl1-mesa-dri`.

## Testes executados e resultados

| Teste | Onde | Resultado |
|---|---|---|
| `gdlint scripts tests` | CI (45837168352, 45838061660) | **Success: no problems found** |
| `gdformat --check` nos 9 arquivos alterados | CI | **9 files would be left unchanged** |
| `tests/run_tests.gd` | local e CI | **TESTES: OK** (16 testes, 1.627 verificações) |
| `tests/smoke_test.gd` | local e CI | **SMOKE TEST: OK** |
| `tests/long_simulation.gd -- --segundos=300` | local e CI | **SIMULAÇÃO LONGA: OK** |
| `tools/wiki/test_wiki.py -v` (14 testes; `test_busca_no_javascript` executado com Node v22.23.5) | local e CI | **OK** |
| `tools/site/test_montar_site.py -v` (7 testes) | local e CI | **OK** |
| Exportação Web e verificação de `index.html`, `.js`, `.pck`, `.wasm` | CI | **OK** |
| Playwright, execução 45838061660 (com Xvfb) | CI | **5 aprovados, 1 pulado de propósito** (toque no perfil de computador), em 33 s |
| Prévia do PR #4 | CI (Publicar) | **verificada no ar** |

### Playwright por perfil (execução 45838061660)

| Perfil | Teste "carrega, inicia e desenha" | Teste de toque e orientação | Renderizador WebGL 2 |
|---|---|---|---|
| Computador 1366 × 768 | ✓ 10,5 s | pulado (não se aplica) | ANGLE (Mesa, llvmpipe, LLVM 21.1.8, OpenGL 4.5) |
| Pixel 7 em pé 412 × 915 | ✓ 6,8 s | ✓ 3,2 s | idem |
| Pixel 7 deitado 915 × 412 | ✓ 6,9 s | ✓ 2,6 s | idem |

A execução anterior, 45837168352, sem Xvfb, também passou (5 aprovados), mas o Chromium usou **SwiftShader**, apesar do `--use-angle=gl`. Por isso o Playwright passou a rodar dentro do `xvfb-run`.

### Os testes falham de verdade

Localmente, com o Playwright 1.63.0 já instalado na sessão, servi uma exportação sem o `index.pck`. O teste falhou com a mensagem `o Godot não iniciou: Failed loading file 'index.pck'`. Também confirmei, com o `EXIGIR_NODE=1` e sem o Node no PATH, que o teste da Wiki falha em vez de ser pulado.

### Evidências

Nenhuma falha nas execuções finais, então nenhum screenshot, trace ou relatório foi guardado: o artefato `playwright-falha` só é criado em caso de falha.

## Problemas encontrados durante a etapa

- **Sessão do Claude Code:** o PyPI e o npm estavam bloqueados, e a compilação local do módulo `regex` foi recusada pelo sistema de segurança. As ferramentas foram validadas no runner do GitHub, com uma execução de diagnóstico temporária.
- **Histórico:** o `git push --force` foi recusado, então os commits de diagnóstico ficaram no histórico da branch. O último commit remove o workflow temporário. Um merge por squash junta tudo.
- **Erros dos meus testes, corrigidos antes da entrega:**
  - esperar por `#status-notice` depois que o `#status` já tinha sido removido;
  - o nome `index.html` para a página pedida como `/`.

## Limitações

- **Celular:** a emulação de Pixel 7 **não equivale** a um celular físico (GPU, desempenho, navegador do aparelho).
- **Navegadores:** só o Chromium; Firefox e WebKit ficaram para uma próxima etapa.
- **Formatação:** os 5 arquivos GDScript antigos citados acima serão formatados quando forem alterados.
- **Tempo:** o job "Testar e exportar" ficou cerca de 1 minuto mais longo, por causa do Chromium e de 5 testes de navegador.

## Custo

Nenhum. GitHub Actions com `ubuntu-latest` (gratuito para repositório público), ferramentas de código aberto com versões fixadas e instaladas só no runner, sem tokens, sem serviços pagos e sem dependências no jogo publicado.
