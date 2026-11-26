---
titulo: Desempenho
resumo: Medições das versões 0.3-alpha e 0.4-alpha e limites do que elas demonstram.
ordem: 70
---
O jogo foi projetado para suportar hordas de até **300 inimigos** de todos os tipos, além de orbes, projéteis e efeitos. O chefe é contado separadamente em algumas medições.

## Medições registradas na 0.4-alpha

Os números abaixo são tempo de CPU por quadro em simulações sem renderização. Não representam FPS de celular.

| Cenário | Média | p95 | p99 | Pior quadro |
|---|---:|---:|---:|---:|
| 0.3, 600 s, piloto padrão | 1,48 ms | 3,33 ms | 3,81 ms | 13,1 ms |
| 0.4, 600 s, piloto padrão | 1,64–1,83 ms | 3,71–4,12 ms | 5,05–5,17 ms | 54 ms* |
| 0.4, 720 s, invulnerável, armas máximas e chefe | 3,29 ms | 5,42 ms | 6,03 ms | 59 ms* |

\* O pior quadro é o primeiro, durante a geração dos 12 sons (aproximadamente 55 ms). Os sons ficam em cache e não são sintetizados novamente a cada partida.

Em relação à 0.3, o custo médio por quadro subiu aproximadamente **10% a 20%**, e o p99 cerca de **33%**. O aumento foi associado aos estados por inimigo, ao recálculo do escudo e às cores por instância.

Na simulação de 720 s, o cenário chegou a 301 inimigos contando o chefe, 400 orbes e 21 projéteis inimigos. A árvore manteve 187 nós, sem crescimento entre reinícios; a memória aumentou cerca de 13,8 MB no teste.

## Como o projeto reduz custo

- Inimigos, projéteis, orbes, lâminas e efeitos repetidos usam arrays e MultiMesh.
- A colisão utiliza uma grade espacial.
- A Aura causa dano por pulso, não a cada quadro.
- O reinício recria a cena e os sistemas da partida.
- Os sons gerados são armazenados em cache entre partidas.

## No celular

Os testes Pixel 7 são emulação em Chromium de computador. **Ainda não há medição em aparelho físico.** O rodapé do jogo exibe o contador de FPS e o número de inimigos; esses dados precisam ser observados com a horda cheia em dispositivos reais.

Relatórios e contexto: [[desenvolvimento/relatorios]].
