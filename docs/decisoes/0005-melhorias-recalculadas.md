# 0005: Melhorias recalculadas a partir dos valores base

| | |
|---|---|
| **Situação** | Aceita |
| **Data** | 26/11/2026 |

## Contexto

Aplicar multiplicadores um sobre o outro acumula erro e torna difícil saber o valor real.

## Decisão

`Upgrades` guarda só o número de níveis de cada melhoria. `Upgrades.refresh()` recalcula todos os modificadores a partir dos valores base (`1 + bônus × níveis`). Os bônus se somam, sem se multiplicar entre si.

## Consequências

Uma melhoria nova entra em `DEFINITIONS`, `describe_next()` e `refresh()`, e ganha um teste de efeito.
