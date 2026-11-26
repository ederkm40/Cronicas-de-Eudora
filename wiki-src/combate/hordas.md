---
titulo: Hordas
resumo: Inimigos surgem fora da tela, aumentam em quantidade e ficam mais resistentes durante a partida.
estado: PUBLICADO
versao: 0.1-alpha
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

O chefe não conta no limite de 300 inimigos.

## Durante o encontro final

Aos 10 minutos começa o encontro com o [[chefes/sentinela-do-eco|Sentinela do Eco]]. Durante esse encontro:

- O ritmo das hordas cai para 30% do ritmo normal.
- Novos Lançadores deixam de nascer.
- Inimigos que já estavam em campo continuam ativos.

O tempo, as hordas, os projéteis e os orbes param durante o [[progressao/level-up|level-up]].
