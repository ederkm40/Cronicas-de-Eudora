---
titulo: Hordas
resumo: Inimigos surgem fora da tela, aumentam em quantidade e ficam mais resistentes durante a partida.
estado: PUBLICADO
versao: 0.4-alpha
ordem: 20
---
Os inimigos surgem logo **fora da área visível**, em volta do personagem, e caminham ou executam seus comportamentos em direção a ele. A mistura de tipos cresce com o tempo.

| Regra | Valor |
|---|---:|
| Intervalo entre ondas no início | 1 s |
| Redução do intervalo | 0,012 s por segundo de partida |
| Intervalo mínimo | 0,12 s |
| Aumento da leva | +1 inimigo a cada 30 s |
| Máximo de inimigos ao mesmo tempo (todos os tipos) | 300 |
| Crescimento de vida | +35% da vida base por minuto |

Os tipos especiais entram gradualmente:

| Inimigo | Começa a aparecer |
|---|---:|
| [[inimigos/espreitador|Espreitador]] | 0:45 |
| [[inimigos/couracado|Couraçado]] | 1:40 |
| [[inimigos/lancador|Lançador]] | 2:30 |
| [[inimigos/volatil|Volátil]] | 3:30 |
| Tecelão | 4:30 |
| Semeador | 5:30 |

Elites modificam inimigos comuns e aparecem periodicamente. Eles têm mais vida, tamanho e dano, recebem um modificador (Veloz, Blindado ou Gerador), são anunciados na tela e concedem um orbe de 12 XP e cura de 15 ao serem derrotados.

O chefe não conta no limite de 300 inimigos.

## Eventos durante a partida

A 0.4-alpha introduz três eventos temporários:

- **Elite:** aos 2:00 e depois a cada 1:15.
- **Fenda do Eco:** aos 2:30 e depois a cada 2:45; ficar 6 s dentro em até 25 s concede uma escolha extra de level-up e 20% de vida, mas as hordas dobram enquanto o jogador permanece na área.
- **Maré e Calmaria:** aos 4:00 e depois a cada 3:00; 15 s de hordas 2,5× mais rápidas, seguidos por 10 s com geração reduzida a 25%.

Os eventos param quando começa o encontro final. Consulte [[desenvolvimento/eventos-da-partida]] para os detalhes e limitações conhecidas.

## Durante o encontro final

Aos 10 minutos começa o encontro com o [[chefes/sentinela-do-eco|Sentinela do Eco]]. Durante esse encontro:

- O ritmo das hordas cai para 30% do ritmo normal.
- Novos Lançadores deixam de nascer.
- Inimigos que já estavam em campo continuam ativos.

O tempo, as hordas, os projéteis e os orbes param durante o [[progressao/level-up|level-up]].
