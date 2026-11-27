# Documentação técnica

Estado de referência: versão **0.4-alpha "O Despertar de Eudora"** (integrada no `main` pelo PR #10, `f51db23`), sobre a 0.3-alpha e a manutenção pós-0.3, mais a manutenção pós-0.4 (desenho dos inimigos no `EnemyRenderer`). Godot 4.7.2, GDScript, renderizador Compatibility (WebGL 2 no navegador), exportação Web sem threads.

## Visão geral

A cena `scenes/main.tscn` tem um único nó com `scripts/main.gd`, que monta toda a partida em código. Cada sistema é uma classe (`class_name`) num arquivo próprio.

```
Main (main.gd)
├── WorldEnvironment, DirectionalLight3D, chão com grade (shader)
├── GroundEffects (ground_effects.gd)      avisos e anéis no chão: arrays + 3 MultiMesh
├── Player (player.gd)                     personagem, vida, movimento, esquiva
├── CameraRig (camera_rig.gd)              câmera isométrica que segue o jogador
├── EnemyManager (enemy_manager.gd)        todos os inimigos e o corpo do chefe: arrays paralelos
│   └── EnemyRenderer (enemy_renderer.gd)  desenho dos inimigos: 1 MultiMesh por tipo
├── EnemyProjectiles (enemy_projectiles.gd) projéteis do Lançador e do chefe: arrays + 1 MultiMesh
├── BossController (boss_controller.gd)    máquina de estados do Sentinela do Eco
├── AutoWeapon (auto_weapon.gd)            Raio arcano (arma inicial): arrays + 1 MultiMesh
├── AuraWeapon (aura_weapon.gd)            Aura de brasas: 1 malha com shader
├── OrbitBlades (orbit_blades.gd)          Lâmina orbital: 1 MultiMesh (lâminas + rastro) e o anel da órbita
├── XpOrbManager (xp_orbs.gd)              orbes de experiência: arrays + 1 MultiMesh
├── HazardZones (hazard_zones.gd)          0.4: poças de cinzas do Semeador (arrays; desenho por GroundEffects)
├── EventDirector (event_director.gd)      0.4: elites, Fenda do Eco, Maré e Calmaria
├── SoundBank (sound_bank.gd)              0.4: sons gerados no código, 10 vozes
├── CombatFeedback (combat_feedback.gd)    0.4: números de dano (24 Label3D reaproveitados)
├── GameFeel (game_feel.gd)                0.4: liga sinais a som, tremor, números e estouros
├── (web_bridge.gd)                      ponte de testes: só na build "Web QA" (ver Builds)
└── CanvasLayer
    ├── FloatingJoystick                   joystick flutuante e duplo toque (esquiva)
    ├── Hud                                tempo, abates, vida, XP, armas, chefe, avisos, esquiva
    ├── LevelUpPanel                       ofertas do level-up, troca e bloqueio (funciona pausado)
    ├── ResultsScreen                      vitória/derrota, resumo e loja permanente (funciona pausado)
    └── PauseMenu                          0.4: pausa com as configurações (funciona pausado)

Objetos sem nó (RefCounted):
  Progression (progression.gd)        XP, nível, níveis pendentes
  Upgrades (upgrades.gd)              melhorias passivas: definições, níveis e efeitos
  WeaponCatalog (weapon_catalog.gd)   definição das armas e atributos por nível (só dados)
  Arsenal (arsenal.gd)                armas do jogador na partida e seus níveis (estado)
  LevelUpOffers (level_up_offers.gd)  sorteio das ofertas, troca e bloqueio
  EnemyTypes (enemy_types.gd)         atributos dos tipos de inimigo e a mistura por tempo
  RunStats (run_stats.gd)             estatísticas reais da partida
  MetaProgress (meta_progress.gd)     Ecos e melhorias permanentes, salvos em user://
  GameSettings (game_settings.gd)     0.4: configurações do jogador, salvas em user://configuracoes.json
```

## Ciclo da partida

1. `EnemyManager.damage(índice, dano, arma)` desconta a resistência do tipo, registra o dano em `RunStats` e, se a vida zerar, emite `enemy_killed(posição, tipo, xp)`.
2. `Main` conta o abate e cria um orbe com a XP do tipo (Errante 1, Espreitador 1, Couraçado 4, Lançador 2, Volátil 2). Um Volátil que explode sozinho não conta abate nem deixa orbe.
3. `XpOrbManager` puxa os orbes a menos de `magnet_radius` (3 m) e coleta a menos de `collect_radius` (0,6 m). `Progression.add_xp()` sobe de nível e acumula `pending_level_ups`. **Cada nível ganho recupera 12% da vida máxima** (`Main.level_up_heal`).
4. No início do quadro seguinte, `Main._open_level_up()` pede até 3 ofertas a `LevelUpOffers`, pausa (`SceneTree.paused`), desliga o joystick e abre o `LevelUpPanel`.
5. O jogador escolhe um cartão, troca as opções ou bloqueia um cartão. A escolha passa por `Main.apply_offer()`, que aplica e sincroniza as armas.
6. Aos 9 min 50 s aparece um aviso; aos 10 min (`Main.encounter_time` = 600 s) começa o **encontro final**: o Sentinela do Eco surge na borda de cima da tela, a barra dele aparece e as hordas caem para 30% do ritmo e novos Lançadores deixam de nascer. A partida **não termina** aos 10 minutos.
7. Derrotar o chefe → vitória: a partida congela (pausa) e abre a `ResultsScreen`. Morrer → derrota: a mesma tela, sem pausa (a horda para porque o jogador morreu).
8. No fim, `MetaProgress.record_run()` soma os Ecos e salva. "Jogar de novo" despausa e recarrega a cena: todo o estado da partida (inimigos, projéteis, efeitos, armas, ofertas, estatísticas) é recriado do zero. Só o arquivo de progresso permanece.

### Curva de experiência

`Progression.requirement(nível) = round(4 × nível^1,35)`: 4, 10, 18, 26, 35… (nível 10 → 90). Sem mudança nesta versão.

### Pausa

Pausa nativa (`SceneTree.paused`). Só `LevelUpPanel`, `ResultsScreen`, `FloatingJoystick` e a ponte de testes usam `PROCESS_MODE_ALWAYS`. Com a pausa, o jogador não recebe teclas (a esquiva pelo Espaço não funciona no menu) e o joystick fica desligado (sem movimento e sem duplo toque), mas continua acompanhando o dedo que já estava nele: ao retomar, esse dedo volta a controlar a partir da posição atual; se foi solto durante a pausa, o joystick volta neutro. Toques que começam durante a pausa não viram joystick, e a pausa zera os gestos de esquiva. A tela de escolha fica travada por 0,35 s depois de abrir.

## Armas

Separação: **definição** (`WeaponCatalog`, só dados) → **estado** (`Arsenal`: quais armas e em que nível, um espaço por arma, 4 espaços) → **execução e visual** (um nó por arma) → **colisão** (consultas do `EnemyManager`) → **dano** (`EnemyManager.damage`, com a arma como origem). Para criar uma arma nova: definição no catálogo, um nó que usa as consultas do `EnemyManager`, e a ligação em `Main._sync_weapons()`.

| Arma | Tipo | Como acerta | Nível 1 → 5 |
|---|---|---|---|
| Raio arcano (inicial) | projétil | atira no inimigo mais próximo a até 11 m; **mira o chefe quando ele está ao alcance**; colisão pela grade espacial | só melhora pelas passivas |
| Aura de brasas | aura | um pulso a cada intervalo acerta todos os inimigos cujo corpo toca o círculo (nunca por quadro) | dano 6 → 14 · raio 2,2 → 3,2 m · pulso 0,6 → 0,45 s |
| Lâmina orbital | orbital | lâminas giram em volta do jogador; cada inimigo só pode ser cortado de novo depois de 0,35 s, mesmo com várias lâminas passando | dano 14 → 26 · lâminas 1 → 4 · raio 1,9 → 2,5 m · giro 3,2 → 4,0 rad/s |

Tabela completa em `WeaponCatalog.DEFINITIONS`. Visual: a aura é um disco com shader (borda de brasas e uma onda que sai do centro a cada pulso); a lâmina é um prisma claro com rastro e um anel fino mostrando a órbita; os inimigos piscam em branco ao levar dano.

### Melhorias passivas e sinergias

Recalculadas a partir dos valores base em `Upgrades.refresh()`, que também aplica os bônus permanentes.

| Melhoria | Efeito | Limite |
|---|---|---|
| Poder arcano | +20% de dano de **todas** as armas | 10 |
| Cadência | +15% de velocidade do Raio **e dos pulsos da Aura** | 8 |
| Núcleo vital | +25% de vida máxima e cura 25 | 8 |
| Passos ligeiros | +15% de velocidade de movimento | 5 |
| Projétil adicional | +1 projétil do Raio por disparo (leque de 10°) | 4 |
| Campo de ruptura | +20% de alcance do Raio e **+10% de raio da Aura** | 5 |

## Ofertas do level-up (`LevelUpOffers`)

- **Válidas:** arma não adquirida com espaço livre (aparece como "NOVA ARMA"), arma adquirida abaixo do nível 5 ("ARMA · Nv. n » n+1", com a mudança de cada atributo), melhoria abaixo do limite ("MELHORIA · n/limite"). Nada bloqueado.
- **Sorteio ponderado, sem repetição:** arma nova peso 2,2 nas 6 primeiras telas e 1,4 depois; evolução de arma 1,4; Núcleo vital 2,0 quando a vida está abaixo de 50%; o resto 1,0.
- **Menos de 3 válidas:** a tela mostra só as que existem. **Nenhuma válida:** o nível conta e o jogador recupera 25 de vida, sem abrir a tela.
- **Trocar opções:** 2 por partida (+1 por nível da melhoria permanente Renovação). Gasta uma troca, não consome o nível, e evita repetir as opções da tela quando há alternativas. Tecla R.
- **Bloquear:** 2 por partida. Tira a opção da partida inteira e põe outra no lugar do cartão. Recusado se for a última opção válida. Troca e bloqueio são independentes.

## Inimigos (`EnemyTypes` + `EnemyManager`)

Todos vivem nos mesmos arrays paralelos do `EnemyManager` (posição, vida, vida máxima, velocidade, empurrão, tipo, estado, temporizador, recarga da lâmina, piscada, aviso ligado e id estável). O desenho fica no `EnemyRenderer`, filho do `EnemyManager`: um `MultiMesh` por tipo, com tamanho (elites maiores) e cor por instância. A cada quadro, o `EnemyManager` calcula a cor de cada inimigo (piscada de dano, brilho dos avisos, estados) num `PackedColorArray` e chama `EnemyRenderer.draw()` uma vez, passando os arrays (só leitura, sem cópia). A forma de cada tipo está em `EnemyRenderer.make_mesh()`. Se um ponto está na tela: `CameraRig.is_on_screen(ponto, centro, metade, margem)`.

| Tipo | Vida | Velocidade | Contato | Comportamento |
|---|---|---|---|---|
| Errante (comum) | 1× | 2,2 m/s | 9/s | persegue |
| Espreitador (rápido) | 0,45× | 4,3 m/s | 7/s | mira à frente do jogador e acelera (×1,3) a menos de 4 m |
| Couraçado (resistente) | 5× | 1,35 m/s | 15/s | ignora 35% do dano; quase não é empurrado pelos outros |
| Lançador (atirador) | 1,2× | 2,4 m/s | 6/s | fica entre 6 e 8,5 m, anda de lado, para e brilha 0,55 s antes de atirar (8 de dano, 6,5 m/s, a cada ~3,2 s); só atira de dentro da tela |
| Volátil (explosivo) | 0,9× | 3,0 m/s | 6/s | a menos de 1,9 m acende o pavio: para, pisca e mostra o círculo no chão; 0,85 s depois explode (26 de dano, raio 2,4 m). Pode ser eliminado antes |

"Vida" multiplica a vida base de 20, que cresce **35% por minuto** de partida. Mistura por tempo (`EnemyTypes.SCHEDULE`): o Espreitador entra aos 45 s, o Couraçado aos 100 s, o Lançador aos 150 s e o Volátil aos 210 s, cada um com peso crescente até um máximo (0,45, 0,22, 0,15 e 0,2, contra 1 do Errante). A leva cresce +1 inimigo a cada 30 s. Limite: 300 inimigos (o chefe não conta).

## Encontro final: Sentinela do Eco (`BossController`)

O corpo do chefe é um inimigo do tipo `CHEFE` dentro do `EnemyManager` (assim todas as armas o acertam do mesmo jeito; o índice dele é mantido ao remover outros). O `BossController` só decide o comportamento, com uma máquina de estados:

`PERSEGUIR (2,2 s) → ataque (rodízio) → RECUPERAR (1,4 s, parado e vulnerável) → PERSEGUIR`

| Ataque | Aviso | Golpe |
|---|---|---|
| Investida | faixa vermelha no chão na direção do jogador, 1 s | atravessa 9 m a 16 m/s; 28 de dano se encostar |
| Erupção | círculos no chão (onde o jogador está, onde vai estar e 2 ao redor), 1,1 s | 30 de dano se o jogador estiver em algum círculo |
| Rajada | o chefe brilha em lilás, 0,7 s | anel de 14 projéteis (12 de dano cada) |

Vida 3.800. Abaixo de 50%: fase 2 (aviso no HUD, avisos e pausas 25% mais curtos, 4 erupções ao redor do jogador em vez de 2, rajada dupla e 6 reforços: Voláteis e Espreitadores). Contato: 24/s. Recompensa: a vitória e 40 Ecos.

## Esquiva

- **Celular:** duplo toque no joystick (`FloatingJoystick`). Um toque curto (até 0,22 s e 28 unidades de arrasto) seguido, em até 0,32 s e a até 140 unidades, de um segundo toque. Se o segundo toque arrasta 40 unidades em até 0,3 s (peteleco), a esquiva vai na direção do arrasto; se é curto, vai para onde o personagem está indo (ou para a frente dele, parado). Um gesto arma uma esquiva só.
- **Computador:** tecla **Espaço** (não conflita com WASD, setas, 1-3 e R).
- **Efeito:** 4 m em 0,18 s, 0,32 s sem levar dano (contato, projéteis, explosões e ataques do chefe), recarga de 1,4 s. Feedback: o personagem fica ciano translúcido, um anel sai do chão e o indicador "Esquiva pronta" no rodapé.
- Os tempos usam o relógio do jogo (soma dos `delta`), então valem igual nos testes.

## Resultados e estatísticas (`RunStats`, `ResultsScreen`)

`RunStats` conta no momento em que acontece: dano por arma e por tipo de inimigo (só a vida realmente tirada), abates por arma e por tipo, dano recebido por origem, esquivas, explosões, momento em que o chefe surgiu e caiu, dano dado e recebido no encontro. A tela mostra tempo, nível, abates, dano causado e recebido, esquivas, chefes derrotados, tempo contra o chefe, armas com nível/dano/abates e melhorias com níveis.

## Progressão permanente (`MetaProgress`)

- Arquivo `user://progresso.json`, com campo `versao` (atual: 1). No navegador, `user://` fica no armazenamento do site (IndexedDB).
- Salvamento: grava num `.tmp` e renomeia. Versão 0 (sem o campo `versao`) é migrada. **Não havia save antes da 0.3**: a migração está pronta e testada para o futuro.
- Leitura com validação (manutenção pós-0.3):
  - **Estrutura inválida** (JSON inválido, raiz que não é objeto, `versao` que não é número ou é negativa, `estatisticas` ou `melhorias` que não são objetos): cópia `.corrompido` e começo do zero.
  - **Campo inválido** (tipo errado, negativo, fracionado, nível acima do limite): cópia `.corrompido`; só o campo vira valor seguro (0, o inteiro abaixo ou o limite); o resto é mantido. `load_note` = `ajustado`.
  - Os motivos ficam em `MetaProgress.load_issues` e saem no console (`push_warning`). Nenhum valor inválido causa erro de execução.
  - **Versão mais nova:** só leitura, tolerante a tipos desconhecidos; nunca salva por cima.
  - O original só é substituído no próximo salvamento, depois da cópia. Campos desconhecidos são mantidos ao salvar.
- Recompensa: 1 Eco a cada 20 s, 1 a cada 15 abates, 40 por chefe derrotado.
- Loja (na tela de resultados): Vigor ancestral (+8% de vida por nível, 5 níveis), Fúria latente (+5% de dano, 5), Atração do eco (+20% no raio do ímã dos orbes, 3), Renovação (+1 troca de opções, 2). Os preços estão em `MetaProgress.UPGRADES`.

## Desempenho

Nada repetido vira nó: inimigos, projéteis (do jogador e dos inimigos), orbes, lâminas e efeitos no chão ficam em `Packed*Array` e são desenhados por `MultiMesh`. A remoção troca com o último elemento (sem criar nem destruir objetos). Efeitos no chão têm limite de 160 (o mais antigo é substituído); projéteis inimigos, de 240.

- **Grade espacial:** montada uma vez por quadro com ordenação nativa (células de 1,5 m). Usada na separação entre inimigos e na colisão dos projéteis do Raio (antes era uma busca em todos os inimigos para cada projétil).
- **Aura:** uma passada pelos inimigos por pulso, não por quadro. **Lâmina:** uma passada por quadro para achar quem está perto do anel, e só esses são comparados com as lâminas.
- **Ciclo de vida:** tudo é filho de `Main`; "Jogar de novo" recarrega a cena e libera tudo. Os testes conferem que a partida anterior é liberada e que a nova começa sem inimigos, projéteis, efeitos, chefe, armas extras ou estatísticas antigas.

Medições: ver `docs/versoes/0.3-alpha/RELATORIO.md`, `docs/versoes/0.4-alpha/RELATORIO.md` e `docs/versoes/manutencao-pos-0.4/RELATORIO.md`. São tempos de CPU do servidor de testes, sem renderização: **não** representam um celular.

## Testes

| Arquivo | O que cobre |
|---|---|
| `tests/run_tests.gd` + `tests/suites/` | 73 testes em 6 suítes: progressão (os 16 da 0.2); armas e ofertas (9); inimigos e chefe (8, com o desenho por tipo); esquiva, encerramento e progressão permanente (9); save e joystick (11, com a Atração do eco); despertar (20, 0.4) |
| `tests/smoke_test.gd` | 60 s de partida: joystick, tecla D, Espaço, coleta, ofertas escolhidas, pausa; 0.4: elite e fenda forçados, pausa por Esc, sons e estouros |
| `tests/long_simulation.gd` | partida longa (`--segundos=N`, `--invulneravel`): tempo por quadro, máximos, nós e memória, com reinícios |
| `tests/balance_simulation.gd` | **não roda no CI**: comparação de armas (`--modo=dps`), partida com piloto (`--modo=partida`) e encontro final (`--modo=chefe`) |

No CI, os scripts do Godot rodam por `tools/ci/rodar_godot.sh`, que **falha se aparecer erro de script no log** (o Godot nem sempre muda o código de saída quando um script quebra no meio).

Ganchos de teste: `EnemyManager.spawning_enabled`, `spawn_at()`, `Player.invulnerable`, `scripted_input`, `Main.start_encounter()`, `Main.apply_offer()`, `Main.encounter_time`, `MetaProgress.path` e `GameSettings.path` (os testes usam arquivos próprios).

### Verificação estática do GDScript (gdtoolkit 4.5.0)

Decisão [0009](decisoes/0009-ferramentas-qa-web.md). Instalado só no runner, com versões fixadas em `requirements-ci.txt`. Roda por `tools/ci/verificar_gdscript.sh`:

| Modo | O que faz |
|---|---|
| `lint` | `gdlint scripts tests` com as regras padrão da versão 4.5.0, sem exceções (`gdlint --dump-default-config` mostra a lista) |
| `formato <commit-base>` | `gdformat --check` só nos `.gd` adicionados ou alterados desde o ponto comum com o commit-base (PR: base do PR; `main`: commit anterior ao envio) |

As regras que exigiram ajustes no código existente foram `max-line-length` (100 caracteres), `class-definitions-order` (constantes antes de variáveis) e `max-returns` (no máximo 6 `return` por função). O ajuste não mudou a lógica: o texto de `Upgrades.describe_next` foi conferido nas 67 combinações.

### Testes de navegador (Playwright 1.65.1)

Em `tools/e2e/`, com guia de manutenção em `tools/e2e/README.md`. Abrem o **jogo exportado de verdade**, servido em `127.0.0.1:8060`, no Chromium, em 3 perfis: computador 1366 × 768, Pixel 7 em pé (412 × 915, toque) e Pixel 7 deitado (915 × 412, toque).

| Verificação | Como |
|---|---|
| Motor iniciado | a página do Godot remove `#status` quando o `startGame()` termina; em caso de erro, o teste mostra `#status-notice` |
| Versão do motor | "Godot Engine v4.7.2" no console |
| WebGL 2 | `getContext("webgl2")`; o renderizador é impresso no log |
| Arquivos essenciais | `index.html`, `.js`, `.wasm` e `.pck` com 200 e nenhuma requisição falhando |
| Canvas | visível, dentro da tela, ocupando a janela, com resolução interna válida |
| Jogo rodando | a imagem do canvas muda com o tempo |
| Sem erros | nenhuma exceção nem `console.error` |
| Toque e orientação | nos perfis de celular |
| Jogabilidade (`jogabilidade.spec.js`) | joystick arrastado, duplo toque (e toques espaçados que não esquivam), Espaço, level-up tocando em Trocar/Bloquear/cartão, vitória contra o chefe e derrota com "Jogar de novo" tocado. Roda na build "Web QA", cuja ponte de testes só lê o estado e prepara situações; inclui a retomada do joystick com o dedo pressionado |
| Produção sem ponte (`producao.spec.js`) | build "Web" aberta normalmente e com `?teste=1`: sem `window.__eudora` nem `window.__eudoraComandos`, comandos escritos na página não são lidos, o jogo roda |

**Renderizador:** dentro do `xvfb-run`, com `--use-angle=gl`, o Chromium usa Mesa/llvmpipe (OpenGL 4.5). Sem tela virtual, cai no SwiftShader, que não mostra as atualizações de MultiMesh. **A emulação de Pixel 7 não equivale a um celular físico.**

## Builds: produção e QA

| Build | Preset | O que tem | Onde vai |
|---|---|---|---|
| **Produção** | `Web` (`export_presets.cfg`, `exclude_filter` tira `scripts/web_bridge.gd`) | o jogo, sem a ponte de testes | site oficial e prévias dos PRs (`tools/ci/construir_parte.sh`) |
| **QA** | `Web QA` (funcionalidade de exportação `qa`) | o jogo + a ponte de testes `scripts/web_bridge.gd` | só os testes do Playwright no CI (`tools/ci/construir_qa.sh`, em `$RUNNER_TEMP/qa`); nunca sai do job "Testar e exportar" |

`main.gd` só carrega a ponte quando o jogo roda no navegador **e** tem a funcionalidade `qa`; a ponte não tem `class_name`, então nada no jogo depende dela. `tools/ci/verificar_producao.sh` confere no CI que o `.pck` de produção não contém `scripts/web_bridge` (e que o de QA contém, para a verificação não passar por engano). O Playwright roda duas vezes: na QA (`E2E_MODO=qa`: `jogo.spec.js` e `jogabilidade.spec.js`) e na produção (`E2E_MODO=producao`: `jogo.spec.js` e `producao.spec.js`).

## Publicação, Wiki e prévias

Workflow `.github/workflows/publicar.yml` (decisão [0006](decisoes/0006-publicacao-gh-pages-previas.md)). O site fica no branch `gh-pages`, e o GitHub Pages precisa usar *Deploy from a branch → gh-pages / (root)*.

| Evento | Job `testar` | Job `publicar` / `remover-previa` |
|---|---|---|
| Push no `main` (ou execução manual no `main`) | Godot, Python + gdtoolkit, Node 22 + Playwright → `gdlint` → `gdformat --check` (alterados) → importa → `run_tests` → smoke → simulação de 5 min → testes da Wiki (com Node obrigatório) e do site → exporta e gera a Wiki → servidor local → Playwright (3 perfis) → guarda a montagem | publica o jogo na raiz e a Wiki em `/wiki/`; remove prévias de PRs que já não estão abertos; verifica no ar |
| Pull Request do próprio repositório (aberto ou novo envio) | o mesmo, com o commit da branch | publica em `/previews/pr-N/` (jogo + Wiki com faixa de prévia), sem tocar na raiz; comenta o endereço e a verificação no PR |
| Pull Request fechado ou integrado | — | `remover-previa` apaga `/previews/pr-N/` |
| Pull Request de fork | testa com permissão só de leitura | nunca publica |

Garantias:

- **Uma publicação por vez:** grupo de concorrência `gh-pages`, sem cancelar a que está rodando.
- **Convergência:** antes de publicar uma prévia, o workflow confere em `publicacao.json` se a raiz corresponde ao `main` atual. Se não corresponder (por exemplo, porque uma publicação do `main` foi cancelada na fila), reconstrói a raiz a partir do `main`.
- **Verificação real:** `tools/ci/verificar_publicacao.sh` espera o `versao.json` do endereço mostrar o commit publicado e testa `index.html`, `.js`, `.pck`, `.wasm` e a Wiki. Se o endereço não abrir, **o job `Publicar` termina como falha**: o PR fica com o check vermelho. O resumo da execução e o comentário do PR são publicados mesmo assim, com o motivo e o endereço.
- **Segurança:** permissões mínimas por job, sem `pull_request_target`, sem segredos. Forks não publicam.

Os nomes dos jobs **`Testar e exportar`** e **`Publicar`** são os checks obrigatórios da proteção da `main`. Não renomeie.

Ferramentas de publicação (Python 3 e shell, sem dependências externas):

| Arquivo | Papel |
|---|---|
| `tools/ci/instalar_godot.sh` | baixa o Godot `GODOT_VERSION` e os modelos Web |
| `tools/ci/construir_parte.sh` | exporta o jogo, gera a Wiki e grava `versao.json` |
| `tools/site/montar_site.py` | aplica a parte no site: `oficial`, `previa`, `remover`, `limpar` |
| `tools/ci/abrir_gh_pages.sh`, `enviar_gh_pages.sh` | baixam e enviam o branch `gh-pages` |
| `tools/wiki/build_wiki.py`, `markdown_mini.py` | geram a Wiki (decisão [0007](decisoes/0007-wiki-gerador-proprio.md)) |

### Wiki

- Fontes em `wiki-src/`, uma página por arquivo `.md`, com cabeçalho `titulo/resumo/estado/versao/ordem`. A sintaxe está em `wiki-src/README.md`.
- Links internos `[[caminho]]` são validados: link quebrado, estado desconhecido, artigo sem título ou diretiva desconhecida **fazem a geração falhar**.
- Busca no navegador sobre `search-index.json` (`wiki-src/assets/busca.js`), sem servidor.
- A geração é determinística (mesmas fontes = mesmos arquivos) e nunca altera as fontes.
- `docs/CHANGELOG.md`, `docs/versoes/*/RELATORIO.md` e `docs/decisoes/*.md` aparecem como páginas somente leitura do painel de desenvolvimento.
- `docs/`, `tools/` e `wiki-src/` têm `.gdignore`, então não entram no `.pck` do jogo.

## 0.4-alpha: O Despertar de Eudora (PR #10)

### Dano e estados nos inimigos

`EnemyManager.damage()` chama `_hurt(índice, dano, arma, piscar)`. Ordem: armadura do elite Blindado (+0,3 de resistência, até 0,75) → escudo do Tecelão (×0,6) → chefe exposto (×1,5) → `RunStats` → morte. Golpes no chefe e em elites emitem `important_hit(posição, dano, exposto)`; mortes de elites emitem `elite_killed(posição, tipo, modificador)`.

Estados por inimigo, em arrays paralelos (trocados com o último na remoção, como os outros):

| Array | Estado | Origem | Regra |
|---|---|---|---|
| `_burn`, `_burn_dps` | queimadura | Coroa de cinzas | dano por segundo sem piscar, fonte `aura_de_brasas`; renova o tempo e fica com o maior dano |
| `_slow` | lentidão | Vendaval de lâminas | velocidade ×0,55 enquanto durar; o chefe é imune |
| `_knock` | empurrão | Raio, Vendaval | velocidade extra somada ao movimento, cai ×9/s; Couraçado e elites ×0,3; o chefe é imune |
| `_shielded` | escudo | Tecelão | recalculado a cada quadro (`_update_weavers`): quem está a até `weaver_radius` (3,5 m) de um Tecelão; nem Tecelões nem o chefe |
| `_elite` | modificador | `spawn_at(..., elite)` | 0 nenhum · 1 Veloz · 2 Blindado · 3 Gerador |

`apply_effects(índice, queimadura_por_s, segundos, lentidão_s, empurrão)` aplica estados; `status_of(índice)` devolve as marcas `STATUS_BURN | SLOW | SHIELD | ELITE` (usadas pelos testes e pela cor). Cor por instância: elite dourado pulsante, queimando laranja, lento azul, com escudo ciano, chefe exposto branco pulsante.

### Tipos novos

`EnemyTypes`: `TECELAO` (6) e `SEMEADOR` (7), `COUNT` = 8. Tecelão: vida ×2, 1,9 m/s, contato 5, XP 3, fica entre 7 e 9,5 m (`_keep_distance`). Semeador: vida ×1,6, 2,1 m/s, contato 6, XP 3; a cada `sower_interval` (4,5 s) chama `HazardZones.add()`. `HazardZones`: até 20 poças, raio 1,6 m, 5 s, ativas depois de 0,6 s, 12 de dano por segundo no jogador (fonte "Semeador").

Elites: vida ×`ELITE_HP` (5), escala ×1,45, contato ×1,5; Veloz ×1,5 de velocidade; Gerador chama 2 Errantes a cada `elite_spawner_interval` (7 s). Recompensa (em `Main`): orbe de 12, cura de 15, `stats.elites_killed`.

### Evoluções

`WeaponCatalog.EVOLUTIONS` (id, arma, nome, descrição, nível da arma, passivas exigidas). `Arsenal.can_evolve()` / `evolve()` / `is_evolved()`. `LevelUpOffers` inclui as evoluções disponíveis em `valid_ids()` com peso 5 (`KIND_EVOLUTION`); o `LevelUpPanel` usa borda dourada. `Main._sync_weapons()` liga `AutoWeapon.chain_enabled`, `AuraWeapon.evolved` e `OrbitBlades.evolved`.

| Evolução | Requisitos | Código |
|---|---|---|
| Raio em cadeia | Raio + Projétil adicional 2 + Poder arcano 3 | `AutoWeapon._strike()`: `chain_targets` 2 vizinhos a até `chain_range` 4 m, `chain_damage_share` 0,6; 3 e ×1,25 se o alvo queimava |
| Coroa de cinzas | Aura 5 + Cadência 2 | raio ×1,15; cada pulso aplica queimadura de 40% do dano por 3 s; `crown` no shader |
| Vendaval de lâminas | Lâmina 5 + Passos ligeiros 2 | +2 lâminas (máximo 6); raio + 0,9·sen(1,6·t); corte aplica lentidão de 1,5 s e empurrão de 4 m/s para fora |

O Raio sempre empurra o alvo (`knockback` 1,2 m/s). **Pacto do eco** (`Upgrades.PACT`, até 3): dano ×(1 + 0,25·n), `xp_multiplier` 1 + 0,15·n, `Player.damage_taken_multiplier` 1 + 0,2·n. A XP extra passa por `Main._on_xp_collected()`, que guarda as frações.

### Chefe

`BossController`: estados novos `ATORDOADO` e `PREPARAR_PRISAO`. Ciclo dos ataques: investida → erupção → rajada → prisão. Fim da investida → `_set_vulnerable(true)` (`EnemyManager.boss_vulnerable`, sinal `vulnerability_changed`) e 2 s (`stun_time`) atordoado; depois volta a perseguir. Prisão: `prison_cells` 10 círculos a `prison_radius` 3,6 m do jogador, 2 vizinhos de fora (saída), aviso de `prison_windup` 1,3 s, 26 de dano. `attack_warned` sai no início de cada aviso (som). Primeiro reforço da fase 2: Tecelão.

### Eventos (`EventDirector`)

Usa `EnemyManager.elapsed`. Só começa eventos com `spawning_enabled` e antes de `stop()` (chamado no encontro final e no fim da partida). Define `spawn_rate_multiplier` a cada quadro: `base_rate` × maré (2,5) ou calmaria (0,25) × fenda (2, com o jogador dentro).

| Evento | Primeiro | Intervalo | Regra |
|---|---|---|---|
| Elite | 120 s | 75 s | `spawn_elite()`: tipo por `EnemyTypes.pick`, modificador aleatório, borda da tela |
| Fenda do Eco | 150 s | 165 s | raio 2,4 m; 6 s dentro em até 25 s → `rift_completed` (Main dá um nível e cura 20%); senão `rift_failed` |
| Maré | 240 s | 180 s | 15 s ×2,5, depois 10 s de calmaria ×0,25 |

### Configurações, pausa e joystick

`GameSettings` (versão 1, `user://configuracoes.json`, `static var path` para os testes): `mao`, `joystick_modo`, `joystick_tamanho` (0,8/1,0/1,25), `joystick_altura` (0,84/0,76/0,66 da tela), `som`, `tremor`, `numeros_dano`. Valor inválido volta ao padrão; arquivo inválido vira `.corrompido`. Gravação por arquivo temporário e renomeação.

`PauseMenu` (sempre ativo): botões que trocam cada opção, salvam e emitem `settings_changed`; Continuar, Esc ou P fecham. `Main.open_pause()` não abre por cima do level-up nem do fim de partida. `Main._apply_settings()` chama `FloatingJoystick.configure(escala, fixo, âncora)`, `Hud.set_left_handed()`, `CameraRig.shake_enabled`, `SoundBank.enabled`, `CombatFeedback.enabled`.

`FloatingJoystick`: no modo fixo o centro é `size × fixed_anchor` (x 0,72 destro, 0,28 canhoto); o centro não acompanha o dedo. `blocked_rects` (o botão de pausa, atualizado a cada quadro por `Main`) ignora toques que começam ali. O duplo toque é o mesmo em todos os modos.

`CameraRig`: em paisagem usa `KEEP_HEIGHT` com `landscape_view_height` 11 m (antes mostrava uma faixa fina); `shake(força, segundos)` desloca `h_offset`/`v_offset`.

### Som e retorno visual

`SoundBank` gera 12 `AudioStreamWAV` (16 bits, 22.050 Hz, mono) no `_ready()`, cada um a partir de uma função `_wave_<nome>`. Nenhum arquivo de áudio. 10 `AudioStreamPlayer` em rodízio; `MIN_GAP` por som evita repetição no mesmo instante. `GameFeel` conecta: abate (som + estouro colorido no chão, até 6 por quadro), golpe importante (som + número), explosão (som + tremor), dano ≥ 6 no jogador (som + tremor), esquiva, nível, orbe, aviso e fase do chefe. `CombatFeedback`: 24 `Label3D` reaproveitados, 0,7 s, sobem 1,4 m.

### Ponte de QA

`web_bridge.gd` (só na build Web QA) informa também `pausa` (aberta, retângulos do botão II, da opção "mão" e de Continuar, `canhoto`) e `joystick_ativo`.

## Limitações conhecidas

- **Sem teste em celular físico.** Os testes de navegador emulam toque e tela de Pixel 7 num Chromium de computador.
- **Equilíbrio medido só com piloto automático:** os números da versão vêm de simulações. Falta testar com pessoas (critério da fase 1).
- **Tela deitada:** na 0.4 a câmera passa a mostrar 11 m na vertical (antes, uma faixa fina); as interfaces continuam numa coluna central. Não testado em aparelho.
- **Destro/canhoto e ajuste do joystick:** implementados na 0.4 (PR #10); não testados em celular físico.
- **Orbes distantes** ficam no chão até o jogador passar perto.
- **Som provisório (procedural) e sem arte final.** O som da 0.4 não foi ouvido por uma pessoa nesta etapa.
