---
titulo: Arquitetura
resumo: Como o jogo é organizado por dentro, em linguagem simples.
ordem: 60
---
O jogo é feito no **Godot 4.7.2** com **GDScript**. Tudo é texto, para que uma IA consiga ler e editar o projeto sem abrir o editor visual. A partida inteira é montada em código, em `scripts/main.gd`.

| Sistema | Arquivo | Função |
|---|---|---|
| Partida | `scripts/main.gd` | monta o mundo e liga todos os sistemas |
| Personagem | `scripts/player.gd` | movimento, vida, dano |
| Câmera | `scripts/camera_rig.gd` | câmera isométrica que segue o personagem |
| Joystick | `scripts/floating_joystick.gd` | joystick flutuante |
| Inimigos | `scripts/enemy_manager.gd` | todos os inimigos de uma vez |
| Arma | `scripts/auto_weapon.gd` | disparos automáticos |
| Orbes | `scripts/xp_orbs.gd` | orbes de experiência |
| Progressão | `scripts/progression.gd` | XP e níveis |
| Melhorias | `scripts/upgrades.gd` | sorteio e efeitos das melhorias |
| Tela de nível | `scripts/level_up_panel.gd` | cartões de escolha |
| Interface | `scripts/hud.gd` | tempo, vida, XP, derrota |

## Escolhas importantes

- **Muitos objetos iguais sem nós individuais.** Inimigos, projéteis e orbes ficam em listas de dados e são desenhados de uma vez só (MultiMesh), o que é essencial para o celular.
- **Pausa nativa.** O level-up usa a pausa do próprio Godot, que congela tudo de uma vez.
- **Melhorias recalculadas a partir da base**, sem erro acumulado.

Os detalhes técnicos estão no [documento técnico](https://github.com/ederkm40/Cronicas-de-Eudora/blob/main/docs/TECNICO.md) e nas [[desenvolvimento/decisoes\|decisões técnicas]].
