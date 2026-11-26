# 0004: Level-up usa a pausa nativa do Godot (`SceneTree.paused`)

| | |
|---|---|
| **Situação** | Aceita |
| **Data** | 26/11/2026 |

## Contexto

A escolha de melhoria precisa congelar inimigos, projéteis, orbes, hordas e temporizadores, sem que cada sistema implemente sua própria pausa.

## Decisão

`get_tree().paused = true` ao abrir a escolha. Todos os sistemas de jogo usam o modo de processamento padrão (pausável). Só `LevelUpPanel` usa `PROCESS_MODE_ALWAYS`. A escolha abre no início do quadro seguinte à subida de nível.

## Consequências

Sistemas novos de jogo são pausáveis por padrão. Coberto por `test_pausa_e_retomada`, que confere 12 grandezas congeladas.
