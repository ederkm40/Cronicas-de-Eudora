# Estado atual do projeto

*Atualizado pelo Claude Code a cada entrega. Última atualização: 26/11/2026, etapa "Manutenção pós-0.3-alpha + Documento Mestre de Sistemas" (PR #7, em revisão).*

| | |
|---|---|
| **Versão oficial** | **0.3-alpha "Grande expansão do combate"**, integrada pelo PR #5 (`51e7e5d`, 26/11/2026) |
| **Commit do `main`** | `3d9102c`: Wiki atualizada para a 0.3-alpha (PR #6, 26/11/2026); CI e publicação com sucesso |
| **Publicado** | jogo e Wiki oficiais do commit `3d9102c` (https://ederkm40.github.io/Cronicas-de-Eudora/ e `/wiki/`). **Atenção:** a build oficial atual ainda contém a ponte de testes (liga com `?teste=1`); a separação só vale depois do merge do PR #7 |
| **Proteção da `main`** | checks obrigatórios: `Testar e exportar` e `Publicar` |
| **Etapa em revisão** | manutenção pós-0.3 + Documento Mestre (branch `feat/manutencao-e-documento-mestre-03`, PR #7); prévia em `/previews/pr-7/` (só a build de produção) |
| **Fase** | 1, protótipo |

## Sistemas do jogo (no `main`)

| Sistema | Arquivo | Situação |
|---|---|---|
| Joystick flutuante, WASD e setas | `floating_joystick.gd`, `player.gd` | publicado |
| Câmera isométrica | `camera_rig.gd` | publicado |
| Orbes, progressão, 6 melhorias, level-up com pausa | `xp_orbs.gd`, `progression.gd`, `upgrades.gd`, `level_up_panel.gd` | publicado |
| Raio arcano, Aura de brasas, Lâmina orbital | `weapon_catalog.gd`, `arsenal.gd`, `auto_weapon.gd`, `aura_weapon.gd`, `orbit_blades.gd` | publicado (0.3) |
| Ofertas com armas, troca e bloqueio | `level_up_offers.gd` | publicado (0.3) |
| 5 tipos de inimigo e mistura por tempo | `enemy_types.gd`, `enemy_manager.gd`, `enemy_projectiles.gd`, `ground_effects.gd` | publicado (0.3) |
| Sentinela do Eco aos 10 min | `boss_controller.gd` | publicado (0.3); equilíbrio a validar com pessoas |
| Esquiva (duplo toque e Espaço) | `floating_joystick.gd`, `player.gd` | publicado (0.3) |
| Vitória, derrota, resultados, reinício limpo | `main.gd`, `results_screen.gd`, `run_stats.gd` | publicado (0.3) |
| Ecos e 4 melhorias permanentes, save versionado | `meta_progress.gd` | publicado (0.3) |

## Correções em revisão no PR #7 (ainda não publicadas)

| Correção | Situação |
|---|---|
| Build de produção sem a ponte de testes; build "Web QA" só no CI (decisão 0011) | implementado e testado (CI e local) |
| Save validado: estrutura e tipos antes de ler; cópia `.corrompido`; campo inválido ajustado sem perder o resto | implementado e testado |
| Joystick retoma o dedo mantido na tela depois do level-up | implementado e testado (Godot e Chromium emulado); **não testado em celular físico** |
| Remoção de `scripts/main.gd.orig` | feito |
| Executor dos testes não trava mais com uma suíte quebrada | feito |

## Documento Mestre de Sistemas (novo, PR #7)

- `docs/design/DOCUMENTO_MESTRE_SISTEMAS.md`, versão 0.1, `EM_ELABORAÇÃO`: 38 áreas com estados independentes de design, implementação e validação.
- `docs/design/catalogos/README.md`: 30 catálogos (9 criados com conteúdo real da 0.3, 21 planejados, ainda sem arquivo) e `MODELO_ENTRADA.md`.
- Não autoriza implementar nada: as entregas aprovadas continuam em `docs/ROADMAP.md`.

## Incompleto, ausente e limitações

- Destro/canhoto e ajuste do joystick: direção aprovada, não implementada.
- Não testado em celular físico; desempenho no celular não medido (o custo de CPU por quadro dobrou na 0.3).
- Equilíbrio medido só com piloto automático; chefe sem validação com pessoas.
- O texto da Atração do eco no jogo diz "raio de coleta"; o efeito é no ímã.
- Câmera em paisagem mostra pouco mapa na vertical; orbes distantes ficam no chão.
- Sem som e sem arte final.
- 2 arquivos GDScript antigos ainda não passaram pelo `gdformat` (`xp_orbs.gd`, `progression.gd`).

## Estado dos testes

- Históricos da 0.3-alpha: `docs/versoes/0.3-alpha/RELATORIO.md` (não repetidos nem alterados).
- Desta etapa: `docs/versoes/manutencao-pos-0.3/RELATORIO.md` e o PR #7.
