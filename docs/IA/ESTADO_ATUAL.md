# Estado atual do projeto

*Atualizado pelo Claude Code a cada entrega. Última atualização: 26/11/2026, versão 0.3-alpha (PR #5, em revisão).*

| | |
|---|---|
| **Versão estável (oficial)** | 0.2-alpha "Ecos da Evolução" + infraestrutura de Wiki, prévias, memória e ferramentas de QA |
| **Branch principal** | `main` |
| **Commit do `main`** | `70cf85fc5e459a042f415e4b5e5493a2233465e9`: PR #4 integrado (squash) em 26/11/2026; CI e publicação com sucesso |
| **Publicado** | jogo e Wiki oficiais do commit `70cf85f` (https://ederkm40.github.io/Cronicas-de-Eudora/ e `/wiki/`) |
| **Proteção da `main`** | checks obrigatórios: `Testar e exportar` e `Publicar` |
| **Etapa em revisão** | 0.3-alpha, grande expansão do combate (branch `feat/grande-expansao-combate-03`, PR #5); prévia em `/previews/pr-5/` |
| **Fase** | 1, protótipo |

## Sistemas do jogo

| Sistema | Arquivo | Situação |
|---|---|---|
| Joystick flutuante, WASD e setas | `floating_joystick.gd`, `player.gd` | publicado (0.1) |
| Câmera isométrica | `camera_rig.gd` | publicado (0.1) |
| Orbes, progressão, 6 melhorias, level-up com pausa | `xp_orbs.gd`, `progression.gd`, `upgrades.gd`, `level_up_panel.gd` | publicado (0.2); melhorias ampliadas na 0.3 (sinergias com as armas) |
| Raio arcano (arma inicial) | `auto_weapon.gd` | publicado; na 0.3 mira o chefe e colide pela grade |
| Aura de brasas e Lâmina orbital (5 níveis) | `weapon_catalog.gd`, `arsenal.gd`, `aura_weapon.gd`, `orbit_blades.gd` | **implementado e testado** (PR #5) |
| Ofertas com armas, troca e bloqueio | `level_up_offers.gd`, `level_up_panel.gd` | **implementado e testado** (PR #5) |
| 4 tipos de inimigo + mistura por tempo | `enemy_types.gd`, `enemy_manager.gd`, `enemy_projectiles.gd`, `ground_effects.gd` | **implementado e testado** (PR #5) |
| Chefe Sentinela do Eco aos 10 min | `boss_controller.gd` | **implementado e testado** (PR #5); equilíbrio a validar com pessoas |
| Esquiva (duplo toque e Espaço) | `floating_joystick.gd`, `player.gd` | **implementado e testado** (PR #5); destro/canhoto e ajuste do joystick **pendentes** |
| Vitória, derrota, resultados, reinício limpo | `main.gd`, `results_screen.gd`, `run_stats.gd` | **implementado e testado** (PR #5) |
| Ecos e 4 melhorias permanentes (save versionado) | `meta_progress.gd` | **implementado e testado** (PR #5) |
| Ponte de testes do navegador (`?teste=1`) | `web_bridge.gd` | implementado (PR #5) |

## Sistemas incompletos ou ausentes

- Destro/canhoto e ajuste do joystick; som; arte final; itens; classes; cidade.
- Equilíbrio medido só com piloto automático.

## Bugs e limitações conhecidos

- Não testado em celular físico (os testes de navegador emulam um Pixel 7).
- Custo de CPU por quadro dobrou em relação à 0.2 (ver relatório da 0.3); falta medir FPS no celular.
- Depois da pausa do level-up, o joystick só responde depois de levantar o dedo e tocar de novo.
- Orbes distantes ficam no chão indefinidamente.
- Na tela deitada, a câmera mantém 14 m de largura e mostra pouco mapa na vertical.
- Com SwiftShader as atualizações de MultiMesh não aparecem; o CI usa `xvfb-run` + `--use-angle=gl` (Mesa/llvmpipe).
- 2 arquivos GDScript antigos ainda não passaram pelo `gdformat` (`xp_orbs.gd`, `progression.gd`); serão formatados quando forem alterados.

## Estado dos testes (última execução real)

Ver `docs/versoes/0.3-alpha/RELATORIO.md` e o PR #5. Resumo: `gdlint` sem problemas; `gdformat` nos 30 arquivos alterados; 41 testes do Godot (4.370 verificações), smoke e simulação de 5 min aprovados; Wiki (14) e site (7) aprovados; Playwright 18 aprovados e 3 pulados de propósito nos 3 perfis, com Mesa/llvmpipe; prévia verificada no ar.
