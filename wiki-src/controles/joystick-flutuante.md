---
titulo: Joystick flutuante
resumo: Toque em qualquer lugar livre da tela e arraste para mover o personagem.
estado: PUBLICADO
versao: 0.1-alpha
ordem: 10
---
Não existe um joystick fixo na tela. **Toque em um ponto livre e arraste**: o joystick aparece onde o dedo tocou e some quando você solta.

## Como funciona

| Característica | Valor |
|---|---|
| Onde aparece | Em qualquer ponto livre da tela |
| Raio | 90 unidades de tela (base de 720 px de largura) |
| Zona morta | 12% do raio |
| Velocidade | Fixa fora da zona morta |
| Centro que acompanha | Sim, quando o dedo passa do raio |

A direção é relativa à tela: arrastar para cima move o personagem para o alto da tela, mesmo com a câmera isométrica.

## Esquiva

Dois toques curtos e próximos podem ativar a [[controles/esquiva|esquiva]]. Um arrasto rápido no segundo toque também pode definir a direção.

## Pausa

Durante o [[progressao/level-up|level-up]], o joystick fica desabilitado. Há uma limitação conhecida: se o dedo continuar pressionando a tela durante a pausa, o controle pode só voltar depois que o dedo for levantado e um novo toque começar. Essa limitação ainda não foi corrigida na versão 0.3-alpha.
