---
titulo: Raio arcano
resumo: Arma inicial que dispara projéteis automaticamente no alvo mais próximo e pode evoluir em Raio em cadeia.
estado: PUBLICADO
versao: 0.4-alpha
ordem: 10
---
O **Raio arcano** é a arma inicial. Dispara sozinho contra o inimigo mais próximo dentro do alcance. Quando o Sentinela do Eco está ao alcance, o Raio prioriza o chefe.

Não é necessário mirar nem apertar um botão de ataque. Na 0.4-alpha, o acerto também aplica um pequeno empurrão.

## Valores base

| Atributo | Valor | Melhoria relacionada |
|---|---:|---|
| Dano por projétil | 10 | [[melhorias/poder-arcano]] |
| Intervalo entre disparos | 0,45 s | [[melhorias/cadencia]] |
| Alcance de mira | 11 m | [[melhorias/campo-de-ruptura]] |
| Projéteis por disparo | 1 | [[melhorias/projetil-adicional]] |
| Velocidade do projétil | 14 m/s | — |
| Duração do projétil | 1,2 s | aumenta com o alcance |
| Raio de acerto | 0,55 m | — |
| Abertura do leque | 10° entre projéteis | com projéteis adicionais |
| Empurrão | 1,2 m/s | 0.4-alpha |

Cada projétil acerta um inimigo e desaparece. O alvo é escolhido no momento do disparo; o projétil segue em linha reta, sem persegui-lo.

## Evolução experimental: Raio em cadeia

Requisitos: Raio arcano, Projétil adicional nível 2 e Poder arcano nível 3.

Cada acerto salta para os dois inimigos próximos mais próximos, a até 4 m, causando 60% do dano. Se o alvo inicial estava queimando, o salto alcança três inimigos e recebe +25% de dano.

A evolução é implementada e testada automaticamente, mas permanece PROPOSTO_NAO_APROVADO no eixo de design até decisão do proprietário.

## Sinergias

- [[melhorias/poder-arcano]] aumenta o dano de todas as armas.
- [[melhorias/cadencia]] aumenta a velocidade de disparo do Raio.
- [[melhorias/projetil-adicional]] acrescenta projéteis em leque.
- [[melhorias/campo-de-ruptura]] aumenta o alcance de mira e a duração do projétil.
