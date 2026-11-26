# 0002: Projeto 100% em texto, com a partida montada em código

| | |
|---|---|
| **Situação** | Aceita |
| **Data** | 25/11/2026 |

## Contexto

IAs editam bem arquivos de texto, mas mal arquivos binários ou cenas complexas com IDs internos. Ninguém abre o editor do Godot.

## Decisão

`scenes/main.tscn` contém um único nó com `scripts/main.gd`, que cria todos os sistemas em código. Cada sistema é uma classe (`class_name`). Os valores de ajuste ficam em `@export`.

## Consequências

Mudanças são revisáveis em diff. Os arquivos `.uid` e `.import` gerados pelo Godot são commitados.
