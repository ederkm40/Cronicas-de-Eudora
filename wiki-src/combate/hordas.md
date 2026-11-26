---
titulo: Hordas
resumo: Inimigos surgem fora da tela, cada vez mais rápido e em grupos maiores, até 300 ao mesmo tempo.
estado: PUBLICADO
versao: 0.1-alpha
ordem: 20
---
Os [[inimigos/inimigo-comum\|inimigos]] surgem logo **fora da área visível**, em volta do personagem, e andam até ele. A pressão cresce com o tempo de partida:

| Regra | Valor |
|---|---|
| Intervalo entre ondas no início | 1 s |
| Redução do intervalo | 0,012 s por segundo de partida |
| Intervalo mínimo | 0,12 s (alcançado por volta de 1 min 13 s) |
| Inimigos por onda | 1, mais 1 a cada 25 s de partida |
| Máximo ao mesmo tempo | 300 |
| Vida dos novos inimigos | +60% da base a cada minuto |

Na simulação automática, a horda chega ao máximo de 300 inimigos por volta dos 2 minutos.

O tempo de partida **para durante o [[progressao/level-up]]**: as hordas não avançam enquanto você escolhe.
