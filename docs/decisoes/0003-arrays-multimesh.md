# 0003: Objetos repetidos em arrays + MultiMesh, nunca um nó por objeto

| | |
|---|---|
| **Situação** | Aceita |
| **Data** | 25/11/2026 |

## Contexto

O gênero exige centenas de inimigos e projéteis. Um nó por objeto gera centenas de chamadas de desenho e muito trabalho de cena, o que é pesado para o navegador do celular.

## Decisão

Inimigos, projéteis e orbes ficam em `PackedVector3Array` e similares e são desenhados por um `MultiMesh` por tipo, com envio das posições via `MultiMesh.buffer`. A remoção troca o item com o último da lista. A separação entre inimigos usa uma grade espacial montada por ordenação nativa (`PackedInt64Array.sort()`).

## Consequências

Lógica dos objetos fica nos gerenciadores (`EnemyManager`, `AutoWeapon`, `XpOrbManager`). Comportamentos por objeto precisam ser escritos como dados nos arrays.
