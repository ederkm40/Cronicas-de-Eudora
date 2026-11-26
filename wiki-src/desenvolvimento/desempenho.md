---
titulo: Desempenho
resumo: Medições registradas e como acompanhar o FPS no celular.
ordem: 70
---
O jogo foi feito para rodar no navegador do celular com **até 300 inimigos** na tela.

## Medições registradas (0.2-alpha)

Feitas na simulação automática de 10 minutos, com a horda cheia de 300 inimigos, **no processador de um servidor e sem desenhar a tela**:

| Medida | Resultado |
|---|---|
| Tempo de processamento por quadro: média | 1,3 ms |
| 99% dos quadros abaixo de | 2,2 ms |
| Objetos na cena | constantes, inclusive depois de reiniciar |
| Memória | estável, sem crescimento contínuo |

Esses números **não representam um celular**. No navegador do celular, o jogo roda mais devagar e a placa de vídeo é mais fraca.

## No seu celular

O rodapé do jogo mostra **FPS** (quadros por segundo) e o número de **inimigos**. A meta é ficar estável em 30 FPS ou mais com a horda cheia. Para ajudar no desenvolvimento, anote o FPS quando a tela estiver lotada.
