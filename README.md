# Crônicas de Eudora

Jogo de hordas isométrico para celular: partidas curtas no estilo *survivors*, com a progressão de personagem e loot de um ARPG. Feito em **Godot 4.7**, quase todo construído por IA.

**Jogar no navegador (celular ou PC):** https://ederkm40.github.io/Cronicas-de-Eudora/

O link é atualizado sozinho alguns minutos depois de cada mudança no branch `main`.

## Estado atual: projeto base do protótipo

- Tela em retrato (720 x 1280), câmera isométrica ortográfica fixa.
- Joystick flutuante: toque em qualquer ponto da tela e arraste. No PC, também dá para usar WASD ou as setas.
- Arma automática que atira no inimigo mais próximo.
- Hordas que aumentam com o tempo (até 300 inimigos), com vida crescente.
- Tela de derrota com "Jogar de novo".
- Contador de FPS e de inimigos no rodapé, para acompanhar o desempenho.

A arte é provisória (cápsulas): o objetivo agora é testar se o movimento e a sobrevivência são divertidos no celular.

## Como o projeto funciona

Tudo é texto: cenas, scripts e configurações. A partida é montada em código, em `scripts/main.gd`, para que a IA consiga ler e editar tudo sem abrir o editor do Godot.

| Arquivo | O que faz |
| --- | --- |
| `scripts/main.gd` | Monta a partida: ambiente, chão, jogador, câmera, inimigos, arma e interface |
| `scripts/floating_joystick.gd` | Joystick flutuante (raio, zona morta, centro que acompanha o dedo) |
| `scripts/camera_rig.gd` | Câmera isométrica e conversão da direção da tela para o chão |
| `scripts/player.gd` | Movimento, vida e dano do jogador |
| `scripts/enemy_manager.gd` | Todos os inimigos em arrays + um único MultiMesh (rápido no celular) |
| `scripts/auto_weapon.gd` | Arma automática e projéteis |
| `scripts/hud.gd` | Tempo, abates, barra de vida, FPS e tela de derrota |
| `tests/smoke_test.gd` | Teste sem tela que simula um toque no joystick e uma partida |
| `.github/workflows/web.yml` | Compila, testa e publica no GitHub Pages a cada envio |

Os valores de ajuste (velocidade, vida, dano, raio do joystick, ângulo da câmera) ficam no topo de cada script, marcados com `@export`.

## Rodar localmente (opcional)

```bash
godot --headless --path . --import
godot --headless --path . --fixed-fps 60 --script res://tests/smoke_test.gd
godot --headless --path . --export-release "Web" build/web/index.html
```
