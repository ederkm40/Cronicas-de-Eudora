---
titulo: Problemas conhecidos
resumo: Limitações da versão 0.3-alpha que ainda precisam de validação ou correção.
ordem: 50
---
| Problema ou limitação | Situação |
|---|---|
| Jogo ainda não testado em celular físico | Pendente de teste com pessoas e aparelhos reais. |
| Joystick depois da pausa do level-up | Se o dedo permanecer na tela durante a pausa, pode ser necessário levantar e tocar novamente. |
| Destro/canhoto e ajuste do joystick | Direção de design aprovada, mas ainda não implementada. |
| Equilíbrio do encontro com o chefe | Ajustado por simulações automáticas, sem balanceamento definitivo contra jogadores humanos. Na última simulação, o piloto automático sobreviveu ao encontro, mas não derrotou o chefe (tirou 2.457 e 3.018 dos 3.800 de vida). A vida do chefe é o primeiro número a revisar com pessoas. |
| Câmera em paisagem | Mantém aproximadamente 14 m de largura e revela pouco mapa na vertical. |
| Orbes distantes | Permanecem no chão até o jogador se aproximar; decisão sobre descarte, fusão ou atração de longe continua pendente. |
| Ponte de QA na exportação Web | A ponte de testes `WebBridge` está incluída no jogo publicado. Ela fica desligada, mas liga quando a página é aberta com `?teste=1`; nesse caso, quem abrir a página pode preparar situações (por exemplo, ganhar experiência ou chamar o chefe). Não há placar nem dado online afetado. Retirar a ponte da exportação oficial ainda não foi decidido. |
| Validação do arquivo de progressão | O save `user://progresso.json` tem versão, migração e cópia de segurança quando o JSON é inválido. Mas a estrutura interna não é toda validada: se o arquivo for um JSON válido com um campo do tipo errado (por exemplo, `estatisticas` como lista), a leitura para no meio e parte dos dados volta ao padrão, sem aviso ao jogador. Isso só acontece com um arquivo editado à mão ou danificado. |
| Desempenho no celular | O custo de CPU por quadro dobrou em relação à 0.2; o FPS em aparelhos reais ainda não foi medido. |
| Arte e áudio | Gráficos ainda provisórios e sem som final. |

O piloto automático usado nas simulações é uma ferramenta simples e não substitui observações de jogadores.
