---
titulo: Level-up
resumo: Ao subir de nível, a partida pausa e você escolhe entre armas novas, evoluções ou melhorias.
estado: PUBLICADO
versao: 0.2-alpha
ordem: 30
---
Quando a barra de [[progressao/experiencia|experiência]] enche, a partida pausa e abre o painel de level-up.

## Como funciona

1. Inimigos, projéteis, orbes, surgimento das hordas e relógio param.
2. Aparecem até três ofertas válidas.
3. Você escolhe uma oferta, troca as opções ou bloqueia um cartão.
4. A escolha é aplicada e a partida continua.

## Tipos de oferta

- **Nova arma:** adquire uma arma que ainda não está no arsenal, se houver espaço.
- **Evolução de arma:** aumenta o nível de uma arma adquirida.
- **Melhoria:** aumenta uma das seis melhorias passivas.

As opções são diferentes entre si. Armas no nível máximo e melhorias no limite deixam de aparecer. Se houver menos de três opções válidas, o jogo mostra apenas as que existem.

## Trocar e bloquear

| Ação | Limite base por partida | Efeito |
|---|---:|---|
| Trocar opções | 2 | Sorteia novas opções, evitando repetir as atuais quando houver alternativas. |
| Bloquear | 2 | Remove uma oferta da partida inteira e coloca outra no cartão. |

Trocar e bloquear são recursos independentes. A melhoria permanente [[progressao/melhorias-permanentes|Renovação]] aumenta a quantidade de trocas.

## Cura e fim das opções

Cada nível ganho recupera **12% da vida máxima**. Se não houver nenhuma oferta válida, o nível é consumido e o personagem recupera 25 de vida sem abrir o painel.

Se vários níveis forem ganhos de uma vez, as escolhas aparecem uma após a outra.

A partida volta a funcionar depois da escolha. Há uma limitação conhecida no joystick quando o dedo permanece pressionando a tela durante a pausa; veja [[desenvolvimento/problemas-conhecidos]].
