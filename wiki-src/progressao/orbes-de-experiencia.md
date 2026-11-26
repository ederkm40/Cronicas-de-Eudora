---
titulo: Orbes de experiência
resumo: Cristais de experiência deixados pelos inimigos derrotados e coletados por proximidade.
estado: PUBLICADO
versao: 0.2-alpha
ordem: 20
---
Cada inimigo derrotado deixa um **orbe de experiência** no lugar onde morreu. O visual atual é um pequeno cristal azul-claro flutuando.

## Coleta por proximidade

| Etapa | Distância | O que acontece |
|---|---:|---|
| Parado | Mais de 3 m | O orbe fica no chão. |
| Ímã | Até 3 m | O orbe voa em direção ao personagem. |
| Coleta | Até 0,6 m | O orbe desaparece e a XP entra na barra. |

Não é preciso tocar no orbe: basta passar perto. A melhoria permanente [[progressao/melhorias-permanentes|Atração do eco]] aumenta o raio do ímã em 20% por nível (a coleta final continua a 0,6 m).

## Limites

- Orbes não somem com o tempo.
- O limite é de 400 orbes no chão.
- Acima do limite, o valor do novo orbe é somado ao orbe mais antigo, sem perda de experiência.
- Os orbes param durante o [[progressao/level-up|level-up]] e depois do encerramento da partida.
