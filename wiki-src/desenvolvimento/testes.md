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
