# Estado atual do projeto

*Atualizado pelo Claude Code a cada entrega. Última atualização: 26/11/2026, etapa 3 "O Despertar de Eudora" (0.4-alpha, PR #10, em revisão).*

| | |
|---|---|
| **Versão oficial** | **0.3-alpha "Grande expansão do combate"** (PR #5, `51e7e5d`), com a manutenção pós-0.3 (PR #7, `202965a`) |
| **Commit do `main`** | `7aba866`: painel de etapas da Wiki (PR #9), depois da documentação do PR #7 (PR #8) |
| **Publicado** | jogo e Wiki oficiais do `main` (https://ederkm40.github.io/Cronicas-de-Eudora/ e `/wiki/`). A build oficial é a de produção, **sem** a ponte de testes (decisão 0011) |
| **Proteção da `main`** | checks obrigatórios: `Testar e exportar` e `Publicar` |
| **Etapa em revisão** | 0.4-alpha "O Despertar de Eudora" (branch `feat/despertar-de-eudora-04`, PR #10); prévia em `/previews/pr-10/` |
| **Fase** | 1, protótipo |

## Sistemas do jogo (no `main`, 0.3-alpha)

| Sistema | Arquivo | Situação |
|---|---|---|
| Joystick flutuante, WASD e setas, retomada depois da pausa | `floating_joystick.gd`, `player.gd` | publicado |
| Câmera isométrica | `camera_rig.gd` | publicado |
| Orbes, progressão, 6 melhorias, level-up com pausa | `xp_orbs.gd`, `progression.gd`, `upgrades.gd`, `level_up_panel.gd` | publicado |
| Raio arcano, Aura de brasas, Lâmina orbital | `weapon_catalog.gd`, `arsenal.gd`, `auto_weapon.gd`, `aura_weapon.gd`, `orbit_blades.gd` | publicado |
| Ofertas com armas, troca e bloqueio | `level_up_offers.gd` | publicado |
| 5 tipos de inimigo e mistura por tempo | `enemy_types.gd`, `enemy_manager.gd`, `enemy_projectiles.gd`, `ground_effects.gd` | publicado |
| Sentinela do Eco aos 10 min | `boss_controller.gd` | publicado |
| Esquiva (duplo toque e Espaço) | `floating_joystick.gd`, `player.gd` | publicado |
| Vitória, derrota, resultados, reinício limpo | `main.gd`, `results_screen.gd`, `run_stats.gd` | publicado |
| Ecos e 4 melhorias permanentes, save validado | `meta_progress.gd` | publicado |

## Em revisão no PR #10 (ainda não publicado)

Mecânicas novas: **propostas experimentais** até o proprietário aprovar. A personalização mobile já era aprovada.

| Sistema | Arquivo | Situação |
|---|---|---|
| Pausa com configurações (mão, joystick fixo/flutuante, tamanho, altura, som, tremor, números), salvas em `user://configuracoes.json`; modo canhoto espelhado | `pause_menu.gd`, `game_settings.gd`, `hud.gd`, `floating_joystick.gd` | implementado e testado (Godot e Playwright, 3 perfis); **não testado em celular físico** |
| Som procedural (12 sons), números de dano (chefe e elites), estouro por abate, tremor | `sound_bank.gd`, `combat_feedback.gd`, `game_feel.gd`, `camera_rig.gd` | implementado e testado; **som não ouvido por pessoa** |
| Evoluções: Raio em cadeia, Coroa de cinzas, Vendaval de lâminas; Pacto do eco | `weapon_catalog.gd`, `arsenal.gd`, `level_up_offers.gd`, armas, `upgrades.gd` | implementado e testado |
| Estados: queimadura, lentidão, empurrão, escudo, vulnerabilidade | `enemy_manager.gd` | implementado e testado |
| Tecelão, Semeador (poças), elites Veloz/Blindado/Gerador | `enemy_types.gd`, `enemy_manager.gd`, `hazard_zones.gd` | implementado e testado |
| Chefe atordoado depois da investida (+50%) e Prisão de ecos | `boss_controller.gd` | implementado e testado; o piloto venceu 3/3 (pode ter ficado fácil) |
| Eventos: elites, Fenda do Eco, Maré e Calmaria | `event_director.gd` | implementado e testado; fenda não medida (o piloto não entra) |
| Câmera deitada com 11 m de altura visível | `camera_rig.gd` | implementado; não testado em aparelho |

## Incompleto, ausente e limitações

- Não testado em celular físico nem por pessoas; FPS no celular não medido. O custo de CPU por quadro subiu de 10 a 20% em média e cerca de 33% no p99 em relação à 0.3.
- Equilíbrio medido só com piloto automático.
- Ações contextuais (mobile) continuam não implementadas.
- O texto da Atração do eco no jogo diz "raio de coleta"; o efeito é no ímã. Orbes distantes ficam no chão.
- Sem arte final; som provisório.
- `EnemyManager` no limite de métodos públicos do `gdlint` (20).

## Estado dos testes

- Desta etapa: `docs/versoes/0.4-alpha/RELATORIO.md` e o PR #10. Local: 71 testes do Godot, 4.613 verificações, 0 falhas; smoke, simulação longa e exportações OK; Playwright na QA e na produção OK.
- Históricos: `docs/versoes/0.3-alpha/RELATORIO.md` e `docs/versoes/manutencao-pos-0.3/RELATORIO.md` (não repetidos nem alterados).
