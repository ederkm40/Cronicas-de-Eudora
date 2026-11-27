# Catálogo 05: Passivos (melhorias da partida)

Fonte: `scripts/upgrades.gd`. As 6 melhorias: **D** `APROVADO` (0.2-alpha; sinergias ampliadas na 0.3) · **I** `IMPLEMENTADO` · **V** `TESTADO` (um teste de efeito por melhoria em `tests/suites/progressao.gd`, e sinergias com a Aura em `armas_e_ofertas.gd`). Sem teste com pessoas.

Regra comum: os níveis somam sobre a base (n níveis = 1 + taxa × n); tudo é recalculado a partir da base (decisão 0005). Uma melhoria no limite sai das ofertas.

| ID permanente | Nome | Efeito por nível | Limite | Sinergias |
|---|---|---|---|---|
| `poder_arcano` | Poder arcano | +20% de dano | 10 | todas as armas |
| `cadencia` | Cadência | +15% de velocidade | 8 | Raio (disparo) e Aura (pulso) |
| `nucleo_vital` | Núcleo vital | +25% de vida máxima e cura 25 na hora | 8 | — (peso 2,0 nas ofertas com vida abaixo de 50%) |
| `passos_ligeiros` | Passos ligeiros | +15% de velocidade de movimento | 5 | — |
| `projetil_adicional` | Projétil adicional | +1 projétil do Raio por disparo, em leque de 10° | 4 | Raio |
| `campo_de_ruptura` | Campo de ruptura | +20% de alcance do Raio e +10% de raio da Aura | 5 | Raio e Aura |

Observação de balanceamento (relatório da 0.3): Passos ligeiros e Campo de ruptura quase não foram escolhidos pelo piloto com prioridade fixa, então não há medição do valor deles.

### Implementado na 0.4-alpha (PR #10, integrada à `main` em `f51db23`)

| Id | Nome | Efeito por nível | Máximo | Afeta | D · I · V |
|---|---|---|---|---|---|
| `pacto_do_eco` | Pacto do eco | +25% de dano e +15% de XP, mas +20% de dano recebido | 3 | todas as armas; coleta de XP; o jogador | `PROPOSTO_NAO_APROVADO` (experimental) · `IMPLEMENTADO` (PR #10) · `TESTADO` |
