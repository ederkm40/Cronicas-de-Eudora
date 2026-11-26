---
titulo: Experiência
resumo: A XP vem dos orbes deixados pelos inimigos derrotados e aumenta o nível da partida.
estado: PUBLICADO
versao: 0.2-alpha
ordem: 10
---
A experiência (XP) vem dos [[progressao/orbes-de-experiencia|orbes]]. A quantidade depende do inimigo derrotado:

| Inimigo | XP |
|---|---:|
| [[inimigos/inimigo-comum|Errante]] | 1 |
| [[inimigos/espreitador|Espreitador]] | 1 |
| [[inimigos/couracado|Couraçado]] | 4 |
| [[inimigos/lancador|Lançador]] | 2 |
| [[inimigos/volatil|Volátil]] | 2 |

Um Volátil que explode sozinho não conta como abate do jogador e não deixa orbe.

## Curva de experiência

A XP necessária para passar de um nível ao próximo é `4 × nível^1,35`, arredondada:

| Nível atual | XP para o próximo | XP total desde o início |
|---|---:|---:|
| 1 | 4 | 4 |
| 2 | 10 | 14 |
| 3 | 18 | 32 |
| 4 | 26 | 58 |
| 5 | 35 | 93 |
| 10 | 90 | 433 |

O excesso de XP passa para o próximo nível. É possível subir vários níveis de uma vez; cada nível abre sua própria escolha, uma depois da outra.

Cada nível ganho também recupera **12% da vida máxima**. Veja [[progressao/level-up]].
