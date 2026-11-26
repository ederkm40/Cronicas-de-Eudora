# Estado atual do projeto

*Atualizado pelo Claude Code a cada entrega. Última atualização: 26/11/2026, etapa "Ferramentas de QA" (PR #4, em revisão).*

| | |
|---|---|
| **Versão estável (oficial)** | 0.2-alpha "Ecos da Evolução" + infraestrutura de Wiki, prévias e memória |
| **Branch principal** | `main` |
| **Commit do `main`** | `1b6c65c14c8a647c12568f780c6dc25f053d1d0d`: PR #2 integrado (squash) em 26/11/2026 |
| **Publicado** | jogo e Wiki oficiais do commit `1b6c65c` no branch `gh-pages` (https://ederkm40.github.io/Cronicas-de-Eudora/ e `/wiki/`); nenhuma prévia aberta antes do PR #4 |
| **Proteção da `main`** | checks obrigatórios: `Testar e exportar` e `Publicar` |
| **Etapa em revisão** | Ferramentas de QA: GDScript Toolkit, Playwright e formulários (branch `infra/ferramentas-qa-web`, PR #4) |
| **Próxima etapa de gameplay** | 0.3-alpha, variedade de combate (2 armas novas) |
| **Fase** | 1, protótipo |

## Sistemas do jogo (no `main`)

| Sistema | Arquivo | Desde |
|---|---|---|
| Joystick flutuante, WASD e setas | `scripts/floating_joystick.gd`, `scripts/player.gd` | 0.1 |
| Câmera isométrica ortográfica fixa (retrato) | `scripts/camera_rig.gd` | 0.1 |
| Arma automática com multiplicadores | `scripts/auto_weapon.gd` | 0.1 / 0.2 |
| Hordas de até 300 (arrays + MultiMesh, separação por grade) | `scripts/enemy_manager.gd` | 0.1 |
| HUD, derrota e reinício | `scripts/hud.gd`, `scripts/main.gd` | 0.1 |
| Orbes de XP com ímã | `scripts/xp_orbs.gd` | 0.2 |
| Progressão (curva `round(4 × n^1,35)`) | `scripts/progression.gd` | 0.2 |
| 6 melhorias com limites | `scripts/upgrades.gd` | 0.2 |
| Level-up com pausa total e 3 cartões | `scripts/level_up_panel.gd`, `scripts/main.gd` | 0.2 |

## Infraestrutura

| Item | Situação |
|---|---|
| Publicação no `gh-pages`, prévia por PR, verificação no ar | **publicado** (PR #2) |
| Wiki gerada de `wiki-src/` (56 páginas) | **publicado** (PR #2) |
| Memória para IAs (`AGENTS.md`, `docs/IA/`, relatórios, decisões, changelog) | **publicado** (PR #2) |
| GitHub Pages lendo o branch `gh-pages` | configurado pelo proprietário |
| GDScript Toolkit 4.5.0 (`gdlint`, `gdformat --check` nos alterados) | **em revisão** (PR #4); aprovado no CI |
| Playwright 1.65.1, só Chromium, 3 perfis, com Mesa/llvmpipe | **em revisão** (PR #4); aprovado no CI |
| Node.js 22 explícito e teste de busca da Wiki obrigatório | **em revisão** (PR #4); aprovado no CI |
| Formulários de Issue (5) e modelo de PR | **em revisão** (PR #4) |

## Sistemas incompletos ou ausentes

- Só 1 arma, 1 tipo de inimigo, nenhum chefe, nenhum item, nenhuma classe, nenhum som, gráficos provisórios.
- Equilíbrio não ajustado.

## Bugs e limitações conhecidos

- Não testado em celular físico. Os testes de navegador emulam um Pixel 7, o que não equivale a um aparelho real.
- Depois da pausa do level-up, o joystick só responde depois de levantar o dedo e tocar de novo.
- Orbes distantes ficam no chão indefinidamente.
- Na tela deitada, a câmera mantém 14 m de largura e mostra pouco mapa na vertical.
- Ambiente de testes: com SwiftShader, as atualizações de MultiMesh não aparecem. O CI roda o Chromium no `xvfb-run` com `--use-angle=gl` (Mesa/llvmpipe). Sem tela virtual, cai no SwiftShader.
- 5 arquivos GDScript antigos ainda não seguem o `gdformat` (`hud.gd`, `floating_joystick.gd`, `xp_orbs.gd`, `main.gd`, `progression.gd`). Eles serão formatados quando forem alterados. Os outros 10 já seguem.

## Estado dos testes (última execução real)

| Teste | Resultado | Onde |
|---|---|---|
| `gdlint scripts tests` (gdtoolkit 4.5.0) | sem problemas | CI, PR #4 |
| `gdformat --check` (9 arquivos alterados no PR #4) | 9 sem mudanças | CI, PR #4 |
| `tests/run_tests.gd` (16 testes, 1.627 verificações) | aprovado | local e CI, PR #4 |
| `tests/smoke_test.gd` | aprovado | local e CI, PR #4 |
| `tests/long_simulation.gd -- --segundos=300` | aprovado | local e CI, PR #4 |
| `tools/wiki/test_wiki.py` (14 testes; busca JS no Node 22) | aprovado | local e CI, PR #4 |
| `tools/site/test_montar_site.py` (7 testes) | aprovado | local e CI, PR #4 |
| Playwright: computador, celular em pé e celular deitado (5 testes + 1 pulado de propósito) | aprovado, com Mesa/llvmpipe | CI, PR #4 |
| Prévia do PR #4 no endereço público | verificada | CI, PR #4 |
