# Entrega para o ChatGPT

*Pacote de fatos técnicos da última entrega do Claude Code. Use para revisar a Wiki (`wiki-src/`) e o `docs/CHANGELOG.md`. Não é um artigo: são dados. O Claude Code **não** alterou o changelog nem a Wiki nesta etapa.*

## Identificação

| | |
|---|---|
| **Etapa** | 3: "O Despertar de Eudora" (a grande evolução do núcleo de gameplay) |
| **Versão do jogo** | **0.4-alpha** (quando integrada; até lá a oficial continua 0.3-alpha) |
| **Branch** | `feat/despertar-de-eudora-04` (a partir do `main` `7aba866`) |
| **Pull Request** | https://github.com/ederkm40/Cronicas-de-Eudora/pull/10 |
| **Prévia** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-10/ |
| **Relatório** | `docs/versoes/0.4-alpha/RELATORIO.md` |

**Importante para a Wiki:**

- As mecânicas novas são **propostas experimentais**, entregues para avaliação do proprietário. Só entram na Wiki como conteúdo do jogo **depois do merge do PR #10**, de preferência marcadas como experimentais.
- **Nada foi testado em celular físico nem por pessoas.**
- O som **não foi ouvido por uma pessoa**.

## Fatos para a Wiki (só depois do merge)

### Controles e configurações (`controles/`)

- O botão **"II"** fica no alto da tela, do lado oposto ao polegar, e abre a **pausa com configurações**. No computador, Esc ou P também pausam. A pausa não abre por cima do level-up nem da tela de resultados.
- **Opções:**
  - Mão: destro ou canhoto. O canhoto espelha o botão de pausa, o texto de estado, o indicador da esquiva e o lugar do joystick fixo.
  - Joystick: flutuante (como antes) ou fixo. No fixo, o toque começa em qualquer lugar, mas o centro fica parado do lado do polegar.
  - Tamanho: pequeno, médio ou grande (×0,8, ×1, ×1,25).
  - Altura do joystick fixo: alta, média ou baixa.
  - Som, tremor da tela e números de dano: ligado ou desligado.
- As escolhas ficam salvas no navegador (`configuracoes.json`), separadas do progresso.
- O duplo toque para esquivar funciona igual em todos os modos. Continua sem botões de ataque e de esquiva.
- Na tela deitada, a câmera mostra mais do mapa na vertical (11 m).

### Armas e evoluções (`armas/`)

- **Evolução** é uma carta dourada "EVOLUÇÃO" no level-up. Aparece quando a arma e as melhorias exigidas estão no nível certo, e cada arma evolui uma vez.

| Evolução | Requisito | Efeito |
|---|---|---|
| Raio em cadeia | Raio arcano + Projétil adicional 2 + Poder arcano 3 | cada acerto salta para 2 inimigos próximos (até 4 m) com 60% do dano; se o alvo estava queimando, salta para 3 com +25% |
| Coroa de cinzas | Aura de brasas nível 5 + Cadência 2 | +15% de raio; cada pulso queima por 3 s (40% do dano do pulso por segundo) |
| Vendaval de lâminas | Lâmina orbital nível 5 + Passos ligeiros 2 | +2 lâminas (até 6); a órbita aumenta e diminui; cada corte deixa o inimigo lento e o empurra |

- O Raio arcano agora **empurra** um pouco quem acerta.

### Melhorias (`progressao/`)

- **Pacto do eco** (nova, até 3 níveis): +25% de dano e +15% de experiência por nível, mas +20% de dano recebido.

### Inimigos (`inimigos/`)

| Nome | Surge | Vida | Comportamento |
|---|---|---|---|
| Tecelão | a partir dos 4:30 | ×2 | fica longe; inimigos a até 3,5 m dele recebem 40% menos dano (ficam ciano). Não protege a si mesmo nem o chefe |
| Semeador | a partir dos 5:30 | ×1,6 | a cada 4,5 s deixa uma poça de cinzas: aviso de 0,6 s, depois 12 de dano por segundo por 5 s |

- **Elites:** inimigos maiores e dourados, com 5× a vida e 1,5× o dano de contato. São anunciados na tela.

| Elite | Diferença |
|---|---|
| Veloz | 1,5× mais rápido |
| Blindado | recebe 30% menos dano |
| Gerador | chama 2 Errantes a cada 7 s |

  Derrotar um elite dá um orbe grande (12 de experiência) e cura 15.
- **Cores de estado:** laranja = queimando; azul = lento; ciano = protegido pelo Tecelão; dourado = elite.

### Chefe (`chefes/sentinela-do-eco`)

- Depois de cada **investida**, a Sentinela fica **atordoada por 2 s** e recebe **+50% de dano**. Aparece o aviso "Ponto fraco exposto: ataque agora!".
- **Novo ataque, Prisão de ecos:** um anel de círculos em volta do jogador, com **uma saída**. O aviso dura 1,3 s e quem fica em cima de um círculo leva 26.
- **Ordem dos ataques:** investida, erupção, rajada, prisão.
- O primeiro reforço da fase 2 é um Tecelão.

### Eventos da partida (página nova sugerida)

| Evento | Quando | O que acontece |
|---|---|---|
| Elite | 2:00 e depois a cada 1:15 | aparece um elite na borda da tela |
| Fenda do Eco | 2:30 e depois a cada 2:45 | um círculo roxo perto do jogador. Ficar **6 s dentro** (no total) em até 25 s dá **uma escolha extra de level-up** e 20% de vida. Enquanto o jogador está dentro, as hordas dobram |
| Maré da horda e Calmaria | 4:00 e depois a cada 3:00 | 15 s de hordas 2,5× mais rápidas, depois 10 s de calmaria (hordas a 25%) |

- Os eventos param quando começa o encontro final.

### Som e efeitos (`desenvolvimento/` ou página de interface)

- O jogo passa a ter **som**: 12 efeitos gerados pelo próprio jogo, sem arquivos de áudio. No navegador, o som começa depois do primeiro toque.
- Cada abate tem um estouro colorido no chão.
- Números de dano aparecem só nos golpes no chefe e em elites.
- A tela treme em explosões, em dano forte e nos momentos do chefe.
- Tudo isso pode ser desligado na pausa.

### Tela de resultados

- Linhas novas: elites derrotados, Fendas do Eco fechadas e armas evoluídas.
- A arma evoluída aparece com o nome da evolução.

### Testes (`desenvolvimento/testes.md`)

- **Godot:** 71 testes em 6 suítes; a nova `despertar.gd` tem 20 testes.
- **Smoke test:** força um elite e uma fenda e pausa por Esc.
- **Playwright:** teste novo da pausa pelo botão II, troca para canhoto e retomada pelo toque, nos 3 perfis.

### Problemas conhecidos (`desenvolvimento/problemas-conhecidos.md`)

- Chefe possivelmente fácil demais: o piloto automático venceu nas 3 simulações.
- O valor da Fenda do Eco não foi medido, porque o piloto não entra nela.
- O som é provisório e não foi ouvido por uma pessoa.
- O botão de pausa não foi conferido em telas com entalhe.
- O custo de processamento por quadro subiu de 10 a 20% em média em relação à 0.3, no servidor de testes. O FPS no celular não foi medido.
- Continua valendo: o texto da Atração do eco diz "raio de coleta" (o efeito é no ímã).
- Sai da lista depois do merge: "destro/canhoto e ajuste do joystick não implementados".

## Para o changelog (sugestão de itens, 0.4-alpha)

- **Adicionado:**
  - pausa com configurações (destro/canhoto, joystick fixo ou flutuante, tamanho, altura, som, tremor, números);
  - som;
  - números de dano no chefe e em elites;
  - estouro nos abates;
  - 3 evoluções de armas;
  - Pacto do eco;
  - Tecelão e Semeador;
  - elites;
  - eventos (Fenda do Eco, Maré e Calmaria);
  - Prisão de ecos e atordoamento do chefe.
- **Alterado:**
  - o Raio empurra;
  - câmera deitada;
  - novas linhas na tela de resultados.
- **Técnico:**
  - decisão 0012;
  - configurações em arquivo próprio;
  - estados de combate nos arrays do gerenciador de inimigos.

## Documento Mestre

- Versão **0.1.1**: os estados foram atualizados com esta etapa.
- Os elementos novos estão como `PROPOSTO_NAO_APROVADO (experimental)` · `EM_DESENVOLVIMENTO (PR #10)` · `TESTADO`.
- A personalização mobile está como `APROVADO` · `EM_DESENVOLVIMENTO (PR #10)` · `TESTADO`.
- Depois do merge, o código passa a `IMPLEMENTADO`. O design só passa a `APROVADO` com a palavra do proprietário.
- Os catálogos 03 (armas), 05 (passivos), 12 (inimigos) e 14 (chefes) ganharam as entradas novas.
