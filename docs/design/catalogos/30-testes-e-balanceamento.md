# Catálogo 30: Testes e balanceamento

Lista dos testes que existem e dos números medidos. Os resultados históricos da 0.3-alpha estão em `docs/versoes/0.3-alpha/RELATORIO.md`; os desta manutenção, em `docs/versoes/manutencao-pos-0.3/RELATORIO.md`.

## Testes

| ID | O que cobre | Comando | Critério | Situação |
|---|---|---|---|---|
| `godot_suites` | 51 testes em 5 suítes: progressão, armas e ofertas, inimigos e chefe, esquiva e encerramento, save e joystick | `godot --headless --path . --fixed-fps 60 --script res://tests/run_tests.gd` | `TESTES: OK` | `TESTADO` no CI |
| `smoke` | 60 s de partida de ponta a ponta | `.../tests/smoke_test.gd` | `SMOKE TEST: OK` | `TESTADO` |
| `simulacao_longa` | desempenho, memória, nós e reinícios | `.../tests/long_simulation.gd -- --segundos=300` | `SIMULAÇÃO LONGA: OK` | `TESTADO` |
| `balanceamento` | dano por arma, partida com piloto, encontro final | `.../tests/balance_simulation.gd -- --modo=dps\|partida\|chefe` | relatório (não reprova por equilíbrio) | rodado manualmente |
| `navegador_qa` | jogo exportado (build QA) em 3 perfis, com controles reais | `xvfb-run -a npx playwright test` (`E2E_MODO=qa`) | todos aprovados | `TESTADO` (emulação) |
| `navegador_producao` | build publicada sem ponte de testes, com e sem `?teste=1` | idem com `E2E_MODO=producao` | todos aprovados | `TESTADO` (emulação) |
| `producao_sem_ponte` | o `.pck` de produção não contém `scripts/web_bridge` | `tools/ci/verificar_producao.sh` | `OK` | `TESTADO` |
| `celular_fisico` | aparelho real | — | — | `NÃO_TESTADO` |
| `pessoas` | 5 a 10 pessoas (roadmap) | — | — | `NÃO_TESTADO` |

## Balanceamento medido (simulação, 0.3-alpha)

Dano por segundo contra a horda dos 240 s, sem passivas, 60 s por carga: Raio sozinho 18/s; com Aura 1 / 3 / 5: Aura 36 / 59 / 126 por segundo; com Lâmina 1 / 3 / 5: Lâmina 27 / 61 / 157 por segundo. Partidas do piloto automático: derrotas entre 8:30 e 12:37 em 6 partidas. Encontro final: 1 vitória em 140 s; depois do último ajuste, 0 vitórias em 2 tentativas. **Nenhum desses números foi validado com pessoas.**
