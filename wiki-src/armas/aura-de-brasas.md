---
titulo: Aura de brasas
resumo: Círculo de fogo que causa dano em pulsos aos inimigos próximos e pode evoluir em Coroa de cinzas.
estado: PUBLICADO
versao: 0.4-alpha
ordem: 20
---
A **Aura de brasas** cria uma área de fogo ao redor do personagem. Em cada pulso, todos os inimigos cujo corpo toca o círculo recebem dano. O dano é aplicado por pulso, não a cada quadro.

A arma pode ser adquirida no [[progressao/level-up|level-up]] e evoluída até o nível 5.

## Valores por nível

| Nível | Dano por pulso | Raio | Intervalo entre pulsos |
|---|---:|---:|---:|
| 1 | 6 | 2,2 m | 0,60 s |
| 2 | 7 | 2,4 m | 0,60 s |
| 3 | 9 | 2,6 m | 0,55 s |
| 4 | 11 | 2,9 m | 0,50 s |
| 5 | 14 | 3,2 m | 0,45 s |

## Sinergias

- [[melhorias/poder-arcano]] aumenta o dano da Aura.
- [[melhorias/cadencia]] acelera os pulsos.
- [[melhorias/campo-de-ruptura]] aumenta o raio da Aura em 10% por nível.

## Evolução experimental: Coroa de cinzas

Requisitos: Aura de brasas nível 5 e Cadência nível 2.

A evolução aumenta o raio da Aura em 15%. Cada pulso aplica queimadura por 3 s, causando por segundo 40% do dano do pulso.

A evolução está implementada e testada automaticamente, mas permanece PROPOSTO_NAO_APROVADO no eixo de design até decisão do proprietário.

O visual atual usa um disco com shader, borda de brasas e uma onda que se expande a cada pulso. A aparência ainda é provisória.
