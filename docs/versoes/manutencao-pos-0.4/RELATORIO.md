# Relatório da manutenção pós-0.4-alpha

| | |
|---|---|
| **Data** | 27/11/2026 |
| **Versão do jogo** | continua 0.4-alpha (sem mudança de equilíbrio, conteúdo ou progressão) |
| **Branch** | `claude/bold-clarke-aixtws` (a partir do `main` `7a7daf2`, que tem a 0.4-alpha do PR #10 e a Wiki do PR #11) |
| **Pull Request** | https://github.com/ederkm40/Cronicas-de-Eudora/pull/12 |
| **Prévia** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-12/ (build de produção) |

## Objetivo

Arrumar a casa depois da 0.4, sem mexer no jogo:

1. Pôr a documentação em dia: ela ainda dizia que a 0.4 estava "em revisão".
2. Corrigir o texto da Atração do eco.
3. Tirar o `EnemyManager` do limite do `gdlint` (20 métodos públicos), para o próximo sistema de inimigos ter espaço.

## 1. Texto da Atração do eco

- **Problema:** a loja dizia "+20% de raio de coleta dos orbes por nível". O efeito real é no **ímã** (`XpOrbManager.magnet_radius`, 3 m na base), a distância em que o orbe começa a voar até o personagem. A coleta final (0,6 m) não muda.
- **Solução:** o texto passou a ser "+20% no raio do ímã dos orbes por nível." (`scripts/meta_progress.gd`). O efeito e os preços não mudaram.

## 2. Divisão do EnemyManager (decisão 0013)

| | Antes | Depois |
|---|---|---|
| Linhas de `enemy_manager.gd` | 890 | 772 |
| Métodos públicos (limite 20) | 20 | 18 |

- **`EnemyRenderer` (novo, `scripts/enemy_renderer.gd`):** cria os `MultiMesh` (um por tipo, 300 de capacidade, 2 para o chefe), guarda os buffers e as formas provisórias de cada tipo (`make_mesh`). O `EnemyManager` calcula a cor de cada inimigo num `PackedColorArray` reaproveitado e chama `draw()` uma vez por quadro. O código de desenho é o mesmo de antes, só mudou de arquivo.
- **`is_on_screen`** passou para o `CameraRig`, com o centro como parâmetro: `is_on_screen(ponto, centro, metade, margem)`.
- **`count_of_kind`** saiu do `EnemyManager`. Só os testes usavam; agora é `_count_of_kind` em `tests/suites/base.gd`.

## Arquivos alterados

- Código: `scripts/enemy_renderer.gd` (novo, com `.uid`), `scripts/enemy_manager.gd`, `scripts/camera_rig.gd`, `scripts/meta_progress.gd`.
- Testes: `tests/suites/base.gd`, `tests/suites/inimigos_e_chefe.gd`, `tests/suites/save_e_joystick.gd`.
- Documentação: `docs/TECNICO.md`, `docs/ROADMAP.md`, `docs/IA/*`, `docs/decisoes/0013-*` (e a linha no índice), `docs/design/DOCUMENTO_MESTRE_SISTEMAS.md` e os catálogos 03, 05, 12, 14 e 26.

## Testes novos

- `test_desenho_um_por_inimigo_e_tela` (inimigos e chefe): o `EnemyRenderer` desenha exatamente 3 Couraçados e 1 Volátil quando há 3 e 1, nenhum comum, e nada depois de limpar; `CameraRig.is_on_screen` aceita o centro e recusa um ponto além da largura.
- `test_atracao_do_eco_texto_e_efeito_no_ima` (save e joystick): o texto fala do ímã e não de coleta; com 2 níveis comprados e salvos, a partida seguinte começa com ímã de 4,2 m.

## Resultados (locais, Godot 4.7.2 headless neste servidor)

| Verificação | Resultado |
|---|---|
| `gdlint scripts tests` | `Success: no problems found` |
| `gdformat --check` (arquivos alterados) | sem alterações pendentes |
| `run_tests` | 73 testes, 4.624 verificações, 0 falhas — `TESTES: OK` |
| `smoke_test` | `SMOKE TEST: OK` |
| `long_simulation` (300 s) | `SIMULAÇÃO LONGA: OK` |
| `tools/wiki/test_wiki.py` | OK |
| `tools/site/test_montar_site.py` | OK |
| Exportações e Playwright | só no CI (ver o PR) |

### Mesmo jogo, mesmo custo

A `long_simulation` de 300 s foi rodada no `main` e nesta branch. As partidas são **idênticas**: mesmos inimigos (122, 300, 123…), níveis, orbes e mortes nos mesmos instantes. A única diferença é 1 nó a mais na árvore (188 contra 187), o `EnemyRenderer`.

Tempo de CPU por quadro, três rodadas alternadas no mesmo servidor (**não representa um celular**):

| Rodada | `main` média · p95 · p99 | Esta branch média · p95 · p99 |
|---|---|---|
| 1 | 2,08 · 6,32 · 7,39 ms | 1,84 · 5,05 · 6,64 ms |
| 2 | 1,82 · 5,07 · 6,49 ms | 1,80 · 4,76 · 6,03 ms |
| 3 | 1,84 · 5,23 · 6,51 ms | 1,83 · 5,13 · 6,80 ms |

As diferenças estão dentro do ruído do servidor: não houve ganho nem perda. O pior quadro (65 a 104 ms) é o primeiro, quando os sons são gerados, como na 0.4.

## Problemas e limitações

- Continua: nada testado em celular físico nem por pessoas; orbes distantes ficam no chão.
- A grade espacial continua no `EnemyManager` (ver as alternativas da decisão 0013).
- As mecânicas da 0.4 continuam **propostas experimentais** no Documento Mestre: o merge integrou o código, mas cada mecânica só vira `APROVADO` com a palavra do proprietário.

## Commit e PR

Código em `5adf868`, documentação nos commits seguintes da branch. PR #12.
