# Relatório 0.2-alpha: Ecos da Evolução

| | |
|---|---|
| **Data** | 26/11/2026 |
| **Branch** | `etapa-0.2-alpha-ecos-da-evolucao` |
| **Commits** | `f54c9f0` (sistemas), `63347a3` (testes), `85112cb` (workflow e documentação) |
| **Merge** | `e516f2187f4726b6d63ad674955c15397a0f548d` |
| **Pull Request** | https://github.com/ederkm40/Cronicas-de-Eudora/pull/1 |
| **Workflow do PR** | execução 45797734170, sucesso |
| **Workflow do `main`** | execução 45802232546, sucesso (build e deploy) |
| **Prévia** | não existia; a versão web do PR ficou como artefato `versao-web`. Publicado em https://ederkm40.github.io/Cronicas-de-Eudora/ |

## Objetivo

Primeiro sistema completo de progressão durante a partida: experiência, coleta, subida de nível e escolha entre três melhorias.

## Funcionalidades implementadas

- **Orbes** (`scripts/xp_orbs.gd`): 1 XP por inimigo. Ímã a 3 m (começa a 4 m/s e acelera 30 m/s²), coleta a 0,6 m. Limite de 400, e o excedente é somado ao orbe mais antigo. Arrays + MultiMesh.
- **Progressão** (`scripts/progression.gd`, RefCounted): `requirement(n) = round(4 × n^1,35)`. Vários níveis de uma vez, `pending_level_ups`.
- **Melhorias** (`scripts/upgrades.gd`): 6 definições com limites e efeitos recalculados a partir da base em `refresh()`. Sorteio sem repetição entre as não esgotadas.
- **Tela de level-up** (`scripts/level_up_panel.gd`): `PROCESS_MODE_ALWAYS`, 3 cartões de 168 px de altura, trava de 0,35 s, teclas 1, 2 e 3.
- **Pausa** via `get_tree().paused`. Joystick desligado durante a escolha.
- **HUD**: barra de XP e "Nv."; a derrota mostra o nível.

## Funcionalidades alteradas

- `AutoWeapon`: multiplicadores de dano, cadência e alcance, `extra_projectiles`, leque de 10°, limite de 256 projéteis (era 128), contador `shots_fired`.
- `Player`: `base_max_hp`, `speed_multiplier`, `heal()`, `set_max_hp_multiplier()`; ganchos de teste `invulnerable` e `scripted_input`.
- `EnemyManager`: ganchos de teste `spawning_enabled`, `spawn_at()` e `hp_of()`.
- Workflow: Pull Requests testam e exportam sem publicar.

## Valores e parâmetros

| Parâmetro | Valor |
|---|---|
| XP por inimigo | 1 |
| Curva | `round(4 × n^1,35)`. O primeiro valor testado foi 5; caiu para 4 porque, na simulação, a primeira subida de nível demorava demais |
| Ímã / coleta | 3 m / 0,6 m |
| Poder arcano | +20% de dano, limite 10 |
| Cadência | +15% de velocidade de disparo, limite 8 |
| Núcleo vital | +25% de vida máxima e cura 25, limite 8 |
| Passos ligeiros | +15% de velocidade, limite 5 |
| Projétil adicional | +1 projétil, limite 4 |
| Campo de ruptura | +20% de alcance e duração do projétil, limite 5 |
| Trava da tela de level-up | 0,35 s |

## Correções

- Seta "→" trocada por "»" nos cartões: a fonte da versão web não tinha o símbolo.

## Testes executados e resultados

| Teste | Resultado |
|---|---|
| `tests/run_tests.gd`: 16 testes, 1.627 verificações | **aprovado** (local e GitHub Actions) |
| `tests/smoke_test.gd`: 60 s com joystick, tecla D, coleta e escolhas | **aprovado** |
| `long_simulation.gd --segundos=600` | **aprovado**: 4 mortes e reinícios, 11 melhorias, 66 nós constantes, memória estável |
| `long_simulation.gd --segundos=600 --invulneravel` | **aprovado**: média de 1,3 ms por quadro, p95 de 2,1 ms, p99 de 2,2 ms (CPU do servidor) |
| Testes de mutação (jogo quebrado de propósito: sem pausa, sem orbes, sorteio repetido, sem cura) | os testes correspondentes **falharam**, como esperado |
| Teste visual num Chrome com celular simulado | barra de XP, "Nível 2!", 3 cartões legíveis, toque escolhe e retoma |

## Problemas conhecidos e limitações

- Não foi testado em celular físico.
- Depois da pausa, o joystick só responde depois de levantar o dedo e tocar de novo.
- Equilíbrio não ajustado: a arma base mata devagar diante de 300 inimigos, e a evolução fica lenta depois do nível 6 ou 7.
- Orbes distantes ficam no chão indefinidamente.

## Arquivos afetados

`scripts/xp_orbs.gd`, `scripts/progression.gd`, `scripts/upgrades.gd`, `scripts/level_up_panel.gd` (novos); `scripts/main.gd`, `scripts/auto_weapon.gd`, `scripts/player.gd`, `scripts/enemy_manager.gd`, `scripts/hud.gd`; `tests/run_tests.gd`, `tests/long_simulation.gd` (novos), `tests/smoke_test.gd`; `.github/workflows/web.yml`; `README.md`, `CLAUDE.md`, `docs/TECNICO.md`, `docs/ROADMAP.md`.
