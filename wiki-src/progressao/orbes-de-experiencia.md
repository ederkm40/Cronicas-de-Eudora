---
titulo: Orbes de experiência
resumo: Cristais azul-claros deixados pelos inimigos; voam até o personagem quando ele chega perto.
estado: PUBLICADO
versao: 0.2-alpha
ordem: 20
---
Cada inimigo derrotado deixa um **orbe de experiência** no lugar onde morreu. Hoje ele aparece como um pequeno cristal azul-claro flutuando, uma arte provisória.

## Coleta por proximidade

| Etapa | Distância do personagem | O que acontece |
|---|---|---|
| Parado | mais de 3 m | o orbe fica no chão, esperando |
| Ímã | até 3 m | o orbe voa até o personagem, cada vez mais rápido |
| Coleta | até 0,6 m | o orbe some e a XP entra na [[progressao/experiencia\|barra]] |

Não é preciso tocar em nada: basta passar perto.

## Detalhes

- Orbes **não somem com o tempo**. Os que caíram longe continuam lá até você passar perto.
- Limite de 400 orbes no chão. Acima disso, o valor do orbe novo é **somado ao orbe mais antigo**, então nenhuma experiência se perde.
- Os orbes param durante o [[progressao/level-up]] e depois da derrota.
