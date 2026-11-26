---
titulo: Problemas conhecidos
resumo: Limitações da versão 0.4-alpha que ainda precisam de observação, correção ou validação.
ordem: 50
---
| Problema ou limitação | Situação |
|---|---|
| Jogo ainda não testado em celular físico nem por pessoas | Pendente. O proprietário adiou a rodada de 5 a 10 jogadores até o jogo avançar mais. |
| Equilíbrio da Sentinela do Eco | O piloto automático venceu 3 de 3 simulações na 0.4, em 165,7 a 263,5 s. É um alerta de possível facilidade excessiva, não uma conclusão sobre a experiência humana. |
| Fenda do Eco | O piloto automático não entra na área; o valor real da recompensa e o risco de permanecer nela ainda não foram medidos. |
| Som procedural | Os 12 efeitos são gerados pelo código e passaram por testes técnicos, mas não foram ouvidos nem avaliados por uma pessoa. São provisórios. |
| Botão de pausa e áreas seguras | Não foi conferido em aparelhos físicos com entalhes, recortes de câmera ou bordas arredondadas. |
| Desempenho em celulares | No servidor de testes, o custo médio por quadro subiu aproximadamente 10% a 20% e o p99 cerca de 33% em relação à 0.3. O FPS real em celular não foi medido. |
| Primeiro quadro de áudio | A geração inicial dos sons pode provocar um quadro de cerca de 55 ms; ocorre uma vez e os sons ficam em cache entre partidas. |
| Atração do eco | O texto ainda diz “raio de coleta”, mas o efeito real altera o raio do ímã. |
| Orbes distantes | Permanecem no chão até o jogador se aproximar; não há atração global. |
| Arte e áudio finais | Os efeitos visuais e sonoros ainda são provisórios; não há pacote audiovisual final. |
| Organização do EnemyManager | O relatório da 0.4 registra 20 métodos públicos e 890 linhas; acompanhar a manutenção da responsabilidade do gerenciador. |

A retomada do joystick após o level-up e as configurações mobile passaram por testes automatizados em Godot e Chromium emulado. Isso não confirma o comportamento em aparelhos físicos.

O piloto automático usado nas simulações é uma ferramenta simples e não substitui observações de jogadores.
