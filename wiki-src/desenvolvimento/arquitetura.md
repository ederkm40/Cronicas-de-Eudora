---
titulo: Arquitetura
resumo: Como os sistemas da versão 0.3-alpha são organizados por dentro.
ordem: 60
---
O jogo é feito no **Godot 4.7.2** com **GDScript**, Compatibility Renderer e exportação Web sem threads. A partida é montada em código por `scripts/main.gd`.

## Sistemas principais

| Sistema | Arquivo ou classe | Função |
|---|---|---|
| Partida | `scripts/main.gd` | Monta o ambiente e coordena os sistemas. |
| Personagem | `scripts/player.gd` | Movimento, vida, dano e esquiva. |
| Câmera | `scripts/camera_rig.gd` | Câmera isométrica que segue o personagem. |
| Joystick | `scripts/floating_joystick.gd` | Movimento por toque e gesto de esquiva. |
| Inimigos | `scripts/enemy_manager.gd`, `EnemyTypes` | Estado e comportamento de cada tipo. |
| Projéteis inimigos | `scripts/enemy_projectiles.gd` | Projéteis do Lançador e do chefe. |
| Chefe | `scripts/boss_controller.gd` | Máquina de estados do Sentinela do Eco. |
| Arma inicial | `scripts/auto_weapon.gd` | Raio arcano. |
| Aura | `scripts/aura_weapon.gd` | Pulsos de dano em área. |
| Lâminas | `scripts/orbit_blades.gd` | Dano orbital e visual das lâminas. |
| Arsenal | `WeaponCatalog`, `Arsenal`, `LevelUpOffers` | Definições, estado das armas e ofertas. |
| Orbes | `scripts/xp_orbs.gd` | Coleta de experiência. |
| Progressão | `scripts/progression.gd`, `scripts/upgrades.gd` | XP, níveis e melhorias da partida. |
| Progressão permanente | `scripts/meta_progress.gd` | Ecos, loja permanente e save versionado. |
| Estatísticas | `scripts/run_stats.gd` | Dano, abates, esquivas e dados do encontro. |
| Resultados | `scripts/results_screen.gd` | Vitória, derrota, resumo e compra de melhorias permanentes. |
| Interface | `scripts/hud.gd`, `scripts/level_up_panel.gd` | HUD e escolhas. |

## Decisões de arquitetura

- **Definição separada de estado e execução:** `WeaponCatalog` guarda dados, `Arsenal` guarda as armas adquiridas e cada arma tem um nó próprio de execução.
- **Inimigos em estruturas compartilhadas:** os inimigos usam arrays e MultiMesh por tipo, em vez de um nó individual para cada criatura.
- **Dano centralizado:** o `EnemyManager` aplica dano e registra a vida realmente retirada para as estatísticas.
- **Pausa nativa:** o level-up usa `SceneTree.paused` para congelar a simulação.
- **Save versionado:** a progressão permanente fica em `user://progresso.json`.

Os detalhes técnicos e decisões estão no [documento técnico](https://github.com/ederkm40/Cronicas-de-Eudora/blob/main/docs/TECNICO.md) e em [[desenvolvimento/decisoes|decisões técnicas]].
