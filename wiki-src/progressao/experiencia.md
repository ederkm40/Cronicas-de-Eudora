---
titulo: Experiência
resumo: Cada inimigo vale 1 de XP; a XP necessária cresce a cada nível.
estado: PUBLICADO
versao: 0.2-alpha
ordem: 10
---
A experiência (XP) vem dos [[progressao/orbes-de-experiencia\|orbes]]. Cada [[inimigos/inimigo-comum\|inimigo]] derrotado vale **1 de XP**.

## Barra de experiência

No topo da tela, abaixo da barra vermelha de vida, fica a **barra azul-clara de experiência**, com o nível atual ao lado (**Nv. 1**, **Nv. 2**…). Ela mostra quanto falta para o próximo nível e volta ao começo a cada nível.

## Curva de experiência

A XP necessária para passar de um nível ao próximo é `4 × nível^1,35`, arredondada:

| Nível atual | XP para o próximo | XP total desde o início |
|---|---|---|
| 1 | 4 | 4 |
| 2 | 10 | 14 |
| 3 | 18 | 32 |
| 4 | 26 | 58 |
| 5 | 35 | 93 |
| 10 | 90 | 433 |

Se um coleta der mais XP do que falta, o que sobra passa para o próximo nível. Dá para **subir vários níveis de uma vez**: cada nível abre a sua própria escolha de melhoria, uma depois da outra. Veja [[progressao/level-up]].
