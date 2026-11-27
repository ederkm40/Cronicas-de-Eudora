# Mapa do projeto

## Diretórios

```
.
├── AGENTS.md                 regras para qualquer IA (leia primeiro)
├── CLAUDE.md                 complemento só para o Claude Code
├── README.md                 apresentação e links
├── requirements-ci.txt       versões fixadas do GDScript Toolkit (só para o CI)
├── project.godot             configuração do Godot (retrato 720x1280, Compatibility, toque pelo mouse)
├── export_presets.cfg        presets "Web" (produção, sem a ponte de testes) e "Web QA" (funcionalidade qa, só para testes); sem threads
├── icon.svg (+ .import)      ícone do jogo
├── scenes/main.tscn          cena única: um Node3D com scripts/main.gd
├── scripts/                  todo o código do jogo (GDScript)
├── tests/                    testes do jogo (rodam no Godot sem tela)
├── tools/                    ferramentas em Python e shell (.gdignore: fora do jogo)
│   ├── wiki/                 gerador da Wiki e testes
│   ├── site/                 montagem do site publicado e testes
│   ├── ci/                   scripts usados pelo workflow
│   └── e2e/                  testes de navegador (Playwright 1.65.1; package.json + package-lock.json)
├── wiki-src/                 fontes da Wiki (.gdignore)
│   ├── site.json             nome, versão oficial, categorias
│   ├── index.md              página inicial
│   ├── <categoria>/index.md  página da categoria
│   ├── <categoria>/<artigo>.md
│   ├── desenvolvimento/      painel de desenvolvimento
│   └── assets/               CSS, busca (JS), logotipo
├── docs/                     documentação permanente (.gdignore)
│   ├── TECNICO.md            arquitetura, fórmulas, desempenho, testes
│   ├── ROADMAP.md            próximas etapas
│   ├── CHANGELOG.md          registro de mudanças (editorial: ChatGPT)
│   ├── versoes/<v>/RELATORIO.md   relatório de cada versão
│   ├── decisoes/NNNN-*.md    decisões técnicas
│   ├── design/               Documento Mestre de Sistemas e catálogos (design; não autoriza implementar)
│   └── IA/                   estado, mapa, continuidade, entrega para o ChatGPT
└── .github/
    ├── workflows/publicar.yml       testes, prévias e publicação
    ├── ISSUE_TEMPLATE/*.yml         5 formulários de Issue
    └── PULL_REQUEST_TEMPLATE.md     modelo de Pull Request
```

`build/` e `.godot/` são gerados e ficam fora do Git.

## Scripts do jogo e relações

| Script | Classe | Usa | É usado por |
|---|---|---|---|
| `main.gd` | (raiz da cena) | todos abaixo | `scenes/main.tscn` |
| `player.gd` | `Player` | `FloatingJoystick`, `CameraRig`, `GroundEffects`, `BlobShadow` | inimigos, armas, orbes, `Upgrades`, `BossController` |
| `camera_rig.gd` | `CameraRig` | — | `Player`, `EnemyManager`, `main.gd` |
| `floating_joystick.gd` | `FloatingJoystick` | — | `Player` (sinal `dodge_requested`), `main.gd` |
| `enemy_types.gd` | `EnemyTypes` (dados) | — | `EnemyManager`, `BossController`, `RunStats`, testes |
| `enemy_manager.gd` | `EnemyManager` | `Player`, `CameraRig`, `EnemyProjectiles`, `GroundEffects`, `RunStats`, `EnemyRenderer` | armas, `BossController`, `main.gd` (sinais `enemy_killed`, `boss_died`) |
| `enemy_renderer.gd` | `EnemyRenderer` (filho do `EnemyManager`) | `EnemyTypes` | `EnemyManager` (`draw()` uma vez por quadro) |
| `main_menu.gd` | `MainMenu` (cena `scenes/menu.tscn`, a cena inicial) | `MetaProgress`, `GameSettings`, `RunSetup`, `SettingsPanel`, `ShopPanel`, `BackNavigation`, `UiStyle` | — (troca para `main.tscn` no JOGAR) |
| `run_setup.gd` | `RunSetup` (escolha de personagem e missão) | — | `MainMenu` (grava), `main.gd` (lê com `take()`) |
| `back_navigation.gd` | `BackNavigation` (Esc, voltar do Android e do navegador) | `JavaScriptBridge` (só na web) | `MainMenu`, `main.gd` |
| `settings_panel.gd` | `SettingsPanel` | `GameSettings`, `UiStyle` | `PauseMenu`, `MainMenu` |
| `shop_panel.gd` | `ShopPanel` | `MetaProgress`, `UiStyle` | `ResultsScreen`, `MainMenu` |
| `ui_style.gd` | `UiStyle` (visual dos botões e textos) | — | menu, pausa, resultados, `Hud` (botão de pausa) |
| `enemy_projectiles.gd` | `EnemyProjectiles` | `Player` | `EnemyManager` (Lançador), `BossController` (rajada) |
| `boss_controller.gd` | `BossController` | `EnemyManager`, `Player`, `GroundEffects`, `EnemyProjectiles` | `main.gd` (`start_encounter`, sinal `phase_changed`) |
| `ground_effects.gd` | `GroundEffects` | — | inimigos, chefe, lâmina, esquiva |
| `weapon_catalog.gd` | `WeaponCatalog` (dados) | — | `Arsenal`, armas, `LevelUpOffers`, `main.gd` |
| `arsenal.gd` | `Arsenal` (RefCounted) | `WeaponCatalog` | `LevelUpOffers`, `main.gd` |
| `auto_weapon.gd` | `AutoWeapon` (Raio arcano) | `Player`, `EnemyManager` | `Upgrades` |
| `aura_weapon.gd` | `AuraWeapon` | `Player`, `EnemyManager` | `Upgrades`, `main.gd` |
| `orbit_blades.gd` | `OrbitBlades` | `Player`, `EnemyManager`, `GroundEffects` | `Upgrades`, `main.gd` |
| `xp_orbs.gd` | `XpOrbManager` | `Player` | `main.gd` (sinal `collected` → `Progression.add_xp`) |
| `progression.gd` | `Progression` (RefCounted) | — | `main.gd` (sinal `leveled_up` → cura), `Hud` |
| `upgrades.gd` | `Upgrades` (RefCounted) | `Player`, armas | `LevelUpOffers`, `main.gd` |
| `level_up_offers.gd` | `LevelUpOffers` (RefCounted) | `Upgrades`, `Arsenal`, `WeaponCatalog` | `LevelUpPanel`, `main.gd` |
| `level_up_panel.gd` | `LevelUpPanel` | `LevelUpOffers` | `main.gd` (sinais `chosen`, `reroll_requested`, `banish_requested`) |
| `hud.gd` | `Hud` | — | `main.gd` |
| `results_screen.gd` | `ResultsScreen` | `MetaProgress`, `Hud.format_time` | `main.gd` (sinal `restart_requested`) |
| `run_stats.gd` | `RunStats` (RefCounted) | `EnemyTypes` | `EnemyManager`, `main.gd`, tela de resultados |
| `meta_progress.gd` | `MetaProgress` (RefCounted) | arquivo `user://progresso.json` | `main.gd`, `ResultsScreen` |
| `web_bridge.gd` | (sem `class_name`) | `JavaScriptBridge`; só existe na build "Web QA" | `main.gd` carrega por caminho na build QA; testes de navegador |
| `blob_shadow.gd` | `BlobShadow` | — | `Player` |
| `hazard_zones.gd` | `HazardZones` (0.4) | `Player`, `GroundEffects` | `EnemyManager` (Semeador) |
| `event_director.gd` | `EventDirector` (0.4) | `EnemyManager`, `Player`, `CameraRig`, `GroundEffects`, `RunStats` | `main.gd` (sinais `announced`, `rift_completed`) |
| `sound_bank.gd` | `SoundBank` (0.4) | — (sons gerados no código) | `GameFeel`, `main.gd` |
| `combat_feedback.gd` | `CombatFeedback` (0.4) | — | `GameFeel` |
| `game_feel.gd` | `GameFeel` (0.4) | `SoundBank`, `CameraRig`, `CombatFeedback`, `GroundEffects` | `main.gd` (`connect_to`) |
| `game_settings.gd` | `GameSettings` (0.4, RefCounted) | arquivo `user://configuracoes.json` | `main.gd`, `PauseMenu` |
| `pause_menu.gd` | `PauseMenu` (0.4) | `GameSettings` | `main.gd` (sinais `resumed`, `settings_changed`) |

Fluxo de uma partida: `EnemyManager.damage(índice, dano, arma)` → `RunStats` → `enemy_killed(posição, tipo, xp)` → `XpOrbManager.spawn()` → `collected` → `Progression.add_xp()` (cura 12% por nível) → `main._open_level_up()` (pausa) → `LevelUpOffers.roll_for_level_up()` → `LevelUpPanel` (`chosen` / `reroll_requested` / `banish_requested`) → `main.apply_offer()` → `_sync_weapons()` → retoma. 0.4: `EventDirector` ajusta `spawn_rate_multiplier` e cria elites e fendas; `GameFeel` transforma sinais em som, números e tremor; o botão "II" do `Hud` → `main.open_pause()` → `PauseMenu` → `settings_changed` → `main._apply_settings()`. Aos 600 s: `main.start_encounter()` → `EventDirector.stop()` → `BossController.spawn()`. Chefe derrotado (`boss_died`) ou jogador morto (`died`) → `main._finish()` → `MetaProgress.record_run()` + `save()` → `ResultsScreen`.

## Testes

| Arquivo | Roda com | Cobre |
|---|---|---|
| `tests/run_tests.gd` | Godot `--script` | executor das suítes de `tests/suites/` (71 testes) |
| `tests/suites/base.gd` | — | base das suítes: ajudantes (partida nova, toques, teclas, inimigos parados) |
| `tests/suites/progressao.gd` | (pelo executor) | 16 testes da 0.2: XP, level-up, efeitos, pausa, derrota, reinício |
| `tests/suites/armas_e_ofertas.gd` | (pelo executor) | 9 testes: arsenal, aura, horda, lâmina, níveis, ofertas, troca, bloqueio |
| `tests/suites/inimigos_e_chefe.gd` | (pelo executor) | 7 testes: mistura por tempo, velocidades e resistência, Lançador, Volátil, chefe |
| `tests/suites/esquiva_e_encerramento.gd` | (pelo executor) | 9 testes: esquiva, duplo toque, derrota, reinício após vitória, progresso salvo |
| `tests/suites/save_e_joystick.gd` | (pelo executor) | 10 testes: save com estrutura/campos inválidos, versão futura, retomada do joystick após a pausa |
| `tests/suites/despertar.gd` | (pelo executor) | 20 testes da 0.4: evoluções, Pacto, elites, Tecelão, Semeador, chefe atordoado e prisão, fenda, maré, configurações, canhoto, joystick fixo, pausa, sons, números |
| `tests/smoke_test.gd` | Godot `--script` | partida de 60 s de ponta a ponta (joystick, D, Espaço, ofertas; 0.4: elite, fenda, pausa por Esc, sons) |
| `tests/long_simulation.gd` | Godot `--script -- --segundos=N [--invulneravel] [--armas-maximas]` | estabilidade, desempenho, memória, reinícios |
| `tests/balance_simulation.gd` | Godot `--script -- --modo=dps\|partida\|chefe` | **fora do CI**: telemetria de equilíbrio |
| `tools/ci/rodar_godot.sh` | bash | roda um script do Godot e falha se o log tiver erro de script |
| `tools/wiki/test_wiki.py` | Python 3 (+ Node) | geração, links, busca, determinismo, erros esperados |
| `tools/site/test_montar_site.py` | Python 3 | montagem: oficial × prévia, remoção, limpeza |
| `tools/ci/verificar_gdscript.sh lint` / `formato <base>` | gdtoolkit 4.5.0 (CI) | `gdlint`; `gdformat --check` nos `.gd` alterados (mostra o diff se falhar) |
| `tools/e2e/testes/jogo.spec.js` | Playwright 1.65.1 + Chromium (CI, `xvfb-run`) | jogo exportado abre e roda nos 3 perfis |
| `tools/e2e/testes/jogabilidade.spec.js` | idem, na build Web QA | controles reais: joystick, duplo toque, Espaço, level-up, vitória, derrota, retomada do joystick |
| `tools/e2e/testes/producao.spec.js` | idem, na build de produção | sem ponte de testes, com e sem `?teste=1` |
| `tools/ci/construir_qa.sh` / `verificar_producao.sh` | bash (CI) | exporta a build Web QA; confere que o `.pck` de produção não tem a ponte |

Ganchos de teste no código: `EnemyManager.spawning_enabled`, `spawn_at()`; `Player.invulnerable`, `scripted_input`; `AutoWeapon.shots_fired`; `Main.start_encounter()`, `apply_offer()`, `encounter_time`; `MetaProgress.path`; ponte `web_bridge.gd` (só na build Web QA).

## Configuração e publicação

| Arquivo | Papel |
|---|---|
| `.github/workflows/publicar.yml` | jobs `testar` ("Testar e exportar") → `publicar` ("Publicar"), os dois checks obrigatórios da `main`, e `remover-previa` (PR fechado) |
| `requirements-ci.txt` | gdtoolkit e dependências, versões fixadas, instalados num ambiente virtual temporário do runner |
| `tools/e2e/playwright.config.js` | perfis, servidor local, renderizador (`E2E_RENDERIZADOR`), evidências só em falha |
| `tools/ci/instalar_godot.sh` | baixa o Godot e os modelos Web (com cache) |
| `tools/ci/construir_parte.sh` | exporta o jogo, gera a Wiki e grava `versao.json` |
| `tools/site/montar_site.py` | aplica a parte no `gh-pages`: raiz (oficial) ou `previews/pr-N/` |
| `tools/ci/abrir_gh_pages.sh` / `enviar_gh_pages.sh` | baixa e envia o branch `gh-pages` |
| `tools/ci/verificar_publicacao.sh` | confirma que o endereço abriu com o commit certo |

Site publicado (branch `gh-pages`): `/` jogo oficial, `/wiki/`, `/previews/`, `/previews/pr-N/`, `/previews/pr-N/wiki/`, `/publicacao.json`, `/versao.json`.

## Comandos importantes

Ver a seção "Comandos de verificação" do `AGENTS.md`. Para montar uma parte localmente: `GODOT=<caminho do godot> bash tools/ci/construir_parte.sh . /tmp/parte previa 0 <commit> <branch>`.
