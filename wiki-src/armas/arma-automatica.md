---
titulo: Arma automática
resumo: Dispara sozinha no inimigo mais próximo dentro do alcance.
estado: PUBLICADO
versao: 0.1-alpha
ordem: 10
---
A arma inicial do [[personagens/personagem-jogavel]]. Você não precisa mirar nem apertar nada: ela dispara sozinha um projétil amarelo no **inimigo mais próximo** que estiver dentro do alcance. Se não houver nenhum inimigo no alcance, ela espera e dispara assim que um aparecer.

## Valores base

| Atributo | Valor | Melhoria |
|---|---|---|
| Dano por projétil | 10 | [[melhorias/poder-arcano]] +20% por nível |
| Intervalo entre disparos | 0,45 s (cerca de 2,2 disparos por segundo) | [[melhorias/cadencia]] +15% de velocidade por nível |
| Alcance de mira | 11 m | [[melhorias/campo-de-ruptura]] +20% por nível |
| Projéteis por disparo | 1 | [[melhorias/projetil-adicional]] +1 por nível |
| Velocidade do projétil | 14 m/s | — |
| Duração do projétil | 1,2 s (cresce junto com o alcance) | [[melhorias/campo-de-ruptura]] |
| Raio de acerto | 0,55 m | — |
| Abertura do leque | 10° entre projéteis | — |

## Detalhes

- Cada projétil acerta **um** inimigo e some.
- Com mais de um projétil por disparo, eles saem em leque, centrados no alvo.
- O alvo é escolhido no momento do disparo. O projétil segue em linha reta e não persegue o alvo.
- Limite técnico: 256 projéteis ao mesmo tempo na tela.
