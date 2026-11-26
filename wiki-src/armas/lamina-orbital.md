---
titulo: Lâmina orbital
resumo: Lâminas giratórias que orbitam o jogador e podem evoluir em Vendaval de lâminas.
estado: PUBLICADO
versao: 0.4-alpha
ordem: 30
---
A **Lâmina orbital** mantém lâminas girando ao redor do personagem. Cada lâmina causa dano quando atravessa um inimigo.

Um mesmo inimigo só pode receber outro corte depois de 0,35 s, mesmo quando várias lâminas passam por ele.

A arma pode ser adquirida no [[progressao/level-up|level-up]] e evoluída até o nível 5.

## Valores por nível

| Nível | Dano por corte | Lâminas | Raio da órbita | Velocidade de giro |
|---|---:|---:|---:|---:|
| 1 | 14 | 1 | 1,9 m | 3,2 rad/s |
| 2 | 15 | 2 | 1,9 m | 3,2 rad/s |
| 3 | 20 | 2 | 2,2 m | 3,6 rad/s |
| 4 | 22 | 3 | 2,2 m | 3,8 rad/s |
| 5 | 26 | 4 | 2,5 m | 4,0 rad/s |

## Sinergias

- [[melhorias/poder-arcano]] aumenta o dano da Lâmina.
- O posicionamento do jogador determina quais inimigos entram na órbita e são atingidos.

## Evolução experimental: Vendaval de lâminas

Requisitos: Lâmina orbital nível 5 e Passos ligeiros nível 2.

A evolução acrescenta duas lâminas (até seis), faz o raio da órbita variar em ±0,9 m e aplica lentidão (×0,55 por 1,5 s) e empurrão a cada corte.

A evolução está implementada e testada automaticamente, mas permanece PROPOSTO_NAO_APROVADO no eixo de design até decisão do proprietário.

O visual atual usa lâminas claras, rastro e um anel fino para indicar a órbita. A aparência ainda é provisória.
