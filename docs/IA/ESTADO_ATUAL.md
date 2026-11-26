# Estado atual do projeto

*Atualizado pelo Claude Code a cada entrega. Última atualização: 26/11/2026, etapa de infraestrutura.*

| | |
|---|---|
| **Versão estável (oficial)** | 0.2-alpha "Ecos da Evolução" |
| **Branch principal** | `main` |
| **Commit do `main`** | `e516f2187f4726b6d63ad674955c15397a0f548d` (merge do PR #1) |
| **Etapa em desenvolvimento** | Infraestrutura: Wiki, prévias e memória (branch `infra/wiki-previews-memoria`, PR #2) |
| **Próxima etapa de gameplay** | 0.3-alpha, variedade de combate (2 armas novas) |
| **Fase** | 1, protótipo |

## Sistemas implementados (no `main`)

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

## Infraestrutura (nesta etapa, ainda não integrada)

| Item | Situação |
|---|---|
| Workflow `publicar.yml` (testes, prévia por PR, publicação no `gh-pages`) | implementado; validado no PR |
| Wiki (`wiki-src/` + `tools/wiki/`) | implementada, 56 páginas, testada |
| Memória para IAs (`AGENTS.md`, `docs/IA/`, `docs/versoes/`, `docs/decisoes/`, `docs/CHANGELOG.md`) | escrita |
| GitHub Pages lendo o branch `gh-pages` | **depende de um ajuste do proprietário** (ver `CONTINUIDADE.md`) |

## Sistemas incompletos ou ausentes

- Só 1 arma, 1 tipo de inimigo, nenhum chefe, nenhum item, nenhuma classe, nenhum som, gráficos provisórios.
- Equilíbrio não ajustado.

## Bugs e limitações conhecidos

- Não testado em celular físico.
- Depois da pausa do level-up, o joystick só responde depois de levantar o dedo e tocar de novo.
- Orbes distantes ficam no chão indefinidamente.
- Na tela deitada, a câmera mantém 14 m de largura e mostra pouco mapa na vertical.
- Ambiente de testes: com SwiftShader (renderização por software do Chrome), as atualizações de MultiMesh não aparecem. Use Mesa/GL (`--use-angle=gl`) para os testes visuais.

## Estado dos testes (última execução real)

| Teste | Resultado | Onde |
|---|---|---|
| `tests/run_tests.gd` | aprovado | local, nesta etapa |
| `tests/smoke_test.gd` | aprovado | local, nesta etapa |
| `tests/long_simulation.gd -- --segundos=300` | aprovado | local, nesta etapa |
| `tools/wiki/test_wiki.py` (14 testes) | aprovado | local, nesta etapa |
| `tools/site/test_montar_site.py` (7 testes) | aprovado | local, nesta etapa |
| Workflow no GitHub (execução 45818565861) | aprovado: testar e publicar; verificação no ar pendente do ajuste do Pages | GitHub Actions |
