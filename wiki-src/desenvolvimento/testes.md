---
titulo: Testes
resumo: Como o jogo é testado e os resultados registrados.
ordem: 40
---
Todo envio de código passa por testes automáticos no GitHub Actions **antes** de o jogo ser exportado e publicado. Se algum teste falhar, nada é publicado.

| Teste | O que verifica |
|---|---|
| `tests/run_tests.gd` | 16 testes da progressão: XP ao derrotar, coleta por proximidade, acúmulo, subida de nível, vários níveis de uma vez, 3 opções diferentes, cada uma das 6 melhorias medida dentro da partida, limites, pausa e retomada, bloqueio após a derrota, reinício limpo |
| `tests/smoke_test.gd` | 60 s de partida de ponta a ponta: toque e arraste no joystick, tecla D, coleta, escolhas de melhoria |
| `tests/long_simulation.gd` | Partida longa (5 min no GitHub, 10 min nos testes manuais), com mortes e reinícios, medindo desempenho e memória |
| `tools/wiki/test_wiki.py` | A Wiki é gerada sem erros, os links funcionam, a busca encontra artigos, o resultado é sempre o mesmo |
| `tools/site/test_montar_site.py` | A montagem do site preserva o jogo oficial ao publicar prévias e remove prévias fechadas |

## Últimos resultados registrados

| Versão | Resultado | Onde está |
|---|---|---|
| 0.2-alpha | Todos os testes passaram (16 testes e 1.627 verificações; smoke test; simulação de 10 min com 4 reinícios) | [[desenvolvimento/relatorios/0.2-alpha\|relatório 0.2-alpha]] |

> O jogo **ainda não foi testado num celular físico** pela equipe de desenvolvimento. Até aqui, os testes visuais foram feitos num Chrome com tela e toque de celular simulados.
