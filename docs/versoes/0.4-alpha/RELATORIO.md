# Relatório da versão 0.4-alpha: O Despertar de Eudora

| | |
|---|---|
| **Etapa** | 3: a grande evolução do núcleo de gameplay ("Operação: O Despertar de Eudora") |
| **Branch** | `feat/despertar-de-eudora-04`, criada a partir do `main` `7aba866` |
| **Pull Request** | https://github.com/ederkm40/Cronicas-de-Eudora/pull/10 (em revisão; **sem merge**) |
| **Prévia** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-10/ (build de produção; ver o comentário do workflow no PR) |
| **Data** | 26/11/2026 |
| **Situação das mecânicas** | propostas **experimentais** (`PROPOSTO_NAO_APROVADO`), entregues para avaliação. A personalização mobile já era `APROVADO`. Nada está `VALIDADO`: **não houve teste com pessoas nem em celular físico** |

## Objetivo

Dar ao protótipo da 0.3 mais **impacto**, **variedade** e **decisões de build**, sem perder o controle de um dedo e sem custo, mantendo 300 inimigos no navegador. Prioridade do proprietário: mobile e movimento.

## Auditoria inicial (antes de desenvolver)

Conferido no código do `main` `7aba866`:

| Área | Situação encontrada | Problema para a experiência |
|---|---|---|
| Impacto e retorno | só a piscada branca ao levar dano; nenhum som | os golpes não "pesam"; abates em massa não têm resposta |
| Builds | evolução só por nível (1–5); sinergias só numéricas | não há momento de "virada" da build nem decisão de risco |
| Inimigos | 5 tipos, todos atacam diretamente | sem suporte, sem controle de área, sem inimigos especiais |
| Chefe | 3 ataques avisados; janela de recuperação de 1,4 s | sem janela clara de contra-ataque; piloto não o derrotava |
| Variedade da partida | ritmo controlado só pelo tempo | as partidas são iguais entre si até os 10 min |
| Estados de combate | inexistentes | armas não se combinam |
| Mobile | joystick flutuante, sem configurações, sem pausa manual | destro/canhoto e ajuste do joystick aprovados e não feitos; não dava para pausar no celular |
| Câmera deitada | faixa fina do mapa | pouca leitura da horda no celular deitado |
| Arquitetura | `EnemyManager` com arrays + MultiMesh; perto dos limites do `gdlint` | qualquer sistema novo de inimigos precisa caber nos arrays |

Prioridades definidas: (1) mobile: pausa, configurações, destro/canhoto, joystick; (2) impacto: som, números, estouros, tremor; (3) builds: evoluções, estados, uma melhoria de risco; (4) ecossistema: 2 tipos novos e elites; (5) chefe com janela de vulnerabilidade e um ataque novo; (6) eventos que mudam o ritmo.

## Funcionalidades entregues

Cada item traz: problema, justificativa, compatibilidade, impacto, riscos, estratégia e critério de teste.

### 1. Configurações mobile e pausa (diretriz `APROVADO`)

- **Problema:** destro/canhoto, preferência salva e ajuste do joystick estavam aprovados e não implementados. Também não havia como pausar no celular.
- **Entrega:**
  - botão "II" no canto de cima (76 × 64), do lado oposto ao polegar, que abre a pausa com as configurações;
  - opções: mão (destro/canhoto), joystick flutuante ou fixo, tamanho (pequeno ×0,8 · médio · grande ×1,25), altura do joystick fixo (alta, média, baixa), som, tremor da tela e números de dano;
  - as escolhas são salvas em `user://configuracoes.json`;
  - no computador, Esc ou P pausa e retoma.
- **Justificativa:** pedido explícito do proprietário (seção 7.2 do Documento Mestre).
- **Compatibilidade:**
  - o duplo toque e a esquiva continuam iguais em todos os modos;
  - continua sem botões de ataque e de esquiva;
  - o toque que começa no botão de pausa não liga o joystick;
  - a pausa não abre por cima do level-up nem da tela de resultados.
- **Impacto:** quem joga com a mão esquerda passa a ter o botão e o joystick fixo do lado certo.
- **Riscos:** o botão pode ficar perto de bordas arredondadas ou do entalhe de alguns celulares. Isso não foi medido em aparelho.
- **Estratégia:** um arquivo separado do progresso, com versão, gravado num arquivo temporário e renomeado. Um arquivo quebrado vira cópia `.corrompido` e um valor inválido volta ao padrão.
- **Testes:**
  - Godot: salvar e ler, valor inválido, arquivo quebrado, canhoto espelhado, centro fixo do joystick, tamanho, pausa pelo botão e por Esc, bloqueio por cima do level-up, toque no botão de pausa;
  - Playwright, nos 3 perfis: tocar em II, trocar para canhoto, tocar em Continuar, o botão muda de lado e o joystick volta a andar.

### 2. Retorno de combate (experimental)

- **Problema:** golpes e abates sem resposta sensorial.
- **Entrega:**
  - **som gerado no código:** 12 sons (golpe, abate, orbe, dano, explosão, esquiva, nível, alerta, evolução, fenda, chefe, vitória), sem nenhum arquivo de áudio;
  - estouro colorido no chão em cada abate (até 6 por quadro);
  - números de dano **só** em golpes no chefe e em elites;
  - tremor de câmera em explosões, dano forte, fase do chefe, elites e início do encontro.
- **Justificativa:** impacto sem poluir a tela. Com 300 inimigos, números em todos os golpes encobririam a horda.
- **Compatibilidade:** som, tremor e números podem ser desligados. Nada muda as regras do jogo (tudo passa pelo `GameFeel`).
- **Riscos:**
  - **o som não foi ouvido por uma pessoa:** só foi conferido por teste que ele é gerado e toca;
  - no navegador, o áudio só começa depois do primeiro toque (regra dos navegadores);
  - os sons são provisórios.
- **Testes:** os 12 sons existem e têm dados; intervalo mínimo entre repetições; som desligado não toca; o abate toca som; estouros por abate; números só em elite/chefe; números somem; números desligados.

### 3. Evoluções de armas e Pacto do eco (experimental)

- **Problema:** a build não tinha um momento de transformação nem decisões de risco.
- **Entrega:**
  - três evoluções, oferecidas como **carta dourada "EVOLUÇÃO"** quando os requisitos são cumpridos (peso 5 no sorteio, uma vez por arma):
    - **Raio em cadeia** (Raio + Projétil adicional 2 + Poder arcano 3): salta para 2 vizinhos com 60% do dano, ou para 3 com +25% se o alvo está queimando;
    - **Coroa de cinzas** (Aura 5 + Cadência 2): +15% de raio, e o pulso queima;
    - **Vendaval de lâminas** (Lâmina 5 + Passos ligeiros 2): +2 lâminas, órbita que "respira", corte que deixa lento e empurra;
  - **Pacto do eco** (até 3): +25% de dano e +15% de XP, mas +20% de dano recebido.
  - O Raio empurra quem acerta (1,2 m/s).
- **Justificativa:** dar uso às passivas pouco escolhidas na 0.3 (Passos ligeiros) e criar a sinergia Raio + Aura.
- **Compatibilidade:**
  - as evoluções usam o mesmo caminho das ofertas (trocar e bloquear funcionam);
  - a carta mostra os requisitos cumpridos;
  - o HUD e a tela de resultados mostram o nome da evolução.
- **Riscos:** a Coroa de cinzas é a evolução mais forte (+52% de dano na medição); o Vendaval rende pouco em dano direto (+23%) e vale mais pelo controle.
- **Testes:** requisitos, evolução única, carta EVOLUÇÃO, saltos da cadeia, queimadura que continua depois do pulso, +2 lâminas e raio variável, lentidão, efeitos e limite do Pacto, XP fracionada (20 viram 23).

### 4. Estados de combate (experimental)

- **Entrega:** queimadura, lentidão, empurrão, escudo e vulnerabilidade (chefe atordoado), guardados em arrays do `EnemyManager` (decisão 0012). Cada estado tem uma cor por inimigo (laranja, azul, ciano, branco no chefe).
- **Riscos:** com muitos estados ao mesmo tempo, a cor de cada inimigo mostra um só, em ordem de prioridade: elite → queimando → lento → escudo.
- **Testes:** aplicação, duração e efeito de cada um (suíte `despertar.gd`).

### 5. Ecossistema de inimigos (experimental)

- **Tecelão** (a partir dos 4:30): fica longe e dá escudo de −40% aos vizinhos a até 3,5 m (não a si nem ao chefe). Cria uma prioridade de alvo.
- **Semeador** (a partir dos 5:30): deixa poças de cinzas (aviso de 0,6 s, 12/s, 5 s). Controla o espaço e obriga o jogador a se mover.
- **Elites** (Veloz, Blindado, Gerador): vida ×5, maiores e dourados, anunciados na tela. Recompensa: orbe de 12, cura de 15.
- **Riscos:** o Gerador pode encher a tela se for ignorado (2 Errantes a cada 7 s). O limite de 300 inimigos continua valendo.
- **Testes:** vida e armadura do Blindado, recompensa, Gerador invoca, escudo só nos vizinhos (6 de 10 de dano), poças que avisam antes de ferir e somem.

### 6. Chefe (experimental)

- **Entrega:**
  - atordoado por 2 s depois de cada investida, recebendo +50%, com o aviso "Ponto fraco exposto: ataque agora!";
  - 4º ataque, a **Prisão de ecos**: anel de 10 círculos com uma saída de 2, aviso de 1,3 s, 26 de dano;
  - o primeiro reforço da fase 2 é um Tecelão;
  - um alerta sonoro no início de cada aviso.
- **Justificativa:** "vida alta não substitui mecânica". A investida passa a ter recompensa para quem desvia e contra-ataca.
- **Riscos:** com o piloto automático, o chefe passou a ser derrotado em todas as rodadas (ver as simulações). **Pode ter ficado fácil demais.**
- **Testes:** atordoamento, +50% de dano, retorno à perseguição, aviso da prisão, saída de 2 círculos, centro seguro, dano em cima de um círculo.

### 7. Eventos da partida (experimental)

- **Elite:** aos 2:00 e depois a cada 1:15.
- **Fenda do Eco:** aos 2:30 e depois a cada 2:45. Quem fica 6 s dentro em até 25 s ganha um nível de escolha e 20% de vida, mas as hordas dobram enquanto o jogador está dentro.
- **Maré e Calmaria:** aos 4:00 e depois a cada 3:00. 15 s de hordas ×2,5, depois 10 s a ×0,25.
- Os eventos param no encontro final. O HUD mostra o progresso da fenda e a maré.
- **Riscos:** o piloto automático não entra na fenda (0 de 3 em cada partida), então o valor real dela não foi medido.
- **Testes:** fenda completada (nível extra) e fenda perdida por prazo; maré, calmaria e volta ao normal; tudo cancelado no encontro final.

### 8. Câmera deitada

- Em paisagem, a câmera passa a manter 11 m de altura visível (antes, uma faixa fina).
- Não testado em aparelho.
- Os testes Playwright em paisagem passam.

## Valores principais

| Sistema | Valor |
|---|---|
| Elite | vida ×5, tamanho ×1,45, contato ×1,5; Veloz ×1,5 de velocidade; Blindado −30% de dano; Gerador 2 Errantes/7 s |
| Tecelão | vida ×2, 1,9 m/s, contato 5, XP 3, distância 7–9,5 m, escudo −40% a 3,5 m, entrada 270 s, peso até 0,07 |
| Semeador | vida ×1,6, 2,1 m/s, contato 6, XP 3, poça a cada 4,5 s (raio 1,6, 12/s, 5 s), entrada 330 s, peso até 0,09 |
| Chefe | atordoado 2 s com +50%; prisão 10 círculos, raio 3,6 m, aviso 1,3 s, 26 de dano |
| Raio | empurrão 1,2 m/s; cadeia: 2 alvos, 4 m, 60% |
| Pacto do eco | +25% dano, +15% XP, +20% dano recebido, máximo 3 |
| Fenda | raio 2,4 m, 6 s em 25 s, hordas ×2 dentro |
| Maré | ×2,5 por 15 s; calmaria ×0,25 por 10 s |

### Ajustes feitos com base nas medições

| Antes | Medição | Depois |
|---|---|---|
| empurrão do Raio 2,5 m/s; elite com vida ×8 | `--modo=partida`, semente 1: derrota aos 10:57, **nível 10, 583 abates** (0.3: 9:11, nível 15, 1.192 abates) | testes isolados: sem empurrão → 748 abates; sem eventos → 883; sem os dois → 1.692. Os dois atrasavam a experiência |
| — | — | empurrão 1,2 m/s e elite com vida ×5 → semente 1: 10:38, nível 20, 2.008 abates |
| escudo do Tecelão também no chefe | `--modo=chefe`, semente 1: o chefe não foi derrotado em 5 min | o escudo não protege o chefe → vitória em 263 s |

## Arquivos

- **Novos:**
  - `scripts/event_director.gd`
  - `scripts/hazard_zones.gd`
  - `scripts/sound_bank.gd`
  - `scripts/combat_feedback.gd`
  - `scripts/game_feel.gd`
  - `scripts/game_settings.gd`
  - `scripts/pause_menu.gd`
  - `tests/suites/despertar.gd`
  - `docs/decisoes/0012-nucleo-de-gameplay-04.md`
  - este relatório
- **Alterados (jogo):**
  - `enemy_types.gd`, `enemy_manager.gd`, `boss_controller.gd`
  - `auto_weapon.gd`, `aura_weapon.gd`, `orbit_blades.gd`
  - `weapon_catalog.gd`, `arsenal.gd`, `level_up_offers.gd`, `level_up_panel.gd`, `upgrades.gd`
  - `player.gd`, `camera_rig.gd`, `floating_joystick.gd`, `hud.gd`
  - `run_stats.gd`, `results_screen.gd`, `main.gd`
  - `web_bridge.gd` (só QA)
- **Alterados (testes):**
  - `tests/run_tests.gd`, `tests/suites/base.gd`, `progressao.gd`, `armas_e_ofertas.gd`
  - `tests/smoke_test.gd`, `tests/long_simulation.gd`, `tests/balance_simulation.gd`
  - `tools/e2e/testes/jogabilidade.spec.js`
- **Documentação:**
  - `docs/TECNICO.md`, `docs/ROADMAP.md` (só a situação)
  - `docs/design/DOCUMENTO_MESTRE_SISTEMAS.md` (estados), catálogos 03, 05, 12 e 14
  - `docs/decisoes/README.md`
  - `docs/IA/*`
- **Não alterados** (papel do ChatGPT): `wiki-src/` e `docs/CHANGELOG.md`.

## Testes e resultados reais

### Godot (local, Godot 4.7.2 sem tela)

| Teste | Resultado |
|---|---|
| `tests/run_tests.gd` | **71 testes, 4.613 verificações, 0 falhas** (6 suítes; a nova `despertar.gd` tem 20 testes) |
| `tests/smoke_test.gd` | **OK**: 60 s, joystick, D, Espaço, ofertas, elite e fenda forçados aos 20 s, pausa por Esc aos 40 s; 129 a 155 sons tocados, 65 a 84 estouros |
| `tests/long_simulation.gd` (600 s, reinícios) | **OK**: 4 mortes e reinícios, nós constantes (187), memória +13,2 MB |
| `tests/long_simulation.gd --segundos=720 --invulneravel --armas-maximas` | **OK**: 301 inimigos, 400 orbes, chefe presente, nós constantes, memória +13,8 MB |
| Regressão: testes antigos | os 51 testes da 0.3 e da manutenção continuam passando. Ajustei 3 contagens que dependiam do número de ofertas: o Pacto e as evoluções entram no sorteio |
| Save | os 5 testes de save da manutenção passam; as configurações têm o próprio teste de arquivo inválido |
| Wiki e site | `tools/wiki/test_wiki.py` OK, `tools/site/test_montar_site.py` OK (sem mudança nesses arquivos) |

### Exportação Web e navegador (local, Chrome + Xvfb)

| Teste | Resultado |
|---|---|
| `construir_parte.sh` (produção) e `construir_qa.sh` (QA) | exportaram sem erro |
| `verificar_producao.sh` | ponte no `.pck`: produção 0 · QA 3 → OK |
| Playwright na build QA | 21 aprovados e 3 pulados antes do teste novo; o teste novo da pausa passou nos 3 perfis (3 aprovados) |
| Playwright na build de produção | 11 aprovados, 1 pulado |

### CI (GitHub Actions, `ubuntu-latest`)

Os resultados do CI (gdlint, gdformat, testes, exportações, Playwright e prévia) estão no PR #10. Duas falhas de estilo apareceram no caminho e foram corrigidas com novos commits: a ordem das definições exigida pelo `gdlint` e a formatação do `gdformat`.

## Simulações e balanceamento

Piloto automático de `tests/balance_simulation.gd`. **É um piloto simples, não uma pessoa.** Prioridade de escolha: evoluções, armas novas, dano, cadência… e o Pacto por último.

### Comparação de armas (`--modo=dps`, 60 s por carga, horda dos 240 s)

| Carga | 0.3 | 0.4 |
|---|---|---|
| Raio (nível 1) | 18/s | 17/s |
| Raio + Aura 5 | 144/s | 129/s |
| Raio + Lâmina 5 | 176/s | 194/s |
| Raio + Aura 5 + Lâmina 5 | 220/s | 230/s |
| Raio + Projétil 2 + Poder 3 → **Raio em cadeia** | — | 73/s → **161/s** |
| Aura 5 + Cadência 2 → **Coroa de cinzas** | — | 204/s → **311/s** |
| Lâmina 5 + Passos 2 → **Vendaval de lâminas** | — | 71/s → **87/s** |

As cargas sem evolução ficaram próximas da 0.3: a variação vem do empurrão e da mistura nova de inimigos. A queda da Lâmina 5 com Passos 2 (71/s contra 194/s sem Passos) mostra o quanto o caminho do piloto pesa nessa medição: mais rápido, ele passa por menos inimigos.

### Partidas completas (`--modo=partida`)

| Semente | Escolha | 0.3 | 0.4 | Eventos (0.4) |
|---|---|---|---|---|
| 1 | prioridade | derrota 9:11, nível 15, 1.192 abates | derrota **10:38**, nível 20, 2.008 abates, dano recebido 391 | 4 elites, fendas 0/3, 2 marés, 1 evolução |
| 2 | prioridade | derrota 9:27, nível 18 | derrota **13:06** (chegou ao chefe), nível 13, 749 abates, 164 | 4 elites, 0/3, 2 marés, 0 evoluções |
| 3 | prioridade | derrota 12:37 (chegou ao chefe), nível 22 | derrota **12:38** (chegou ao chefe), nível 19, 1.834 abates, 279 | 5 elites, 0/3, 2 marés, 1 evolução |
| 4 | aleatória | derrota 9:41, nível 16 | derrota 10:28 (chegou ao chefe), nível 17, 1.266 abates | — |

Leitura: o piloto sobrevive um pouco mais (o empurrão e a calmaria ajudam) e chega ao chefe em 3 das 4 rodadas. O piloto não usa a fenda, então o ganho real dela não foi medido.

### Encontro final (`--modo=chefe`, build típica dos 10 min)

| Semente | 0.3 | 0.4 |
|---|---|---|
| 1 | vitória, 140 s | **vitória**, 263,5 s, dano recebido 136 |
| 2 | derrota | **vitória**, 165,7 s, 111 |
| 3 | derrota | **vitória**, 181,1 s, 96 |

Na 0.4, o piloto ganha da Sentinela nas 3 rodadas. Os motivos são a janela de +50% depois de cada investida e as evoluções conquistadas durante a luta (2 a 3). **É o primeiro número a revisar com pessoas.** Se o chefe ficar fácil demais, as opções são reduzir o bônus (`EnemyManager`, ×1,5) ou o tempo atordoado (`stun_time`, 2 s).

## Desempenho

Tempo de CPU por quadro na `long_simulation`, no mesmo servidor, uma rodada depois da outra (**não representa um celular**):

| Medição | Média | p95 | p99 | Pior | Máximos |
|---|---|---|---|---|---|
| `main` (0.3), 600 s, piloto padrão | 1,48 ms | 3,33 ms | 3,81 ms | 13,1 ms | 300 inimigos, 19 efeitos |
| 0.4, 600 s, piloto padrão | 1,64–1,83 ms | 3,71–4,12 ms | 5,05–5,17 ms | 54 ms* | 301 inimigos, 25 efeitos |
| 0.4, 720 s, invulnerável, Aura 5 + Lâmina 5, com o chefe | 3,29 ms | 5,42 ms | 6,03 ms | 59 ms* | 301 inimigos, 400 orbes, 21 projéteis inimigos |

\* O pior quadro é **o primeiro**, quando o jogo gera os 12 sons (~55 ms, uma vez ao abrir). Confirmei registrando cada quadro acima de 20 ms: só o quadro 0. Os sons ficam guardados entre partidas, e "Jogar de novo" não os gera de novo.

- O custo médio subiu cerca de 10 a 20% em relação à 0.3, e o p99 cerca de 33%. Isso vem dos estados por inimigo, do escudo recalculado a cada quadro e de mais cores por instância.
- Os nós na árvore são constantes (187, antes 114), sem crescer entre reinícios. A diferença vem dos 24 números de dano, das 10 vozes de som e da tela de pausa, criados uma vez.
- **O FPS no celular continua sem medição.**

## Problemas encontrados no caminho

- **Coordenadas do toque nos testes:** na janela pequena do modo sem tela, a posição de um toque não coincide com a posição da interface. Os testes novos convertem o ponto da interface para a janela (`_window_point`).
- **Tocar no botão de pausa pausa o jogo:** um teste esperava só "não ligar o joystick". O comportamento certo é pausar, e o teste foi corrigido.
- **XP fracionada:** 20 × 1,15 dava 22,999… e virava 22. Corrigido com uma pequena tolerância.
- **Escudo no chefe:** o reforço Tecelão protegia o chefe e travava a luta. O chefe deixou de receber escudo.
- **Lint e formatação no CI:** ordem das definições (`gdlint`) e formatação (`gdformat`). Corrigidos com novos commits.

## Limitações conhecidas

- **Nada foi testado em celular físico nem por pessoas.** Os testes de navegador emulam toque e tela de Pixel 7 num Chromium de computador.
- **Som:** procedural e provisório; não foi ouvido por uma pessoa nesta etapa.
- **Chefe** possivelmente fácil demais (piloto 3/3).
- **Fenda do Eco:** valor real não medido (o piloto não entra).
- **Botão de pausa:** não foi conferido em telas com entalhe ou bordas arredondadas.
- O `EnemyManager` chegou a 20 métodos públicos (limite do `gdlint`) e 890 linhas.
- Continua: o texto da Atração do eco diz "raio de coleta" (o efeito é no ímã); orbes distantes ficam no chão.

## Pendências e próximos passos

1. Teste com 5 a 10 pessoas no celular: chefe, fenda, elites, Pacto, som, botão de pausa e joystick fixo.
2. Medir o FPS no celular com a horda cheia.
3. Decidir quais mecânicas experimentais ficam (o proprietário aprova ou rejeita cada uma).
4. Wiki e changelog: dados em `docs/IA/ENTREGA_PARA_CHATGPT.md` (tarefa do ChatGPT).
