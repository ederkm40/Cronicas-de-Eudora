# Catálogo 03: Armas

Fonte dos números: `scripts/weapon_catalog.gd` e `scripts/auto_weapon.gd`. Campos que o código ainda não tem (elemento, tipo de dano, raridade, evoluções, sons) ficam "—".

### Raio arcano

| Campo | Valor |
|---|---|
| **ID permanente** | `raio_arcano` |
| **Categoria** | foco arcano · projétil |
| **Descrição** | dispara sozinho no inimigo mais próximo |
| **Função** | dano a distância em alvo único; arma inicial |
| **Valores** | dano 10 por projétil; intervalo 0,45 s; alcance 11 m; velocidade 14 m/s; duração 1,2 s (cresce com o alcance); raio de acerto 0,55 m (maior contra inimigos maiores); leque de 10° entre projéteis; até 256 projéteis ativos |
| **Efeitos** | cada projétil acerta 1 inimigo e some; mira o chefe quando ele está ao alcance |
| **Requisitos** | começa no arsenal |
| **Sinergias** | Poder arcano, Cadência, Projétil adicional, Campo de ruptura, Fúria latente |
| **Limitações** | nível único (`max_level` 1): cresce só pelas passivas; o projétil para no primeiro inimigo do caminho |
| **Elemento / tipo de dano / raridade** | — / — / — |
| **Evoluções** | — |
| **Referência visual** | esfera amarela pequena (provisório) |
| **Efeitos sonoros** | — (o jogo não tem som) |
| **Dependências** | `EnemyManager` (alvo, colisão pela grade, dano), `Upgrades` |
| **Estado de design** | `APROVADO` (0.1-alpha) |
| **Estado de implementação** | `IMPLEMENTADO` (`scripts/auto_weapon.gd`) |
| **Estado de validação** | `TESTADO` (`progressao.gd`: efeitos das 4 passivas; sem teste com pessoas) |

### Aura de brasas

| Campo | Valor |
|---|---|
| **ID permanente** | `aura_de_brasas` |
| **Categoria** | arma de área · aura |
| **Descrição** | círculo de brasas que queima todos os inimigos dentro dele a cada pulso |
| **Função** | dano em área contra quem chega perto; limpa grupos |
| **Valores (nível 1 → 5)** | dano 6, 7, 9, 11, 14 · raio 2,2, 2,4, 2,6, 2,9, 3,2 m · pulso 0,6, 0,6, 0,55, 0,5, 0,45 s |
| **Efeitos** | um pulso acerta todos cujo corpo toca o círculo; nunca dá dano por quadro |
| **Requisitos** | oferta de nova arma no level-up, com espaço livre no arsenal (4 espaços) |
| **Sinergias** | Poder arcano (dano), Cadência (pulso), Campo de ruptura (+10% de raio por nível), Fúria latente |
| **Limitações** | só alcança quem está perto; limite de nível 5 |
| **Elemento / tipo de dano / raridade** | — (o nome sugere fogo; não há sistema de elementos) / — / — |
| **Evoluções** | — (níveis 1–5 apenas) |
| **Referência visual** | disco com shader, borda de brasas e onda a cada pulso (provisório) |
| **Efeitos sonoros** | — |
| **Dependências** | `EnemyManager.indices_in_radius`, `damage`; `Upgrades` |
| **Estado de design** | `APROVADO` (0.3-alpha) |
| **Estado de implementação** | `IMPLEMENTADO` (`scripts/aura_weapon.gd`) |
| **Estado de validação** | `TESTADO` (`armas_e_ofertas.gd`: pulsos, alcance, dano, horda de 80, sinergias, níveis; simulação `--modo=dps`) |

### Lâmina orbital

| Campo | Valor |
|---|---|
| **ID permanente** | `lamina_orbital` |
| **Categoria** | arma orbital |
| **Descrição** | lâminas giram ao redor do jogador e cortam quem atravessam |
| **Função** | dano em anel ao redor do jogador; recompensa posicionamento |
| **Valores (nível 1 → 5)** | dano 14, 15, 20, 22, 26 · lâminas 1, 2, 2, 3, 4 · raio 1,9, 1,9, 2,2, 2,2, 2,5 m · giro 3,2, 3,2, 3,6, 3,8, 4,0 rad/s |
| **Efeitos** | cada inimigo só é cortado de novo depois de 0,35 s, mesmo com várias lâminas passando; alcance de corte 0,5 m + corpo do inimigo |
| **Requisitos** | oferta de nova arma no level-up, com espaço livre |
| **Sinergias** | Poder arcano, Fúria latente (Cadência e Campo de ruptura **não** afetam a Lâmina) |
| **Limitações** | não acerta quem está dentro ou fora do anel; até 6 lâminas no código, 4 usadas |
| **Elemento / tipo de dano / raridade** | — / — / — |
| **Evoluções** | — |
| **Referência visual** | prisma claro com rastro e anel fino da órbita (provisório) |
| **Efeitos sonoros** | — |
| **Dependências** | `EnemyManager.indices_in_radius`, `try_blade_hit`, `damage`; `GroundEffects` (faísca) |
| **Estado de design** | `APROVADO` (0.3-alpha) |
| **Estado de implementação** | `IMPLEMENTADO` (`scripts/orbit_blades.gd`) |
| **Estado de validação** | `TESTADO` (`armas_e_ofertas.gd`: órbita, giro, dano por corte, 1 × 4 lâminas, limite da recarga) |

Medição de dano por segundo (simulação, não pessoas): ver [catálogo 30](30-testes-e-balanceamento.md).
