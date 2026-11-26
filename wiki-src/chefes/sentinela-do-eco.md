---
titulo: Sentinela do Eco
resumo: Chefe do encontro final, com investida, erupções, rajadas e mecânicas experimentais da 0.4-alpha.
estado: PUBLICADO
versao: 0.4-alpha
ordem: 10
---
O **Sentinela do Eco** é o chefe do encontro final. Um aviso aparece aos 9 min e 50 s; aos 10 min, o chefe surge na borda superior da área visível.

A partida não termina quando ele aparece. **A vitória só acontece quando o Sentinela é derrotado.**

## Valores e encontro

| Regra | Valor |
|---|---|
| Momento de surgimento | 10:00 |
| Vida | 3.800 |
| Dano por contato | 24 por segundo |
| Recuperação entre ataques | 1,4 s |
| Recompensa | Vitória e 40 Ecos |

Durante o encontro, o ritmo das hordas cai para 30% do ritmo normal e novos Lançadores deixam de surgir. Os que já estão em campo permanecem.

## Ataques

| Ataque | Aviso | Efeito |
|---|---|---|
| Investida | Faixa vermelha no chão por 1 s | Avança 9 m a 16 m/s; causa 28 de dano se atingir o jogador. |
| Erupção | Círculos perigosos no chão por 1,1 s | Causa 30 de dano em cada execução, se o jogador estiver em uma das áreas. |
| Rajada | Brilho lilás por 0,7 s | Dispara um anel de 14 projéteis, cada um com 12 de dano. |

## Mecânicas experimentais da 0.4-alpha

- **Janela de vulnerabilidade:** depois de cada investida, o Sentinela fica atordoado por 2 s e recebe +50% de dano. O aviso é “Ponto fraco exposto: ataque agora!”.
- **Prisão de ecos:** um anel de círculos aparece em torno do jogador, com uma única saída. O aviso dura 1,3 s; ficar sobre um círculo causa 26 de dano.
- **Ordem dos ataques:** investida, erupção, rajada e Prisão de ecos.
- Na fase 2, o primeiro reforço é um Tecelão. O escudo do Tecelão não protege o chefe.

## Fase 2

Quando a vida fica abaixo de 50%, o Sentinela entra na fase 2:

- Avisos e pausas de ataque ficam 25% mais curtos.
- A erupção passa a usar quatro áreas adicionais ao redor do jogador, em vez de duas.
- A rajada passa a ser dupla.
- Seis reforços surgem: Voláteis, Espreitadores e o primeiro Tecelão.

## Equilíbrio e validação

O piloto automático venceu as três simulações de chefe da 0.4, entre 165,7 e 263,5 segundos. Isso é um alerta de possível facilidade excessiva, não uma conclusão sobre o equilíbrio para pessoas.

As novas mecânicas do chefe estão implementadas e testadas automaticamente, mas permanecem PROPOSTO_NAO_APROVADO no eixo de design até decisão do proprietário. Não houve teste com pessoas nem em celular físico.
