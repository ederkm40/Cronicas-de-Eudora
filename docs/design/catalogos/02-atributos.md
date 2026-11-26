# Catálogo 02: Atributos

Atributos que existem no código da 0.3-alpha. Fórmulas e ordem de aplicação: seção 5 do [Documento Mestre](../DOCUMENTO_MESTRE_SISTEMAS.md). Todos: **D** `APROVADO` · **I** `IMPLEMENTADO` · **V** `TESTADO` (testes de efeito em `tests/suites/progressao.gd` e `armas_e_ofertas.gd`), salvo indicação.

| ID (conceito) | Atributo | Base | Modificado por | Limite | Origem no código |
|---|---|---|---|---|---|
| `vida_maxima` | Vida máxima do jogador | 100 | Núcleo vital ×(1+0,25n), Vigor ancestral ×(1+0,08v) | 8 e 5 níveis | `Player.base_max_hp`, `Upgrades.refresh` |
| `velocidade` | Velocidade de movimento | 5 m/s | Passos ligeiros ×(1+0,15n) | 5 níveis | `Player.move_speed` |
| `dano` | Multiplicador de dano de todas as armas | 1 | Poder arcano (1+0,2n), Fúria latente ×(1+0,05f) | 10 e 5 níveis | `Upgrades.refresh` |
| `cadencia` | Velocidade do Raio e dos pulsos da Aura | 1 | Cadência (1+0,15n) | 8 níveis | `AutoWeapon.fire_rate_multiplier`, `AuraWeapon.rate_multiplier` |
| `alcance` | Alcance do Raio | 11 m | Campo de ruptura (1+0,2n) | 5 níveis | `AutoWeapon.range_multiplier` |
| `area_aura` | Raio da Aura | por nível | Campo de ruptura (1+0,1n) | 5 níveis | `AuraWeapon.area_multiplier` |
| `projeteis` | Projéteis do Raio por disparo | 1 | Projétil adicional (+n) | 4 níveis | `AutoWeapon.extra_projectiles` |
| `ima` | Raio do ímã de orbes | 3 m | Atração do eco ×(1+0,2a) | 3 níveis | `XpOrbManager.magnet_radius` |
| `coleta` | Raio de coleta de orbes | 0,6 m | — | — | `XpOrbManager.collect_radius` |
| `invulnerabilidade` | Tempo sem dano na esquiva | 0,32 s | — | — | `Player.dodge_invulnerability` |
| `cura_por_nivel` | Cura ao ganhar nível | 12% da vida máxima | — | — | `Main.level_up_heal` |
| `resistencia` | Parte do dano ignorada (inimigos) | 0 | por tipo: Couraçado 0,35 | — | `EnemyTypes.STATS.armor` |

Atributos planejados (crítico, armadura, regeneração, sorte etc.): `PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO` — lista na seção 5.2 do Documento Mestre, **sem entradas aqui** até haver decisão.
