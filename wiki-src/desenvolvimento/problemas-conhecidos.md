---
titulo: Problemas conhecidos
resumo: Limitações da versão 0.3-alpha que ainda precisam de validação ou correção.
ordem: 50
---
| Problema ou limitação | Situação |
|---|---|
| Jogo ainda não testado em celular físico | Pendente de teste com pessoas e aparelhos reais. |
| Destro/canhoto e ajuste do joystick | Direção de design aprovada, mas ainda não implementada. |
| Equilíbrio do encontro com o chefe | Ajustado por simulações automáticas, sem balanceamento definitivo contra jogadores humanos. Na última simulação, o piloto automático sobreviveu ao encontro, mas não derrotou o chefe (tirou 2.457 e 3.018 dos 3.800 de vida). A vida do chefe é o primeiro número a revisar com pessoas. |
| Câmera em paisagem | Mantém aproximadamente 14 m de largura e revela pouco mapa na vertical. |
| Orbes distantes | Permanecem no chão até o jogador se aproximar; decisão sobre descarte, fusão ou atração de longe continua pendente. |
| Desempenho no celular | O custo de CPU por quadro dobrou em relação à 0.2; o FPS em aparelhos reais ainda não foi medido. |
| Arte e áudio | Gráficos ainda provisórios e sem som final. |

A retomada do joystick após o level-up foi corrigida e testada no Godot e no Chromium emulado, mas ainda precisa de confirmação em celulares físicos. A ponte de QA foi removida da build de produção; a build com ferramentas de QA existe apenas no CI. O save agora valida estrutura e tipos, preserva cópia de estruturas/campos inválidos e não sobrescreve arquivos de versão futura.

O piloto automático usado nas simulações é uma ferramenta simples e não substitui observações de jogadores.
