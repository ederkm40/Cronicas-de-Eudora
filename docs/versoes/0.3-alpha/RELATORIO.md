# Relatório da versão 0.3-alpha: grande expansão do combate

| | |
|---|---|
| **Data** | 26/11/2026 |
| **Versão** | 0.3-alpha (em revisão) |
| **Branch** | `feat/grande-expansao-combate-03` (a partir do `main` `70cf85f`, com o PR #4 integrado) |
| **Pull Request** | https://github.com/ederkm40/Cronicas-de-Eudora/pull/5 |
| **Prévia do jogo** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-5/ |
| **Prévia da Wiki** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-5/wiki/ |
| **Commit final** | o último da branch (ver o PR); os resultados de CI abaixo citam o commit de cada execução |

## Objetivo

Evoluir o combate de ponta a ponta: duas armas novas com espaços próprios, ofertas de armas no level-up com troca e bloqueio, quatro tipos de inimigo com comportamentos diferentes, um chefe no encontro dos 10 minutos, esquiva pelo joystick, vitória com tela de resultados e a primeira camada de progressão entre partidas. Tudo testado de forma automática e medido com simulações.

## Auditoria inicial (antes de desenvolver)

- `main` em `70cf85f` (PR #4 integrado em 26/11/2026); CI do `main` e publicação concluídos com sucesso (execução 45845052018).
- Sistemas existentes conferidos no código: jogador e joystick, uma arma (`AutoWeapon`), um tipo de inimigo (`EnemyManager`, arrays + MultiMesh), orbes, progressão, 6 melhorias, HUD com tela de derrota, reinício por recarga da cena. **Não havia:** encontro final, vitória, persistência, configurações.
- Problemas encontrados:
  - **Colisão dos projéteis:** cada projétil comparava com todos os inimigos a cada quadro (até 256 × 300). Corrigido com a grade espacial já existente.
  - **Sem cura constante:** a vida só subia escolhendo Núcleo vital. Nas simulações, o piloto morria antes dos 5 minutos com 100 de vida total.
  - **Testes não falhavam com erro de script:** um erro no meio de um teste aparecia no log, mas o resultado era "OK". Corrigido com `tools/ci/rodar_godot.sh`.
  - **Interfaces largas na tela deitada:** cartões e barras atravessavam a tela inteira. Corrigido com colunas de largura fixa.
  - O arquivo citado como `docs/IA/MAPA_PROJETO.md` no pedido se chama `docs/IA/MAPA_DO_PROJETO.md`; foi esse o atualizado.

## Funcionalidades entregues

### 0.3 (escopo completo)

- **Arsenal extensível:** `WeaponCatalog` (definição), `Arsenal` (estado, 4 espaços), um nó por arma (execução e visual), colisão e dano pelo `EnemyManager` (decisão 0010).
- **Aura de brasas:** pulsos de dano em área (nunca por quadro), 5 níveis, visual de borda de brasas com onda a cada pulso.
- **Lâmina orbital:** 1 a 4 lâminas em órbita, recarga de 0,35 s por inimigo (várias lâminas não acertam o mesmo inimigo no mesmo instante), 5 níveis, visual de lâmina com rastro e anel da órbita.
- **Level-up:** ofertas de arma nova, evolução e melhoria, com o tipo escrito no cartão; sem duplicatas nem opções inválidas; **trocar opções** (2 por partida) e **bloquear** (2 por partida), independentes.

### Antecipado da 0.4

- **4 tipos de inimigo** com atributos, comportamento e visual próprios: Espreitador (rápido, mira à frente), Couraçado (5× vida, ignora 35% do dano), Lançador (mantém distância, para e brilha antes de atirar, só atira de dentro da tela), Volátil (acende o pavio com círculo de aviso e explode; pode ser eliminado antes).
- **Entrada gradual** por tempo (45 s, 100 s, 150 s, 210 s).
- **Chefe (Sentinela do Eco)** aos 10 minutos: máquina de estados, investida, erupção e rajada com avisos, fase 2 com reforços, barra de vida, brilho nos avisos e piscada de dano.

### Antecipado da 0.5

- **Esquiva** por duplo toque no joystick (sem botão), com direção pelo gesto, recarga, invulnerabilidade, anel no chão e indicador no HUD; tecla Espaço no computador.
- **Pendente da 0.5:** opções de destro/canhoto e ajuste do joystick (não implementado; os parâmetros já são `@export` em `FloatingJoystick`).

### Antecipado da 0.6

- **Vitória ao derrotar o chefe** (a partida não termina sozinha aos 10 minutos), **tela de resultados** com estatísticas reais, derrota integrada à mesma tela, **reinício limpo** (testado).
- **Pendente da 0.6:** equilíbrio a partir de testes com pessoas.

### Progressão entre partidas (primeira camada)

- **Ecos:** 1 a cada 20 s, 1 a cada 15 abates, 40 por chefe derrotado.
- **4 melhorias permanentes** (vida, dano, ímã de orbes, trocas extras), compradas na tela de resultados.
- **Save versionado** em `user://progresso.json` com escrita atômica, migração, proteção contra versão futura e contra arquivo corrompido. Não existia save antes desta versão.

### Adicionais

- Cura de 12% da vida a cada nível ganho.
- HUD: linha das armas com níveis, barra do chefe, avisos no meio da tela, indicador de esquiva; coluna central na tela deitada.
- Raio arcano mira o chefe quando ele está ao alcance.
- Ponte de testes `?teste=1` (`WebBridge`) e testes de navegador com controles reais.
- Simulação de balanceamento (`tests/balance_simulation.gd`).

## Valores

Todos em `scripts/` (ver `docs/TECNICO.md` para as tabelas completas):

| Item | Valor |
|---|---|
| Aura de brasas, nível 1 → 5 | dano 6 → 14, raio 2,2 → 3,2 m, pulso 0,6 → 0,45 s |
| Lâmina orbital, nível 1 → 5 | dano 14 → 26, lâminas 1 → 4, raio 1,9 → 2,5 m, giro 3,2 → 4,0 rad/s, recarga por inimigo 0,35 s |
| Inimigos (vida × base, velocidade, contato) | Errante 1×, 2,2, 9/s · Espreitador 0,45×, 4,3, 7/s · Couraçado 5×, 1,35, 15/s (35% de resistência) · Lançador 1,2×, 2,4, 6/s (tiro 8 a cada ~3,2 s) · Volátil 0,9×, 3,0, 6/s (explosão 26, raio 2,4 m, pavio 0,85 s) |
| Crescimento da vida dos inimigos | +35% por minuto (era 60%) |
| Leva | +1 inimigo a cada 30 s (era 25 s) |
| Chefe | 3.800 de vida; investida 28; erupção 30; rajada 14 × 12; contato 24/s; fase 2 abaixo de 50% |
| Esquiva | 4 m em 0,18 s; invulnerável 0,32 s; recarga 1,4 s; duplo toque: toque ≤ 0,22 s, intervalo ≤ 0,32 s, distância ≤ 140 |
| Cura por nível | 12% da vida máxima |
| Encontro final | aos 600 s; hordas a 30% do ritmo e sem Lançadores novos (os que já estão em campo continuam) |

## Arquivos

| Novos | Alterados |
|---|---|
| `scripts/`: `weapon_catalog.gd`, `arsenal.gd`, `aura_weapon.gd`, `orbit_blades.gd`, `level_up_offers.gd`, `enemy_types.gd`, `enemy_projectiles.gd`, `ground_effects.gd`, `boss_controller.gd`, `run_stats.gd`, `meta_progress.gd`, `results_screen.gd`, `web_bridge.gd` (+ `.uid`) | `scripts/`: `main.gd`, `enemy_manager.gd`, `player.gd`, `floating_joystick.gd`, `auto_weapon.gd`, `upgrades.gd`, `level_up_panel.gd`, `hud.gd` |
| `tests/suites/` (`base.gd` + 4 suítes), `tests/balance_simulation.gd` | `tests/run_tests.gd` (vira executor), `tests/smoke_test.gd`, `tests/long_simulation.gd` |
| `tools/ci/rodar_godot.sh`, `tools/e2e/testes/jogabilidade.spec.js`, `tools/e2e/testes/ajudantes.js` | `.github/workflows/publicar.yml` (só os comandos das 3 etapas do Godot e os nomes), `tools/ci/verificar_gdscript.sh` (mostra o diff do gdformat), `tools/e2e/README.md` |
| `docs/versoes/0.3-alpha/RELATORIO.md`, `docs/decisoes/0010-combate-03-arquitetura.md` | `AGENTS.md`, `CLAUDE.md`, `docs/TECNICO.md`, `docs/ROADMAP.md`, `docs/CHANGELOG.md` (entrada nova, para revisão do ChatGPT), `docs/IA/*`, `docs/decisoes/README.md` |

Sem mudança: `scenes/`, `project.godot`, `export_presets.cfg`, jobs `publicar` e `remover-previa`, `wiki-src/`.

## Testes e resultados reais

### Testes do Godot (41 testes, 4 suítes)

| Suíte | Testes |
|---|---|
| `progressao.gd` (0.2) | 16: XP, coleta, level-up, opções, 6 efeitos, limites, pausa e retomada, derrota, reinício |
| `armas_e_ofertas.gd` | 9: espaços independentes e limites do Arsenal; aura (pulsos, alcance, dano, sinergias); aura contra 80 inimigos num pulso; lâmina (órbita, giro, dano por corte, 1 × 4 lâminas, limite da recarga); níveis 1–5 e o 6º recusado; ofertas válidas e distintas em 400 sorteios; menos de 3 válidas; XP preservada; troca (sem repetir, contador, botão); bloqueio (substituição, nunca volta, última opção protegida, partida nova limpa) |
| `inimigos_e_chefe.gd` | 7: mistura por tempo (pesos e hordas reais aos 400 s); velocidades e resistência; Lançador (recua, aviso antes do tiro, acerta, não atira de fora da tela); Volátil (aviso, explosão de 26, sem abate nem orbe; eliminado antes não explode e deixa orbe; fugindo do raio não leva dano); chefe surge aos 600 s (não antes), barra cheia, a partida não termina sozinha, hordas mais lentas e sem Lançadores novos; investida, erupção e rajada com aviso antes; fase 2, reforços, barra, vitória só com o chefe derrotado |
| `esquiva_e_encerramento.gd` | 9: Espaço (4 m, para a frente, recarga, com D para a direita); invulnerabilidade e recarga; duplo toque e peteleco (direção); intervalos de 2, 6, 12, 18 quadros esquivam e 25, 40 não; sem esquiva acidental (joystick girando, toques distantes, toque segurado, arrasto lento, menu aberto); derrota com estatísticas conferidas (abates, dano causado = vida tirada, dano recebido, Ecos salvos); reinício após vitória sem resíduos (chefe, inimigos, projéteis, efeitos, armas, estatísticas, ofertas, relógio); save, compra, bônus aplicados; migração, versão futura e arquivo corrompido |

### CI (GitHub Actions, `ubuntu-latest`)

Execução 45858257785, commit `996ac94` (último commit de código; depois dele só entra esta atualização do relatório):

| Etapa | Resultado |
|---|---|
| `gdlint scripts tests` | Success: no problems found |
| `gdformat --check` | 30 arquivos alterados, todos sem mudança |
| `run_tests.gd` | 41 testes, 4.370 verificações, 0 falhas |
| `smoke_test.gd` | SMOKE TEST: OK |
| `long_simulation.gd --segundos=300` | OK; CPU por quadro: média 2,17 ms, p95 5,56 ms, p99 5,80 ms, pior 15,3 ms; até 300 inimigos |
| Wiki e site | 14 e 7 testes, OK |
| Playwright (3 perfis) | 18 aprovados, 3 pulados de propósito (toque no computador; Espaço nos perfis de celular), Mesa/llvmpipe |
| Prévia | verificada no ar (jogo e Wiki com o commit `996ac94`) |

O commit de documentação que vem depois roda o mesmo workflow; o resultado dele aparece no PR #5.

### Navegador (controles reais)

`jogabilidade.spec.js`, nos 3 perfis: joystick arrastado move o personagem (sem esquivar); dois toques com 0,7 s de intervalo não esquivam; o duplo toque esquiva uma vez; Espaço esquiva (computador); level-up tocando em Trocar, Bloquear e num cartão (contadores, pausa e arma adquirida conferidos); vitória contra o chefe e "Jogar de novo" tocado (partida nova sem resíduos); derrota e reinício tocado. Também rodou localmente (Chrome + Xvfb) com 13 aprovados e 2 pulados.

## Simulações e balanceamento

Ferramenta: `tests/balance_simulation.gd`. Piloto automático: foge dos inimigos próximos, sai dos círculos de aviso, busca orbes, esquiva quando leva muito dano ou fica cercado, e escolhe ofertas (prioridade: armas novas, evolução, dano, cadência… ou aleatório). **É um piloto simples, não uma pessoa.**

### Comparação de armas (`--modo=dps`)

Horda mista dos 240 s, jogador invulnerável andando em círculo, sem melhorias passivas, 60 s por carga:

| Carga | Dano total por segundo | Detalhe |
|---|---|---|
| Raio (nível 1) | 18 | Raio 18/s |
| Raio + Aura 1 | 45 | Aura 36/s |
| Raio + Aura 3 | 66 | Aura 59/s |
| Raio + Aura 5 | 144 | Aura 126/s |
| Raio + Lâmina 1 | 40 | Lâmina 27/s |
| Raio + Lâmina 3 | 72 | Lâmina 61/s |
| Raio + Lâmina 5 | 176 | Lâmina 157/s |
| Raio + Aura 5 + Lâmina 5 | 220 | Aura 87/s, Lâmina 114/s |

Leitura: as duas armas novas ficam equivalentes nos níveis 1 e 3; no nível 5 a Lâmina rende um pouco mais (4 lâminas) e a Aura limpa melhor quem encosta. O Raio sozinho é fraco nesta medição porque cresce pelas melhorias passivas, que aqui ficaram de fora: na partida com escolhas aleatórias (semente 4), com Poder arcano e Projétil adicional, o Raio chegou a 75/s e foi a arma que mais matou.

Primeira medição, antes dos ajustes (Aura até 16 de dano e 3,5 m): Aura 5 = 186/s contra Lâmina 5 = 138/s, e a Lâmina 3 só rendia 54/s. A Aura foi reduzida e os níveis 2–3 da Lâmina subiram.

### Partidas completas (`--modo=partida`)

| Rodada | Configuração | Resultado |
|---|---|---|
| Antes dos ajustes | vida +60%/min, sem cura, sementes 1–2 | derrota aos 4:39 e 6:53 (níveis 10 e 13); todo o dano recebido era de contato |
| 2ª | vida +40%/min, sementes 1–3 | derrota aos 6:25, 5:41 e 6:31 (níveis 13–17) |
| **Final** | vida +35%/min, cura de 12% por nível, Lançador mais lento | ver abaixo |

| Semente | Escolha | Resultado final | Nível | Abates | Esquivas | Dano recebido |
|---|---|---|---|---|---|---|
| 1 | prioridade | derrota aos 9:11 | 15 | 1.192 | 31 | 202 (contato 138, Lançador 64) |
| 2 | prioridade | derrota aos 9:27 | 18 | 1.559 | 19 | 239 (contato 191, Lançador 48) |
| 3 | prioridade | derrota aos 12:37, **chegou ao chefe** | 22 | 2.380 | 29 | 287 (contato 161, chefe 70, Lançador 56) |
| 4 | aleatória | derrota aos 9:41 | 16 | 1.332 | 53 | 276 |
| 5 | aleatória | derrota aos 8:30 | 16 | 1.152 | 59 | 223 |
| 6 | prioridade, **sem esquiva** | derrota aos 10:36, chegou ao chefe | 20 | 1.818 | 0 | 319 |

Leitura: depois dos ajustes, o piloto simples chega perto dos 10 minutos e às vezes alcança o chefe. A esquiva automática do piloto não melhorou o resultado (semente 6), o que diz mais sobre o piloto (que esquiva por reflexo, sem mirar) do que sobre a esquiva; isso precisa de teste com pessoas.

### Encontro final (`--modo=chefe`)

Começa aos 10:00 com uma build típica medida nas partidas (Aura 4, Lâmina 4, Poder arcano 4, Cadência 3, Núcleo vital 2, Projétil adicional 2, Campo de ruptura 1, Passos ligeiros 1):

| Semente | Resultado | Tempo contra o chefe | Dano no chefe | Dano recebido |
|---|---|---|---|---|
| 1 | **vitória** aos 12:20 | 140,3 s | 3.800 | 90 (chefe 42, contato 32, Lançador 16) |
| 2 | derrota aos 13:20 | — | 2.710 | 227 (Lançador 158, chefe 60) |
| 3 | derrota aos 14:49 | — | 2.669 | 362 (Lançador 277, chefe 78) |

Com o chefe a 7.000 de vida e sem o Raio mirar nele, o piloto tirava só 252 de vida em 4 minutos (ele ficava longe e os tiros acertavam a horda no caminho). Por isso: o Raio passou a mirar o chefe ao alcance, a vida caiu para 4.500 e depois 3.800, e a recuperação entre ataques subiu para 1,4 s. Nas derrotas acima, **o Lançador causou a maior parte do dano**: por isso, durante o encontro, novos Lançadores deixam de nascer (os que já estão em campo continuam).

Depois dessa mudança (sementes 1 e 2, até 15:00): o piloto **sobreviveu** os 5 minutos de encontro nas duas, com o dano recebido vindo quase todo do chefe (244 e 222) e não mais do Lançador, mas **não derrotou** o chefe (tirou 2.457 e 3.018 dos 3.800). O piloto acerta o chefe só a ~10 de dano por segundo, porque fica a 6–9 m durante os avisos e a Aura (3,2 m) e as Lâminas (2,5 m) quase não alcançam. Um jogador que fica perto do chefe nas pausas de recuperação causa bem mais (pelos números das armas, a Aura 4 e a Lâmina 4 somam mais de 100 de dano por segundo num alvo encostado), mas isso **não foi medido com pessoas**. A vida de 3.800 foi mantida; é o primeiro número a revisar no teste com pessoas.

### Ajustes feitos com base nas medições

| Ajuste | Antes | Depois | Motivo medido |
|---|---|---|---|
| Crescimento da vida dos inimigos | +60%/min | +35%/min | piloto morria antes dos 5 min |
| Leva | +1 a cada 25 s | +1 a cada 30 s | idem |
| Cura por nível | nenhuma | 12% da vida máxima | todo o dano era cumulativo, sem resposta |
| Aura de brasas, níveis 2–5 | até 16 de dano, 3,5 m, 0,42 s | até 14, 3,2 m, 0,45 s | Aura 5 rendia 35% mais que a Lâmina 5 |
| Lâmina orbital, níveis 2–5 | 14/18/20/24 | 15/20/22/26 | Lâmina 3 rendia pouco mais que a 1 |
| Lançador | 10 de dano, 7,5 m/s, a cada 2,8 s, peso 0,2 | 8, 6,5 m/s, 3,2 s, peso 0,15 | maior fonte de dano no fim da partida |
| Chefe | 7.000 de vida, 1,1 s de recuperação | 3.800, 1,4 s | 4–6 min para cair com o dano medido |
| Raio arcano | sempre o mais próximo | mira o chefe ao alcance | os tiros paravam na horda |
| Encontro final | hordas a 50% | 30% e sem Lançadores novos | dano do Lançador nas derrotas contra o chefe |

Identificados e **não** resolvidos nesta etapa: o Raio sem melhorias passivas é a arma mais fraca (por desenho, cresce pelas passivas); Passos ligeiros e Campo de ruptura quase não foram escolhidos pelo piloto por prioridade, então não há medição do valor deles; nenhuma combinação dominante clara apareceu nas 6 partidas.

## Desempenho

Tempo de CPU por quadro na `long_simulation` (servidor de testes, sem renderização, **não representa um celular**). As duas primeiras linhas rodaram na mesma máquina, uma depois da outra, sem nada em paralelo:

| Medição | Média | p95 | p99 | Pior | Máximos |
|---|---|---|---|---|---|
| `main` (0.2), 300 s, piloto padrão | 0,57 ms | 1,43 ms | 2,00 ms | 12,3 ms | 300 inimigos |
| 0.3, 300 s, piloto padrão | 1,30 ms | 3,30 ms | 3,61 ms | 13,9 ms | 300 inimigos, 19 efeitos |
| 0.3, 660 s, invulnerável, Aura 5 + Lâmina 5, com o chefe | 3,01 ms | 4,40 ms | 5,67 ms | 17,5 ms | 301 inimigos, 400 orbes, 39 projéteis inimigos |
| 0.3 no CI (`ubuntu-latest`), 300 s | 2,24 ms | 5,76 ms | 6,07 ms | 15,5 ms | 300 inimigos |

- O custo por quadro **mais que dobrou** em relação à 0.2 (comportamento por tipo, cor por instância e 6 `MultiMesh` de inimigos em vez de 1). O pior caso medido fica abaixo de 6 ms no p99, mas no celular o GDScript roda em WebAssembly e pode ficar várias vezes mais lento. **O FPS no celular precisa ser medido** (o contador fica no rodapé do HUD).
- Memória: +8,4 MB em 11 minutos de pior caso, sem crescimento contínuo; 114 nós na árvore, constantes, inclusive entre reinícios (a simulação reinicia ao morrer e confere que os nós não crescem).
- O limite de 400 orbes foi atingido no pior caso (jogador invulnerável que não coleta); acima disso a XP é somada ao orbe mais antigo, sem perda e sem memória extra.

## Problemas encontrados no caminho

- **Ponte de testes parada no navegador:** no jogo exportado, um `JavaScriptBridge.eval` que devolvia um booleano interrompia a função sem mensagem. Resolvido lendo o endereço por `JavaScriptBridge.get_interface("location")` e terminando os códigos de `eval` com `void 0`.
- **Toques lentos no navegador do CI:** cada evento do protocolo do Chromium só volta depois de um quadro desenhado (~25 por segundo com renderização por software), e o trace do Playwright atrasa ainda mais. Um toque com espera de 40 ms virava 300 ms. Os testes passaram a enviar "encostar" e "soltar" juntos, como um toque real.
- **Limites do gdlint nos testes:** com 41 testes, o arquivo passou de 20 métodos públicos e 1.000 linhas. Os testes foram divididos em suítes, sem desligar regras.
- **Teste que dependia do acaso:** o teste do surgimento do chefe falhou quando o Raio passou a mirar o chefe (o chefe levava um tiro antes da verificação). O teste agora desliga o Raio.

## Limitações conhecidas

- Não testado em celular físico. Os perfis de Pixel 7 são emulação num Chromium de computador.
- Equilíbrio ajustado só com piloto automático.
- Destro/canhoto e ajuste do joystick: pendentes.
- Tela deitada: a câmera mantém 14 m de largura e mostra pouco mapa na vertical.
- Depois da pausa, o joystick só responde depois de levantar o dedo e tocar de novo.
- A ponte de testes existe no jogo publicado, mas só liga com `?teste=1`; com ela, quem abrir a página pode preparar situações (dar XP, chamar o chefe). Não há placar nem dado online afetado.
- Sem som e sem arte final.

## Pendências e próximos passos

1. Teste com 5 a 10 pessoas no celular (critério da fase 1): ritmo das hordas, dificuldade do chefe, clareza dos avisos e se o duplo toque é natural.
2. Opções de destro/canhoto e tamanho/sensibilidade do joystick (aprovadas como direção, não implementadas).
3. Revisar o valor de Passos ligeiros e Campo de ruptura com dados de pessoas.
4. Propostas para avaliação (não aprovadas): orbes distantes puxados ao fim do encontro; mais um chefe ou variação de ataques; efeitos sonoros.

## Revisão editorial

*(Espaço do ChatGPT.)*
