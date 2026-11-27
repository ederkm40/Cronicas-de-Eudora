---
titulo: Testes
resumo: Testes automatizados registrados nas versões 0.3-alpha e 0.4-alpha; validação humana ainda pendente.
ordem: 40
---
O projeto utiliza testes automáticos no GitHub Actions antes de exportar o jogo e atualizar o site. Os resultados abaixo são os registrados em cada entrega, não uma nova execução desta atualização editorial.

## Manutenção pós-0.4-alpha — PR #12

A manutenção registrou **73 testes em seis suítes, 4.624 verificações e zero falhas**. Foram acrescentados dois testes: desenho dos inimigos por tipo/geometria da tela e texto/efeito do ímã da Atração do eco.

| Verificação | Resultado registrado |
|---|---|
| gdlint scripts tests | Sem problemas |
| gdformat --check | Sem alterações pendentes nos arquivos alterados |
| Testes do Godot | 73 testes, 4.624 verificações, 0 falhas |
| Smoke test | Aprovado |
| Simulação longa | 300 s, aprovada |
| Wiki / montagem do site | Aprovados |
| Playwright no CI | QA: 24 aprovados, 3 pulados; produção: 11 aprovados, 1 pulado, nos três perfis |

A comparação de uma simulação de 300 s entre main e a branch produziu partidas idênticas. As medições de CPU por quadro ficaram dentro da variação normal do servidor, sem ganho ou perda identificável. Os perfis móveis do Playwright são emulações no Chromium, não aparelhos físicos.

Relatório: [manutenção pós-0.4-alpha](https://github.com/ederkm40/Cronicas-de-Eudora/blob/main/docs/versoes/manutencao-pos-0.4/RELATORIO.md) · [PR #12](https://github.com/ederkm40/Cronicas-de-Eudora/pull/12).

## 0.4-alpha — PR #10

### Godot e simulações

A 0.4-alpha registrou **71 testes em seis suítes, 4.613 verificações e zero falhas**. A nova suíte despertar.gd acrescentou 20 testes, cobrindo evoluções, Pacto do Eco, elites, Tecelão, Semeador, chefe, Fenda, Maré, configurações mobile, canhoto, joystick fixo, pausa, sons e números de dano.

| Verificação | Resultado registrado |
|---|---|
| gdlint | Sem problemas no CI |
| gdformat --check | 34 arquivos sem alterações de formatação |
| Testes do Godot | 71 testes, 4.613 verificações, 0 falhas |
| Smoke test | Aprovado; elite, Fenda, pausa, sons e estouros forçados |
| Simulação prolongada no CI | 300 s, aprovada |
| Simulações locais prolongadas | 600 s e 720 s no cenário invulnerável com armas máximas; nós constantes e memória estável |
| Wiki / montagem do site | Testes aprovados |
| Build de produção | Sem ponte de QA; QA permanece restrita aos testes |

### Navegador

| Build | Resultado registrado |
|---|---|
| QA, computador, celular em pé e deitado | 24 aprovados, 3 pulados por desenho |
| Produção, computador, celular em pé e deitado | 11 aprovados, 1 pulado por desenho |

Os perfis de celular são emulações de tela e toque no Chromium de computador. Não equivalem a aparelhos físicos.

### Balanceamento e desempenho

As simulações de balanceamento são instrumentos automáticos, não jogadores humanos:

- O piloto automático venceu a Sentinela nas 3 sementes do encontro final, levando de 165,7 a 263,5 segundos. Isso sugere que o chefe pode ter ficado fácil demais.
- O piloto não entra na Fenda do Eco; portanto, o valor real da recompensa não foi medido.
- O custo médio de CPU por quadro subiu aproximadamente 10% a 20% e o p99 cerca de 33% em relação à 0.3, no mesmo servidor de testes.
- O primeiro quadro pode chegar a aproximadamente 55 ms pela geração dos sons. Os sons ficam em cache e não são sintetizados novamente a cada partida.
- **O FPS em celular físico não foi medido.**

Relatório técnico: [0.4-alpha — O Despertar de Eudora](https://github.com/ederkm40/Cronicas-de-Eudora/blob/main/docs/versoes/0.4-alpha/RELATORIO.md). Workflow de integração: [GitHub Actions #45902410165](https://github.com/ederkm40/Cronicas-de-Eudora/actions/runs/45902410165).

## Manutenção pós-0.3-alpha (PR #7)

A etapa de manutenção registrou **51 testes em cinco suítes, 4.482 verificações e zero falhas**.

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

## 0.3-alpha

A 0.3-alpha registrou **41 testes em quatro suítes e 4.370 verificações**.

| Suíte | Cobertura |
|---|---|
| progressao.gd | XP, coleta, level-up, melhorias, limites, pausa, derrota e reinício |
| armas_e_ofertas.gd | Arsenal, Aura, Lâmina, níveis, ofertas, troca e bloqueio |
| inimigos_e_chefe.gd | Mistura por tempo, comportamentos, avisos, chefe, fases e vitória |
| esquiva_e_encerramento.gd | Esquiva, invulnerabilidade, resultados, reinício e progressão permanente |

## Limite da validação

**Ainda não houve teste com pessoas nem em celular físico.** A validação com 5 a 10 jogadores foi adiada pelo proprietário para depois de mais evolução do jogo. Os testes automatizados continuam necessários, mas não provam conforto de uso, diversão ou equilíbrio para pessoas.
