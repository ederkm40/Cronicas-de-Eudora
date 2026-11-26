---
titulo: Personagem jogável
resumo: O único personagem atual, com 100 de vida e 5 m/s de velocidade.
estado: PUBLICADO
versao: 0.1-alpha
ordem: 10
---
O personagem que você controla em todas as partidas. Ainda não tem nome, classe nem visual definitivo: hoje é uma **cápsula azul** com um pequeno bloco à frente, que mostra para onde ele está virado.

## Atributos base

| Atributo | Valor | Melhorias que alteram |
|---|---|---|
| Vida máxima | 100 | [[melhorias/nucleo-vital]] (+25% por nível) |
| Velocidade de movimento | 5 m/s | [[melhorias/passos-ligeiros]] (+15% por nível) |
| Arma | [[armas/arma-automatica]] | várias |

## Comportamento

- Anda na direção do [[controles/joystick-flutuante]] ou do [[controles/teclado]], com velocidade fixa (não há meio-termo entre parado e andando).
- Vira de frente para a direção em que está andando.
- Ao receber dano, pisca em branco por um instante.
- Quando a vida chega a zero, a partida termina com a tela de derrota. Veja [[combate/dano-e-derrota]].
- Tem uma sombra simples no chão (um disco escuro), mais leve que sombra em tempo real.
