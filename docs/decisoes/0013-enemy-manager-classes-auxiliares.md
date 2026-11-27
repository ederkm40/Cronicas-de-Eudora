# 0013: O EnemyManager ganha classes auxiliares, começando pelo desenho

| | |
|---|---|
| **Situação** | Aceita |
| **Data** | 27/11/2026 |

## Contexto

Na 0.4 o `EnemyManager` chegou a 890 linhas e 20 métodos públicos. O `gdlint` permite até 1.000 linhas e 20 métodos públicos por arquivo, sem exceções (AGENTS.md). Qualquer inimigo ou consulta nova esbarraria nesses limites. As decisões 0003 e 0010 continuam valendo: inimigos em arrays + MultiMesh, nunca um nó por inimigo, e todo dano por `EnemyManager.damage()`.

## Decisão

1. **O desenho sai para o `EnemyRenderer`** (`scripts/enemy_renderer.gd`, filho do `EnemyManager`). Ele guarda os `MultiMesh`, os buffers e a forma de cada tipo (`make_mesh`). O `EnemyManager` continua dono dos dados: a cada quadro, calcula a cor de cada inimigo num `PackedColorArray` reaproveitado e chama `draw(count, posições, tipos, elites, cores)` **uma vez**. Os arrays só são lidos, então o Godot não os copia. Não há uma chamada de função por inimigo a mais.
2. **Geometria da tela fica no `CameraRig`:** `is_on_screen(ponto, centro, metade, margem)`.
3. **Consultas usadas só pelos testes ficam nos testes:** `count_of_kind` virou `_count_of_kind` em `tests/suites/base.gd`.
4. **Próximas classes auxiliares seguem a mesma regra:** recebem os arrays como parâmetro (só leitura) ou guardam o próprio estado. Não leem membros com `_` de outra classe, e o `EnemyManager` continua sendo o único lugar onde os arrays mudam.

Resultado: 772 linhas e 18 métodos públicos.

## Alternativas consideradas

- **Um objeto `EnemyData` com todos os arrays públicos:** um acesso a mais por leitura nos laços mais quentes, e uma reescrita do arquivo inteiro. Grande demais para uma manutenção. Pode ser reavaliado se o número de colunas crescer muito.
- **Mover a grade espacial:** a separação e a colisão dos projéteis percorrem a grade dentro de laços quentes. Separar exigiria devolver arrays novos por consulta (alocação por inimigo por quadro). Fica onde está.
- **Desligar a regra do `gdlint`:** proibido pelo AGENTS.md.

## Consequências

- Uma partida simulada de 300 s é idêntica antes e depois: mesmos inimigos, níveis e mortes nos mesmos instantes. O tempo de CPU por quadro ficou igual, dentro do ruído (relatório da manutenção pós-0.4).
- A árvore tem 1 nó a mais (`EnemyManager/Desenho`), criado uma vez.
- Uma forma nova de inimigo entra em `EnemyRenderer.make_mesh()`. Um comportamento novo continua no `match` de `EnemyManager._move()`.
