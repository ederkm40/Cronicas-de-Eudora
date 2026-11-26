---
titulo: Joystick flutuante
resumo: Toque em qualquer lugar da tela e arraste para mover.
estado: PUBLICADO
versao: 0.1-alpha
ordem: 10
---
Não existe um joystick fixo na tela. **Toque em qualquer ponto livre e arraste**: o joystick aparece onde o dedo tocou e some quando você solta.

## Como funciona

| Característica | Valor |
|---|---|
| Onde aparece | em qualquer ponto da tela, menos sobre botões |
| Raio | 90 unidades de tela (cerca de 1/8 da largura) |
| Zona morta | 12% do raio (movimentos pequenos do dedo são ignorados) |
| Velocidade | fixa: fora da zona morta, o personagem anda na velocidade máxima |
| Centro que acompanha | se o dedo passar do raio, o centro do joystick é arrastado junto |

A direção é relativa à tela: arrastar **para cima** anda para o alto da tela, mesmo com a câmera isométrica.

## Pausa e derrota

Durante o [[progressao/level-up]] e depois da derrota, o joystick fica desligado.
