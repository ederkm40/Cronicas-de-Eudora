---
titulo: Arsenal
resumo: Como as armas são adquiridas, ocupam espaços e evoluem durante a partida.
estado: PUBLICADO
versao: 0.3-alpha
ordem: 10
---
O arsenal separa a definição das armas, o estado do jogador e a execução de cada ataque. Isso permite que cada arma tenha comportamento e visual próprios.

## Espaços

- O arsenal comporta até **quatro espaços**.
- O [[armas/arma-automatica|Raio arcano]] é a arma inicial.
- [[armas/aura-de-brasas|Aura de brasas]] e [[armas/lamina-orbital|Lâmina orbital]] podem ser adquiridas durante a partida.
- Cada uma das duas armas adicionais pode evoluir até o nível 5.
- O Raio arcano é modificado pelas melhorias passivas, sem níveis próprios no catálogo atual.

## Aquisição e evolução

No [[progressao/level-up|level-up]], uma oferta de arma pode ser:

- **Nova arma:** ocupa um espaço livre.
- **Evolução:** aumenta o nível de uma arma já adquirida.
- **Melhoria:** aumenta uma melhoria passiva.

Não há duplicatas na mesma tela e armas no nível máximo deixam de ser elegíveis. O sorteio mostra apenas opções válidas; se houver menos de três opções, mostra menos cartões em vez de inventar uma oferta.

A arquitetura técnica usa `WeaponCatalog` para definições, `Arsenal` para o estado e um nó de execução por arma.
