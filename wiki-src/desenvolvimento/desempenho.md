---
titulo: Desempenho
resumo: Medições da versão 0.3-alpha e limites do que elas demonstram.
ordem: 70
---
O jogo foi projetado para suportar hordas de até **300 inimigos** (de todos os tipos; o chefe fica fora desse limite), além de orbes, projéteis e efeitos.

## Medições registradas na 0.3-alpha

Os números abaixo são tempo de CPU por quadro em simulações sem renderização. Não representam FPS de celular.

| Cenário | Média | p95 | p99 | Pior quadro |
|---|---:|---:|---:|---:|
| 0.2 (referência), 300 s, piloto padrão | 0,57 ms | 1,43 ms | 2,00 ms | 12,3 ms |
| 0.3, 300 s, piloto padrão | 1,30 ms | 3,30 ms | 3,61 ms | 13,9 ms |
| 0.3, 660 s, armas no máximo e chefe | 3,01 ms | 4,40 ms | 5,67 ms | 17,5 ms |

As duas primeiras linhas rodaram na mesma máquina, em sequência: o custo por quadro da 0.3 **mais que dobrou** em relação à 0.2, por causa do comportamento por tipo de inimigo, da cor por instância e dos seis MultiMesh de inimigos. No CI (`ubuntu-latest`), a simulação de 300 s da 0.3 registrou média de 2,17 ms e p99 de 5,80 ms.

No pior caso medido, a simulação alcançou 301 entidades inimigas contando o chefe, 400 orbes e 39 projéteis inimigos. A memória aumentou cerca de 8,4 MB em 11 minutos, sem crescimento contínuo observado no teste.

## Como o projeto reduz custo

- Inimigos, projéteis, orbes, lâminas e efeitos repetidos usam arrays e MultiMesh.
- A colisão utiliza uma grade espacial.
- A Aura causa dano por pulso, não a cada quadro.
- O reinício recria a cena e os sistemas da partida.

## No celular

Os testes Pixel 7 são emulação em Chromium de computador. **Ainda não há medição em aparelho físico.** O rodapé do jogo exibe o contador de FPS e o número de inimigos; esses dados precisam ser observados com a horda cheia em dispositivos reais.

Relatórios e contexto: [[desenvolvimento/relatorios]].
