---
titulo: Arsenal
resumo: Como as armas são adquiridas, ocupam espaços e evoluem durante a partida.
estado: PUBLICADO
versao: 0.4-alpha
ordem: 10
---
O arsenal separa a definição das armas, o estado do jogador e a execução de cada ataque. Isso permite que cada arma tenha comportamento e visual próprios.

## Espaços

- O arsenal comporta até **quatro espaços**.
- O [[armas/arma-automatica|Raio arcano]] é a arma inicial.
- [[armas/aura-de-brasas|Aura de brasas]] e [[armas/lamina-orbital|Lâmina orbital]] podem ser adquiridas durante a partida.
- Cada arma pode alcançar uma evolução experimental quando seus requisitos são cumpridos.

## Aquisição e evolução

No [[progressao/level-up|level-up]], uma oferta pode ser:

- **Nova arma:** ocupa um espaço livre.
- **Evolução:** transforma uma arma quando os níveis exigidos de arma e passivas são alcançados.
- **Melhoria:** aumenta uma melhoria passiva.

Na 0.4-alpha, as três evoluções são **Raio em cadeia**, **Coroa de cinzas** e **Vendaval de lâminas**. Elas aparecem como cartas douradas e cada arma evolui uma vez.

As evoluções são implementadas e testadas automaticamente, mas continuam PROPOSTO_NAO_APROVADO no eixo de design até decisão do proprietário.

Não há duplicatas na mesma tela e armas no nível máximo deixam de ser elegíveis. O sorteio mostra apenas opções válidas; se houver menos de três opções, mostra menos cartões em vez de inventar uma oferta.

A arquitetura técnica usa WeaponCatalog para definições, Arsenal para o estado e um nó de execução por arma.
