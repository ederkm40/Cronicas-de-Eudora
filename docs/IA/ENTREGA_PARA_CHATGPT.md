# Entrega para o ChatGPT

*Pacote de fatos técnicos da última entrega do Claude Code. Use para atualizar a Wiki (`wiki-src/`), o `docs/CHANGELOG.md` e revisar o relatório. Não é um artigo: são dados.*

## Identificação

| | |
|---|---|
| **Etapa** | Infraestrutura: ferramentas auxiliares, QA de navegador e formulários |
| **Versão do jogo** | continua **0.2-alpha** (sem mudança de gameplay) |
| **Branch** | `infra/ferramentas-qa-web` (a partir do `main` `1b6c65c`) |
| **Commit** | último commit da branch (ver PR #4) |
| **Pull Request** | https://github.com/ederkm40/Cronicas-de-Eudora/pull/4 |
| **Prévia do jogo** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-4/ |
| **Prévia da Wiki** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-4/wiki/ |

## Contexto: o que já foi integrado antes

O PR #2 (infraestrutura de Wiki, prévias e memória) foi integrado em `1b6c65c`. A Wiki oficial já está no ar em `/wiki/`. Nas páginas do painel de desenvolvimento (`wiki-src/desenvolvimento/`), a linha "Infraestrutura: Wiki, prévias e memória" ainda aparece como `{EM_DESENVOLVIMENTO}`: ela pode passar para `{PUBLICADO}`.

## Resumo técnico desta etapa

- **GDScript Toolkit 4.5.0** no CI: `gdlint` em `scripts/` e `tests/` (regras padrão, sem exceções) e `gdformat --check` nos `.gd` alterados no PR. Versões fixadas em `requirements-ci.txt`.
- **Playwright Test 1.65.1** (`tools/e2e/`, só Chromium): abre o jogo exportado de verdade e confere motor iniciado, WebGL 2, arquivos essenciais, canvas, imagem em movimento e ausência de erros, em 3 perfis (computador 1366 × 768; Pixel 7 em pé 412 × 915; Pixel 7 deitado 915 × 412). Renderizador Mesa/llvmpipe via Xvfb.
- **Node.js 22** configurado explicitamente; o teste de busca da Wiki em JavaScript virou obrigatório no CI.
- **Formulários do GitHub:** 5 formulários de Issue (erro, sugestão, jogabilidade, desempenho no celular, Wiki) e modelo de Pull Request.
- **Estilo do GDScript:** 9 arquivos ajustados ao `gdlint` e formatados pelo `gdformat`, **sem mudança de lógica** (constantes reordenadas, linhas quebradas, `describe_next` com um único `return`, com texto idêntico conferido).

## Arquivos

| Novo | Alterado |
|---|---|
| `requirements-ci.txt`, `tools/ci/verificar_gdscript.sh`, `tools/e2e/` (`package.json`, `package-lock.json`, `playwright.config.js`, `testes/jogo.spec.js`, `README.md`, `.gitignore`), `.github/ISSUE_TEMPLATE/*.yml` (5), `.github/PULL_REQUEST_TEMPLATE.md`, `docs/decisoes/0009-ferramentas-qa-web.md`, `docs/versoes/infra-ferramentas-qa/RELATORIO.md` | `.github/workflows/publicar.yml` (job `testar`), `tools/wiki/test_wiki.py` (Node obrigatório com `EXIGIR_NODE=1`), `scripts/` (auto_weapon, camera_rig, enemy_manager, level_up_panel, player, upgrades: só estilo), `tests/` (run_tests, smoke_test, long_simulation: só estilo), `AGENTS.md`, `CLAUDE.md`, `README.md`, `docs/TECNICO.md`, `docs/IA/*`, `docs/decisoes/README.md` |

Não alterados: `scenes/`, `project.godot`, `export_presets.cfg`, `publicar` e `remover-previa` (jobs), `wiki-src/` e `docs/CHANGELOG.md`.

## Comportamentos novos no jogo

Nenhum. Valores do jogo inalterados.

## Testes realizados e resultados

Ver `docs/versoes/infra-ferramentas-qa/RELATORIO.md`. Resumo: gdlint sem problemas; gdformat 9/9; jogo, Wiki e site aprovados; Playwright com 5 aprovados e 1 pulado de propósito (toque no computador), usando Mesa/llvmpipe; prévia verificada no ar.

## Para a Wiki e o changelog

- **Changelog:** registrar a etapa "Ferramentas de QA" (categorias Testes e Infraestrutura), sem efeito no gameplay.
- **Painel de desenvolvimento** (`wiki-src/desenvolvimento/testes.md`): acrescentar as suítes novas: `gdlint`/`gdformat` (GDScript Toolkit 4.5.0) e os testes de navegador (Playwright 1.65.1; computador, celular em pé e deitado). Deixar claro que a emulação de Pixel 7 **não** é teste em celular físico.
- **Funcionalidades** (`funcionalidades.md`): a infraestrutura do PR #2 passa a `{PUBLICADO}`; as ferramentas de QA ficam `{TESTADO}` até o merge do PR #4.
- Uma possível página nova "Como relatar um problema", apontando para **Issues → New issue** e para os 5 formulários.
