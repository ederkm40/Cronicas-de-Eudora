---
titulo: Inimigo comum
resumo: Anda em direção ao personagem e causa dano ao encostar. Fica mais resistente com o tempo.
estado: PUBLICADO
versao: 0.1-alpha
ordem: 10
---
O único inimigo atual, representado por uma **cápsula vermelha** provisória. Ele surge fora da tela e anda direto na direção do [[personagens/personagem-jogavel]].

## Valores

| Atributo | Valor |
|---|---|
| Vida no início da partida | 20 |
| Aumento de vida | +60% da vida base por minuto de partida |
| Velocidade | 2,2 m/s, com variação de ±15% entre inimigos |
| Dano por contato | 9 por segundo, enquanto estiver a menos de 0,8 m do personagem |
| Experiência ao morrer | 1 (um [[progressao/orbes-de-experiencia\|orbe]]) |

### Vida ao longo da partida

| Tempo de partida | Vida de um inimigo novo |
|---|---|
| 0 min | 20 |
| 1 min | 32 |
| 5 min | 80 |
| 10 min | 140 |

## Comportamento

- Os inimigos se empurram de leve para não ficarem todos no mesmo ponto.
- Um inimigo que fica longe demais do personagem reaparece do outro lado, fora da tela.
- Como surgem as hordas: veja [[combate/hordas]].
