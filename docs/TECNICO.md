# Documentação técnica

Estado de referência: versão 0.2-alpha "Ecos da Evolução". Godot 4.7.2, GDScript, renderizador Compatibility (WebGL 2 no navegador), exportação Web sem threads.

## Visão geral

A cena `scenes/main.tscn` tem um único nó com `scripts/main.gd`, que monta toda a partida em código. Cada sistema é uma classe (`class_name`) num arquivo próprio.

```
Main (main.gd)
├── WorldEnvironment, DirectionalLight3D, chão com grade (shader)
├── Player (player.gd)                 personagem, vida, movimento
├── CameraRig (camera_rig.gd)          câmera isométrica que segue o jogador
├── EnemyManager (enemy_manager.gd)    todos os inimigos: arrays + 1 MultiMesh
├── AutoWeapon (auto_weapon.gd)        disparos automáticos: arrays + 1 MultiMesh
├── XpOrbManager (xp_orbs.gd)          orbes de experiência: arrays + 1 MultiMesh
└── CanvasLayer
    ├── FloatingJoystick               joystick flutuante
    ├── Hud                            tempo, abates, vida, XP, nível, FPS, derrota
    └── LevelUpPanel                   escolha de melhorias (funciona com o jogo pausado)

Objetos sem nó (RefCounted):
  Progression (progression.gd)   XP, nível, níveis pendentes
  Upgrades (upgrades.gd)         definições, níveis, sorteio e efeitos das melhorias
```

## Ciclo da experiência

1. `EnemyManager.damage()` zera a vida de um inimigo → emite `enemy_killed(posição)`.
2. `Main` conta o abate e chama `XpOrbManager.spawn(posição, 1)`.
3. A cada quadro, `XpOrbManager` puxa os orbes a menos de `magnet_radius` (3 m) em direção ao jogador, acelerando, e coleta os que chegam a menos de `collect_radius` (0,6 m). Emite `collected(quantidade)`.
4. `Progression.add_xp()` soma a experiência. Se passar do necessário, sobe de nível (pode subir vários de uma vez) e acumula `pending_level_ups`.
5. No início do quadro seguinte, `Main._process()` vê o nível pendente e chama `_open_level_up()`:
   - sorteia 3 melhorias diferentes com `Upgrades.roll_choices(3)`;
   - liga `get_tree().paused = true` e desliga o joystick;
   - abre o `LevelUpPanel`.
6. O jogador toca num cartão → `LevelUpPanel.chosen(id)` → `Upgrades.apply()` aplica o efeito → `Progression.consume_pending_level_up()`.
7. Se ainda houver níveis pendentes, abre outra escolha. Se não, despausa e religa o joystick.

### Curva de experiência

`Progression.requirement(nível) = round(4 × nível^1,35)`

| Nível | XP para o próximo | XP total acumulada |
| --- | --- | --- |
| 1 | 4 | 4 |
| 2 | 10 | 14 |
| 3 | 18 | 32 |
| 5 | 35 | 85 |
| 10 | 90 | 433 |

Cada inimigo vale 1 de XP (`Main.xp_per_enemy`).

### Pausa

A pausa usa o mecanismo nativo do Godot (`SceneTree.paused`). Todos os nós do jogo usam o modo padrão (`PROCESS_MODE_INHERIT` → pausável), então param juntos: inimigos, projéteis, orbes, geração de hordas, temporizadores, tempo da partida e o próprio `Main`. Só o `LevelUpPanel` usa `PROCESS_MODE_ALWAYS`.

A tela de escolha fica travada por 0,35 s depois de abrir (`input_delay`). Isso evita que o dedo, ainda no joystick, escolha um cartão sem querer.

A escolha não abre depois da derrota: `_process` só abre se `player.alive`, e `_on_player_died` fecha a tela se estiver aberta. "Jogar de novo" despausa e recarrega a cena, e com isso todo o estado (níveis, XP, melhorias, orbes) volta ao início.

## Melhorias

Definidas em `Upgrades.DEFINITIONS`. Cada uma guarda um número de níveis (pilhas). Os efeitos são **recalculados a partir dos valores base** a cada aplicação, em `Upgrades.refresh()`. Assim não há erro acumulado e os bônus somam sobre o base:

| Melhoria | Campo alterado | Fórmula | Limite |
| --- | --- | --- | --- |
| Poder arcano | `AutoWeapon.damage_multiplier` | 1 + 0,20 × n | 10 |
| Cadência | `AutoWeapon.fire_rate_multiplier` (intervalo = base ÷ multiplicador) | 1 + 0,15 × n | 8 |
| Núcleo vital | `Player.max_hp` = base × (1 + 0,25 × n) e cura 25 | — | 8 |
| Passos ligeiros | `Player.speed_multiplier` | 1 + 0,15 × n | 5 |
| Projétil adicional | `AutoWeapon.extra_projectiles` (leque de 10° entre projéteis) | n | 4 |
| Campo de ruptura | `AutoWeapon.range_multiplier` (alcance e duração do projétil) | 1 + 0,20 × n | 5 |

Sorteio: `roll_choices()` tira opções sem reposição entre as que não chegaram ao limite. Nunca repete numa mesma escolha. Se restarem menos de 3 disponíveis, mostra as que restam. Se nenhuma restar, o nível conta e o jogador recupera 25 de vida, sem abrir a tela.

## Desempenho

Objetos repetidos não viram nós. Inimigos, projéteis e orbes ficam em `Packed*Array` e são desenhados por um `MultiMesh` cada (uma chamada de desenho por tipo). Inimigos e orbes enviam as posições de uma vez via `MultiMesh.buffer`.

- **Separação entre inimigos:** grade espacial montada com uma ordenação nativa (`PackedInt64Array.sort()`). A separação é recalculada para metade dos inimigos por quadro, alternando.
- **Orbes:** limite de 400. Acima disso, o valor do orbe novo é somado ao mais antigo, então a XP nunca se perde e a memória fica limitada.
- **Remoção:** troca com o último elemento e reduz o array (`swap-remove`). Não cria nem destrói objetos.

Medições da simulação prolongada (10 min de partida, horda cheia de 300 inimigos, CPU do servidor de testes, sem renderização):

| Medida | Resultado |
| --- | --- |
| Tempo de CPU por quadro: média | 1,3 ms |
| p95 | 2,1 ms |
| p99 | 2,2 ms |
| Nós na árvore | 66, constante, inclusive entre reinícios |
| Memória | estável depois do primeiro minuto (+7 a +8,5 MB no total, sem crescimento contínuo) |

Esses números **não** representam um celular. No navegador do celular, o GDScript roda mais devagar (WebAssembly) e a GPU é mais fraca. O contador de FPS no rodapé é a referência real.

## Testes

| Arquivo | O que cobre | Tempo |
| --- | --- | --- |
| `tests/run_tests.gd` | 16 testes específicos: XP ao derrotar, coleta por proximidade, acúmulo de XP e barra, subida de nível, vários níveis de uma vez, 3 opções distintas (300 sorteios + tela), cada um dos 6 efeitos medido na partida, acúmulo e limites, pausa e retomada (12 grandezas congeladas + toque ignorado), bloqueio após derrota, reinício limpo | ~2 s |
| `tests/smoke_test.gd` | 60 s de partida de ponta a ponta: joystick, tecla D, coleta, level-ups com escolha, pausa | ~1 s |
| `tests/long_simulation.gd` | Partida longa (`--segundos=N`). O piloto foge em círculos por 2 min e depois fica parado até morrer; reinicia e continua. Mede tempo por quadro, máximos, nós e memória. `--invulneravel` mantém a horda cheia | 10 min de jogo ≈ 25 s |

Os testes usam ganchos que só existem para isso: `EnemyManager.spawning_enabled`, `spawn_at()`, `hp_of()`, `Player.invulnerable`, `scripted_input` e `AutoWeapon.shots_fired`.

Os testes também foram conferidos ao contrário: quebrando o jogo de propósito (sem pausa, sem orbes, sorteio com repetição, sem a cura do Núcleo vital), os testes correspondentes falham.

## Publicação

`.github/workflows/web.yml`:

1. Importa o projeto.
2. Roda os testes: `run_tests`, `smoke_test` e a simulação prolongada de 5 minutos.
3. Exporta para Web.
4. Verifica os arquivos exportados (`index.html`, `.js`, `.pck`, `.wasm`).
5. Publica no GitHub Pages, **só** em push no `main`. Em Pull Request, a versão web fica disponível para download como artefato `versao-web`, sem publicar.

## Limitações conhecidas

- **Sem teste em celular físico.** Até aqui o jogo foi conferido em Chrome com tela e toque de celular simulados.
- **Pausa e dedo no joystick:** se o dedo ainda estiver na tela quando a pausa termina, o joystick só volta a responder depois de levantar e tocar de novo.
- **Equilíbrio ainda não ajustado:** a arma base mata devagar diante da horda máxima. Na simulação, a horda chega a 300 inimigos por volta dos 2 minutos, e quem fica parado cai rápido. Esse ajuste depende de testes com pessoas.
- **Orbes distantes:** orbes que caem longe ficam no chão até o jogador passar perto. Não somem nem são puxados de longe.
- **Sem som e sem arte final.**
