# Estado atual do projeto

*Atualizado pelo Claude Code a cada entrega. Última atualização: 27/11/2026, 0.5-alpha Parte 1 "menu inicial" (branch `claude/bold-clarke-aixtws`, PR #14, em revisão).*

| | |
|---|---|
| **Versão oficial** | **0.4-alpha "O Despertar de Eudora"** (PR #10, `f51db23`), com a manutenção pós-0.4 (PR #12, `baea23d`) |
| **Commit do `main`** | `baea23d`: manutenção pós-0.4 (PR #12) |
| **Publicado** | jogo e Wiki oficiais do `main` (https://ederkm40.github.io/Cronicas-de-Eudora/ e `/wiki/`). A build oficial é a de produção, **sem** a ponte de testes (decisão 0011) |
| **Proteção da `main`** | checks obrigatórios: `Testar e exportar` e `Publicar` |
| **Etapa em revisão** | 0.5-alpha, Parte 1 de 4: menu inicial (PR #14, `docs/versoes/0.5-alpha-parte-1/RELATORIO.md`). O jogo passa a abrir no menu; a partida continua igual |
| **Também aberto** | PR #13 (ChatGPT): Wiki e changelog da manutenção pós-0.4 |
| **Fase** | 1, protótipo |

## Sistemas do jogo (no `main`)

| Sistema | Arquivo | Situação |
|---|---|---|
| Joystick flutuante, WASD e setas, retomada depois da pausa | `floating_joystick.gd`, `player.gd` | publicado |
| Câmera isométrica | `camera_rig.gd` | publicado |
| Orbes, progressão, 6 melhorias, level-up com pausa | `xp_orbs.gd`, `progression.gd`, `upgrades.gd`, `level_up_panel.gd` | publicado |
| Raio arcano, Aura de brasas, Lâmina orbital | `weapon_catalog.gd`, `arsenal.gd`, `auto_weapon.gd`, `aura_weapon.gd`, `orbit_blades.gd` | publicado |
| Ofertas com armas, troca e bloqueio | `level_up_offers.gd` | publicado |
| 5 tipos de inimigo e mistura por tempo | `enemy_types.gd`, `enemy_manager.gd`, `enemy_renderer.gd` (desenho), `enemy_projectiles.gd`, `ground_effects.gd` | publicado |
| Sentinela do Eco aos 10 min | `boss_controller.gd` | publicado |
| Esquiva (duplo toque e Espaço) | `floating_joystick.gd`, `player.gd` | publicado |
| Vitória, derrota, resultados, reinício limpo | `main.gd`, `results_screen.gd`, `run_stats.gd` | publicado |
| Ecos e 4 melhorias permanentes, save validado | `meta_progress.gd` | publicado |

## Em revisão no PR #14 (0.5-alpha, Parte 1)

| Sistema | Arquivo | Situação |
|---|---|---|
| Menu inicial: JOGAR, Personagens, Missões, Loja, Configurações; cena inicial do jogo | `main_menu.gd`, `scenes/menu.tscn` | implementado e testado (Godot e Playwright no CI); não testado em celular físico |
| Voltar único: Esc, Android, navegador (não sai mais da página) | `back_navigation.gd` | implementado e testado (Playwright `page.goBack()`); não testado em celular físico |
| Configurações e loja compartilhadas | `settings_panel.gd`, `shop_panel.gd` | implementado e testado |
| Pacote personagem + missão para a partida | `run_setup.gd` | só os atuais (`padrao`) |
| Encerrar partida (pausa), Voltar ao menu (resultados) | `pause_menu.gd`, `results_screen.gd`, `main.gd` | implementado e testado |
| Botão de pausa visível e estilo comum de botões | `ui_style.gd`, `hud.gd` | implementado; o proprietário não tinha achado o botão antigo |

## 0.4-alpha (PR #10, publicado)

Mecânicas novas: **propostas experimentais** até o proprietário dizer que ficam (o merge integrou o código). A personalização mobile já era aprovada.

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
- Orbes distantes ficam no chão.
- Sem arte final; som provisório.
- `EnemyManager`: 772 linhas e 18 métodos públicos depois da manutenção pós-0.4 (decisão 0013); antes, 890 e 20 (o limite).

## Estado dos testes

- Desta etapa: `docs/versoes/0.5-alpha-parte-1/RELATORIO.md`. Local: 86 testes do Godot, 4.704 verificações, 0 falhas; smoke (pelo menu) e simulação longa OK. Playwright no CI: QA 33 aprovados e 3 pulados; produção 11 aprovados e 1 pulado.
- Históricos: `docs/versoes/manutencao-pos-0.4/`, `0.4-alpha/`, `0.3-alpha/` e `manutencao-pos-0.3/` (não repetidos nem alterados).
