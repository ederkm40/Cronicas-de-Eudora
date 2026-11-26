# Catálogo 12: Inimigos

Fonte: `scripts/enemy_types.gd` e `scripts/enemy_manager.gd`. Vida = multiplicador × 20, e a base cresce +35% por minuto de partida. Todos: **D** `APROVADO` (Errante 0.1; os outros 4 na 0.3, antecipados da 0.4) · **I** `IMPLEMENTADO` · **V** `TESTADO` (`tests/suites/inimigos_e_chefe.gd`; sem teste com pessoas).

| Tipo (número) | Nome | Arquétipo | Vida | Velocidade | Contato | Resistência | XP | Entrada | Peso máximo |
|---|---|---|---|---|---|---|---|---|---|
| 0 | Errante | comum | 1× | 2,2 m/s | 9/s | 0 | 1 | 0:00 | 1 |
| 1 | Espreitador | rápido | 0,45× | 4,3 m/s | 7/s | 0 | 1 | 0:45 | 0,45 |
| 2 | Couraçado | resistente | 5× | 1,35 m/s | 15/s | 35% | 4 | 1:40 | 0,22 |
| 3 | Lançador | atirador | 1,2× | 2,4 m/s | 6/s | 0 | 2 | 2:30 | 0,15 |
| 4 | Volátil | explosivo | 0,9× | 3,0 m/s | 6/s | 0 | 2 | 3:30 | 0,2 |

O peso de cada tipo cresce de 0 até o máximo depois da entrada (Espreitador em 200 s; os outros em 300 s).

### Comportamento e ataques

| Nome | Comportamento | Ataque e aviso | Referência visual |
|---|---|---|---|
| Errante | persegue | contato | cápsula vermelha |
| Espreitador | mira à frente do jogador; ×1,3 de velocidade a menos de 4 m | contato | cápsula pequena verde-amarela |
| Couraçado | persegue devagar; quase não é empurrado | contato | cubo cinza-azulado |
| Lançador | fica entre 6 e 8,5 m; anda de lado; só atira de dentro da tela | para e brilha 0,55 s; projétil de 8, a 6,5 m/s, a cada ~3,2 s | prisma roxo |
| Volátil | aproxima-se; a menos de 1,9 m acende o pavio e para | círculo no chão por 0,85 s; explosão de 26 no raio de 2,4 m; eliminado antes, não explode e deixa orbe | esfera laranja que pisca |

Regras gerais: até 300 inimigos (todos os tipos); dano de contato de até 5 inimigos ao mesmo tempo; inimigos longe demais reaparecem fora da tela; todos piscam em branco ao levar dano. No encontro final, novos Lançadores não nascem.

Dependências: combate, `GroundEffects` (avisos), `EnemyProjectiles` (Lançador), progressão (XP), `RunStats`.
