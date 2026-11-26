---
titulo: Testes
resumo: Como a versão 0.3-alpha é validada e quais resultados foram registrados no PR #5.
ordem: 40
---
O projeto utiliza testes automáticos no GitHub Actions antes de exportar o jogo e atualizar o site. Os resultados abaixo são os registrados durante a entrega da 0.3-alpha, não uma nova execução desta atualização editorial.

## Testes do Godot

A 0.3-alpha registrou **41 testes em quatro suítes e 4.370 verificações**:

| Suíte | Cobertura |
|---|---|
| `progressao.gd` | XP, coleta, level-up, melhorias, limites, pausa, derrota e reinício |
| `armas_e_ofertas.gd` | Arsenal, Aura, Lâmina, níveis, ofertas, troca e bloqueio |
| `inimigos_e_chefe.gd` | Mistura por tempo, comportamentos, avisos, chefe, fases e vitória |
| `esquiva_e_encerramento.gd` | Esquiva, invulnerabilidade, resultados, reinício e progressão permanente |

Também foram registrados:

- `tests/smoke_test.gd`: teste de ponta a ponta.
- `tests/long_simulation.gd`: simulação prolongada de 300 s.
- `tests/balance_simulation.gd`: simulações de armas, partidas e encontro final. Não é executada no CI.

## CI e navegador

No PR #5, o relatório registrou:

| Verificação | Resultado informado |
|---|---|
| `gdlint` | Sem problemas |
| `gdformat --check` | Arquivos GDScript alterados formatados |
| Testes do Godot | 41 testes, 4.370 verificações, zero falhas |
| Smoke test | Aprovado |
| Simulação prolongada | Aprovada |
| Testes da Wiki e montagem do site | 14 e 7 testes aprovados |
| Playwright | 18 aprovados e 3 pulados por desenho, nos três perfis |

Os testes Playwright abrem o jogo exportado e verificam joystick, esquiva, teclado, level-up, vitória, derrota e reinício.

## Limite importante

Os perfis de Pixel 7 são emulação de tela e toque em Chromium de computador. **Não equivalem a teste em celular físico.** O desempenho de CPU medido sem renderização também não representa FPS real em um aparelho.

Consulte [[desenvolvimento/relatorios|os relatórios por versão]] para os detalhes e as condições de cada medição.


## Manutenção pós-0.3-alpha (PR #7)

A etapa de manutenção ampliou a cobertura para **51 testes em cinco suítes, com 4.482 verificações e zero falhas**. Esses números são os registrados no CI e no relatório do PR #7, não uma execução feita durante esta atualização editorial.

| Verificação | Resultado registrado |
|---|---|
| Testes do Godot | 51 testes, 4.482 verificações, 0 falhas |
| Conferência ao contrário (save e joystick) | 5 testes falham quando as correções são removidas |
| Smoke test | Aprovado |
| Simulação prolongada de 300 s | Aprovada |
| Wiki / montagem do site | 14 / 7 testes aprovados |
| Verificação das builds | Produção: 0 referências à ponte de QA; QA: 3 |
| Playwright na build Web QA, 3 perfis | 21 aprovados, 3 pulados por desenho |
| Playwright na build de produção, 3 perfis | 11 aprovados, 1 pulado por desenho |

A build de produção é a única publicada. A build Web QA, que contém a ponte usada pelos testes de jogabilidade, é restrita ao CI. Os três perfis de navegador incluem desktop e emulações de Pixel 7 em retrato e paisagem. **A emulação não substitui testes em aparelhos físicos**, que continuam pendentes.

Relatório técnico: `docs/versoes/manutencao-pos-0.3/RELATORIO.md`. Pull Request: [#7](https://github.com/ederkm40/Cronicas-de-Eudora/pull/7).
