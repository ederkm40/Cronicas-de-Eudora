# Mapa do projeto

## Diretórios

```
.
├── AGENTS.md                 regras para qualquer IA (leia primeiro)
├── CLAUDE.md                 complemento só para o Claude Code
├── README.md                 apresentação e links
├── requirements-ci.txt       versões fixadas do GDScript Toolkit (só para o CI)
├── project.godot             configuração do Godot (retrato 720x1280, Compatibility, toque pelo mouse)
├── export_presets.cfg        preset "Web" (sem threads; ensure_cross_origin_isolation_headers=false)
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
| `player.gd` | `Player` | `FloatingJoystick`, `CameraRig`, `BlobShadow` | `EnemyManager`, `AutoWeapon`, `XpOrbManager`, `Upgrades` |
| `camera_rig.gd` | `CameraRig` | — | `Player`, `EnemyManager` |
| `floating_joystick.gd` | `FloatingJoystick` | — | `Player`, `main.gd` |
| `enemy_manager.gd` | `EnemyManager` | `Player`, `CameraRig` | `AutoWeapon`, `main.gd` (sinal `enemy_killed`) |
| `auto_weapon.gd` | `AutoWeapon` | `Player`, `EnemyManager` | `Upgrades` |
| `xp_orbs.gd` | `XpOrbManager` | `Player` | `main.gd` (sinal `collected` → `Progression.add_xp`) |
| `progression.gd` | `Progression` (RefCounted) | — | `main.gd`, `Hud` |
| `upgrades.gd` | `Upgrades` (RefCounted) | `Player`, `AutoWeapon` | `main.gd`, `LevelUpPanel` |
| `level_up_panel.gd` | `LevelUpPanel` | `Upgrades` | `main.gd` (sinal `chosen`) |
| `hud.gd` | `Hud` | — | `main.gd` (sinal `restart_requested`) |
| `blob_shadow.gd` | `BlobShadow` | — | `Player` |

Fluxo de uma partida: `EnemyManager.damage()` → `enemy_killed` → `XpOrbManager.spawn()` → `collected` → `Progression.add_xp()` → `pending_level_ups` → `main._open_level_up()` (pausa) → `LevelUpPanel.chosen` → `Upgrades.apply()` → retoma.

## Testes

| Arquivo | Roda com | Cobre |
|---|---|---|
| `tests/run_tests.gd` | Godot `--script` | 16 testes da progressão, efeitos, pausa, derrota, reinício |
| `tests/smoke_test.gd` | Godot `--script` | partida de 60 s de ponta a ponta |
| `tests/long_simulation.gd` | Godot `--script -- --segundos=N [--invulneravel]` | estabilidade, desempenho, memória, reinícios |
| `tools/wiki/test_wiki.py` | Python 3 (+ Node, se houver) | geração, links, busca, determinismo, erros esperados |
| `tools/site/test_montar_site.py` | Python 3 | montagem: oficial × prévia, remoção, limpeza |
| `tools/ci/verificar_gdscript.sh lint` / `formato <base>` | gdtoolkit 4.5.0 (CI) | `gdlint` em `scripts/` e `tests/`; `gdformat --check` nos `.gd` alterados |
| `tools/e2e/testes/jogo.spec.js` | Playwright 1.65.1 + Chromium (CI, `xvfb-run`) | jogo exportado no navegador: computador, Pixel 7 em pé e deitado |

Ganchos de teste no código: `EnemyManager.spawning_enabled`, `spawn_at()`, `hp_of()`; `Player.invulnerable`, `scripted_input`; `AutoWeapon.shots_fired`.

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
