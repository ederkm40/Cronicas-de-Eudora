# CRÔNICAS DE EUDORA — DOCUMENTO MESTRE DE SISTEMAS

## Enciclopédia de Design, Conteúdo, Mecânicas e Arquitetura

| | |
|---|---|
| **Versão do documento** | 0.1.2 (0.4-alpha integrada à `main`; manutenção pós-0.4) |
| **Data de início** | 26/11/2026 |
| **Data desta revisão** | 27/11/2026 |
| **Status geral** | `EM_ELABORAÇÃO` |
| **Versão do jogo inventariada** | 0.4-alpha (`main` em `7a7daf2`, com o PR #10 integrado em `f51db23`), mais a manutenção pós-0.4 |
| **Catálogos** | [`catalogos/README.md`](catalogos/README.md) · modelo de entrada em [`catalogos/MODELO_ENTRADA.md`](catalogos/MODELO_ENTRADA.md) |

> **Etapa 3, "O Despertar de Eudora" (0.4-alpha, PR #10, integrada à `main` em `f51db23`).** Os elementos dessa etapa estão `IMPLEMENTADO (PR #10)`. As mecânicas novas continuam **propostas experimentais** (`PROPOSTO_NAO_APROVADO (experimental)`): o merge integrou o código, mas cada mecânica concreta só vira `APROVADO` quando o proprietário disser que fica. A personalização mobile já era `APROVADO` (seção 7.2). Nada está `VALIDADO`: não houve teste com pessoas nem em celular físico.

> **Leia antes de usar.** Este documento organiza o design e o planejamento. Ele **não autoriza** implementar nada (seção 37). A lista de entregas aprovadas é o [`docs/ROADMAP.md`](../ROADMAP.md). O funcionamento real do jogo está no código e em [`docs/TECNICO.md`](../TECNICO.md). Quando este documento e o código discordarem, **o código vale** e este documento deve ser corrigido.

---

## Sumário

1. [Propósito e princípios do documento](#1-propósito-e-princípios-do-documento)
2. [Identidade e pilares do jogo](#2-identidade-e-pilares-do-jogo)
3. [Ciclo central de jogo](#3-ciclo-central-de-jogo)
4. [Personagens e classes](#4-personagens-e-classes)
5. [Atributos e estatísticas](#5-atributos-e-estatísticas)
6. [Sistema de combate](#6-sistema-de-combate)
7. [Mobilidade e controles](#7-mobilidade-e-controles)
8. [Armas](#8-armas)
9. [Habilidades, poderes e magias](#9-habilidades-poderes-e-magias)
10. [Passivos, amuletos, anéis e equipamentos](#10-passivos-amuletos-anéis-e-equipamentos)
11. [Relíquias, runas e catalisadores](#11-relíquias-runas-e-catalisadores)
12. [Evoluções, sinergias e builds](#12-evoluções-sinergias-e-builds)
13. [Inimigos](#13-inimigos)
14. [Chefes e minibosses](#14-chefes-e-minibosses)
15. [Estágios, regiões e mapas](#15-estágios-regiões-e-mapas)
16. [Eventos, missões e desafios](#16-eventos-missões-e-desafios)
17. [Captadores, coletáveis e recompensas](#17-captadores-coletáveis-e-recompensas)
18. [Coleções, bestiário e descobertas](#18-coleções-bestiário-e-descobertas)
19. [Progressão durante a partida](#19-progressão-durante-a-partida)
20. [Progressão permanente](#20-progressão-permanente)
21. [Economia, comércio e fabricação](#21-economia-comércio-e-fabricação)
22. [NPCs e facções](#22-npcs-e-facções)
23. [História, narrativa e lore](#23-história-narrativa-e-lore)
24. [Interação com o ambiente](#24-interação-com-o-ambiente)
25. [Modos de jogo e dificuldade](#25-modos-de-jogo-e-dificuldade)
26. [Conquistas e objetivos de longo prazo](#26-conquistas-e-objetivos-de-longo-prazo)
27. [Interface e experiência do jogador](#27-interface-e-experiência-do-jogador)
28. [Acessibilidade](#28-acessibilidade)
29. [Áudio e identidade sensorial](#29-áudio-e-identidade-sensorial)
30. [Arquitetura técnica e dados](#30-arquitetura-técnica-e-dados)
31. [Telemetria e balanceamento](#31-telemetria-e-balanceamento)
32. [Testes e validação](#32-testes-e-validação)
33. [Catálogos Mestres](#33-catálogos-mestres)
34. [Matriz de dependências entre sistemas](#34-matriz-de-dependências-entre-sistemas)
35. [Diretrizes de produção de conteúdo](#35-diretrizes-de-produção-de-conteúdo)
36. [Ordem recomendada de desenvolvimento](#36-ordem-recomendada-de-desenvolvimento)
37. [Regras de governança](#37-regras-de-governança)
38. [Fontes de pesquisa e histórico do documento](#38-fontes-de-pesquisa-e-histórico-do-documento)

---

## 1. Propósito e princípios do documento

**Propósito.** Centralizar o planejamento de todos os sistemas de Crônicas de Eudora: o que cada um representa, para que serve, como funciona, que regras o governam, que conteúdos pertencem a ele, de que depende, como deve ser implementado e testado, e qual é o seu estado real.

**Princípios** (diretrizes do proprietário para este documento, `APROVADO` como princípio de trabalho):

- Cada mecânica tem uma finalidade clara.
- Cada categoria tem identidade própria.
- Os sistemas interagem de forma significativa.
- A progressão vai além de aumentar números.
- As escolhas têm consequências perceptíveis.
- A raridade estimula a descoberta.
- O jogo é acessível no celular.
- A interface não tem complexidade desnecessária.
- A arquitetura é expansível.
- Nada é considerado pronto sem validação.

### 1.1. Os três estados independentes

Todo elemento deste documento e dos catálogos tem **três estados**, que não podem ser confundidos.

| Eixo | Valores | Pergunta que responde |
|---|---|---|
| **Design** | `PROPOSTO_NAO_APROVADO` · `APROVADO` · `REJEITADO` · `SUBSTITUÍDO` | O proprietário decidiu que isso deve existir? |
| **Implementação** | `NÃO_IMPLEMENTADO` · `EM_DESENVOLVIMENTO` · `IMPLEMENTADO` · `IMPLEMENTADO_PARCIALMENTE` | Está no código da `main`? |
| **Validação** | `NÃO_TESTADO` · `TESTADO_COM_FALHAS` · `TESTADO` · `VALIDADO` | Que evidência existe de que funciona? |

Regras de classificação usadas nesta versão:

- **`APROVADO`** só com evidência: decisão em `docs/decisoes/`, item do `docs/ROADMAP.md`, instrução explícita do proprietário registrada numa etapa, ou funcionalidade entregue por PR aprovado e integrado.
- Tudo o que é ideia, estudo ou combinação sugerida aqui fica **`PROPOSTO_NAO_APROVADO`**.
- **`IMPLEMENTADO`** só para o que está no código da `main`.
- **`TESTADO`** = passa em testes automáticos registrados (Godot sem tela, simulações, Playwright com emulação de celular).
- **`VALIDADO`** = confirmado com pessoas jogando em aparelhos reais. **Nada está `VALIDADO` na 0.3-alpha**: não houve teste com pessoas nem em celular físico.
- No estado de validação, a emulação de Pixel 7 no Chromium conta como teste automático, **não** como teste em celular.

Notação curta usada nas tabelas: **D** = design, **I** = implementação, **V** = validação.

---

## 2. Identidade e pilares do jogo

**Identidade** (descrição do proprietário, `APROVADO`): Crônicas de Eudora é um RPG de ação isométrico com combate contínuo, hordas de inimigos, construção de personagem e progressão roguelite. Combina a velocidade e a legibilidade de um survivors-like com a profundidade de construção de personagem de um action RPG, uma progressão recompensadora, exploração com descobertas, diversidade de armas, habilidades e equipamentos, evoluções e sinergias, chefes com mecânicas próprias, conteúdo expansível e identidade visual e narrativa originais.

**Estado real (0.3-alpha):** o jogo é um protótipo de **partida de hordas de 10 minutos** com um personagem, três armas, seis melhorias, cinco tipos de inimigo, um chefe e uma camada inicial de progressão permanente. Exploração, equipamentos, habilidades ativas, narrativa e identidade visual final **não existem** ainda.

| Pilar | D | I | V | Situação atual |
|---|---|---|---|---|
| 1. Combate satisfatório e responsivo | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | `TESTADO` | combate automático, esquiva e avisos de ataque existem; sem som e sem arte final |
| 2. Builds variadas e reconhecíveis | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | `TESTADO` | 3 armas + 6 passivos + sinergias simples; sem evoluções de arma |
| 3. Progressão recompensadora | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | `TESTADO` | XP, level-up, Ecos e 4 melhorias permanentes |
| 4. Exploração significativa | `APROVADO` | `NÃO_IMPLEMENTADO` | `NÃO_TESTADO` | o mapa é um chão de grade sem limites |
| 5. Identidade visual e narrativa própria | `APROVADO` | `NÃO_IMPLEMENTADO` | `NÃO_TESTADO` | arte provisória (formas simples), sem lore |
| 6. Sinergias reais entre sistemas | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | `TESTADO` | Poder arcano, Cadência e Campo de ruptura afetam mais de uma arma |
| 7. Experiência mobile e desktop consistente | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | `TESTADO` | joystick, toque e teclado; falta destro/canhoto e teste em aparelho |
| 8. Arquitetura sustentável | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | `TESTADO` | arrays + MultiMesh, dados separados da execução (decisões 0003 e 0010) |
| 9. Interface clara | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | `TESTADO` | HUD, cartões, resultados; sem menu principal nem configurações |
| 10. Validação de todos os sistemas implementados | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | `TESTADO` | 51 testes do Godot e Playwright; falta teste com pessoas |

---

## 3. Ciclo central de jogo

### 3.1. Ciclo atual da partida (0.3-alpha)

Etapas do ciclo completo pedido pelo proprietário, com o que existe hoje:

| # | Etapa | D | I | Como é hoje |
|---|---|---|---|---|
| 1 | Seleção de personagem e configuração | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` | a partida começa direto, com o único personagem |
| 2 | Seleção de estágio e dificuldade | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` | um único ambiente, sem dificuldade escolhível |
| 3 | Entrada no ambiente | `APROVADO` | `IMPLEMENTADO` | chão de grade que acompanha o jogador |
| 4 | Combate | `APROVADO` | `IMPLEMENTADO` | ataques automáticos, hordas, esquiva |
| 5 | Coleta de experiência e recompensas | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | só orbes de XP; sem outros coletáveis |
| 6 | Level-up | `APROVADO` | `IMPLEMENTADO` | pausa e até 3 ofertas |
| 7 | Escolha de armas, passivos e poderes | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | armas e passivos; sem poderes/habilidades |
| 8 | Construção de sinergias | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | sinergias de passivos com armas |
| 9 | Eventos e inimigos especiais | `APROVADO` (inimigos) / `PROPOSTO_NAO_APROVADO` (eventos) | `IMPLEMENTADO_PARCIALMENTE` | 4 tipos especiais por tempo; sem eventos |
| 10 | Chefes | `APROVADO` | `IMPLEMENTADO` | Sentinela do Eco aos 10 min |
| 11 | Objetivos e sobrevivência | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | único objetivo: derrotar o chefe |
| 12 | Recompensas | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | Ecos ao fim da partida |
| 13 | Resultados | `APROVADO` | `IMPLEMENTADO` | tela de vitória/derrota com estatísticas reais |
| 14 | Progressão permanente | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | Ecos e 4 melhorias |

**Regra fixa nesta etapa:** a duração de referência de **10 minutos** e o **Sentinela do Eco** como encontro final continuam como estão (instrução do proprietário). Outros formatos de partida são propostas separadas (seção 25).

### 3.2. Ritmo atual (valores do código)

| Momento | O que acontece | Fonte |
|---|---|---|
| 0:00 | só Errantes; leva de 1 inimigo a cada 1 s | `EnemyManager._spawn` |
| 0:45 | começa o Espreitador | `EnemyTypes.SCHEDULE` |
| 1:40 | começa o Couraçado | idem |
| 2:30 | começa o Lançador | idem |
| 3:30 | começa o Volátil | idem |
| a cada 30 s | +1 inimigo por leva; intervalo cai 0,012 s por segundo até 0,12 s | `batch_growth_seconds`, `spawn_interval_*` |
| todo minuto | vida dos inimigos +35% da base | `hp_growth_per_minute` |
| 9:50 | aviso do encontro final | `Main.encounter_warning` |
| 10:00 | Sentinela do Eco; hordas a 30% e sem Lançadores novos | `Main.start_encounter` |
| derrota do chefe | vitória | `Main._on_boss_died` |
| vida 0 | derrota | `Main._on_player_died` |

**Intervalos de respiro:** hoje só existem a pausa do level-up e a janela de recuperação do chefe (1,4 s). Respiros planejados (eventos calmos, baús) são `PROPOSTO_NAO_APROVADO`.

### 3.3. Ciclos complementares (todos fora da 0.3-alpha)

| Ciclo | D | I | Observação |
|---|---|---|---|
| Exploração | `APROVADO` como pilar · forma `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` | depende de estágios (15) |
| Combate | `APROVADO` | `IMPLEMENTADO` | ver 6 |
| Aquisição de itens | `APROVADO` ("loot que muda regras", fase 2 do roadmap) | `NÃO_IMPLEMENTADO` | ver 10 |
| Evolução de armas | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` | hoje há só níveis 1–5 |
| Fabricação | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` | ver 21 |
| Desbloqueios | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` | ver 20 |
| Missões | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` | ver 16 |
| Progressão permanente | `APROVADO` | `IMPLEMENTADO_PARCIALMENTE` | ver 20 |
| Coleções e descobertas | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` | ver 18 |

**Como testar o ciclo:** `tests/smoke_test.gd` (60 s de ponta a ponta), `tests/long_simulation.gd` (partidas longas com reinício) e `tests/balance_simulation.gd` (partida com piloto). Validação com pessoas: pendente.

---

## 4. Personagens e classes

### 4.1. Inventário atual

| Elemento | D | I | V | Valores (código) |
|---|---|---|---|---|
| Personagem jogável único, sem nome nem classe | `APROVADO` (protótipo) | `IMPLEMENTADO` | `TESTADO` | vida 100, velocidade 5 m/s, cápsula azul (`player.gd`) |
| Uma classe completa | `APROVADO` (fase 2 do roadmap) | `NÃO_IMPLEMENTADO` | `NÃO_TESTADO` | — |
| Classes adicionais, especializações | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` | `NÃO_TESTADO` | — |

### 4.2. Ficha planejada de personagem (`PROPOSTO_NAO_APROVADO`)

Cada personagem jogável deverá ter: nome, identidade visual, história, origem, personalidade, atributos base, característica especial, animações, identidade sonora, arma inicial e condição de desbloqueio. Nenhum desses campos foi definido para o personagem atual.

### 4.3. Arquétipos a estudar (`PROPOSTO_NAO_APROVADO`)

Ofensivo · Defensivo · Mobilidade · Magia elemental · Invocação · Controle de grupo · Corpo a corpo · Distância · Híbrido.

Regras de estudo:

- Classes **favorecem** estilos de combate (bônus, habilidades, arma inicial), mas **não bloqueiam** famílias de armas de forma arbitrária.
- Três caminhos de especialização por classe podem servir de referência de estudo, **sem decisão**.
- A primeira classe só deve ser definida depois do teste com pessoas da fase 1 (critério de saída do roadmap).

**Dependências:** atributos (5), armas (8), habilidades (9), progressão permanente (20), interface de seleção (27). **Testes futuros:** atributos base aplicados no início da partida; arma inicial correta; reinício sem resíduos da classe anterior.

---

## 5. Atributos e estatísticas

### 5.1. Atributos que existem hoje (todos `APROVADO` · `IMPLEMENTADO` · `TESTADO`)

| Atributo | Base | Modificadores | Regra de cálculo | Onde |
|---|---|---|---|---|
| Vida máxima | 100 | Núcleo vital (+25%/nível, até 8); Vigor ancestral (+8%/nível, até 5) | `100 × (1 + 0,25 × n) × (1 + 0,08 × v)` | `Upgrades.refresh`, `Player.set_max_hp_multiplier` |
| Velocidade de movimento | 5 m/s | Passos ligeiros (+15%/nível, até 5) | `5 × (1 + 0,15 × n)` | `Player.effective_speed` |
| Dano (todas as armas) | por arma | Poder arcano (+20%/nível, até 10); Fúria latente (+5%/nível, até 5) | `base × (1 + 0,2 × n) × (1 + 0,05 × f)` | `Upgrades.refresh` |
| Velocidade de ataque (Raio) e frequência (Aura) | por arma | Cadência (+15%/nível, até 8) | `intervalo ÷ (1 + 0,15 × n)` | `AutoWeapon`, `AuraWeapon` |
| Alcance (Raio) | 11 m | Campo de ruptura (+20%/nível, até 5) | `11 × (1 + 0,2 × n)`; duração do projétil cresce igual | `AutoWeapon` |
| Área (Aura) | por nível | Campo de ruptura (+10%/nível) | `raio × (1 + 0,1 × n)` | `Upgrades.AURA_RANGE_SHARE` |
| Quantidade de projéteis (Raio) | 1 | Projétil adicional (+1, até 4) | `1 + n` | `AutoWeapon` |
| Raio do ímã de orbes | 3 m | Atração do eco (+20%/nível, até 3) | `3 × (1 + 0,2 × a)` | `Main._ready` |
| Raio de coleta de orbes | 0,6 m | — | fixo | `XpOrbManager` |
| Esquiva | 4 m, 0,18 s | — | ver 7 | `Player` |
| Invulnerabilidade | 0,32 s na esquiva | — | bloqueia todo dano | `Player.is_invulnerable` |
| Cura | 12% da vida máxima por nível ganho; 25 no Núcleo vital | — | não passa do máximo | `Main._on_leveled_up`, `Player.heal` |
| Resistência (inimigos) | Couraçado 35% | — | `dano × (1 − 0,35)` | `EnemyManager.damage` |

**Ordem de aplicação atual:** valores base → bônus da partida (aditivos entre si, por melhoria) → bônus permanente (multiplica o resultado). Tudo é **recalculado a partir da base** a cada mudança (decisão 0005), o que evita aplicação duplicada. Não há arredondamento nos valores de combate; os textos dos cartões arredondam porcentagens para inteiros.

### 5.2. Atributos planejados para estudo (todos `PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO`)

- **Ofensivos:** dano físico, mágico e elemental; dano por segundo (hoje só medido em simulação); chance e multiplicador crítico; frequência de conjuração; duração; penetração; ricochete; perfuração; dano contra chefes.
- **Defensivos:** regeneração; armadura; resistências do jogador; redução de dano; escudo; bloqueio; recuperação; roubo de vida; resistência a estados negativos.
- **Utilidade:** quantidade de experiência; sorte; frequência de recompensas; duração de efeitos; redução de recarga; eficiência de recursos; descoberta; resistência a controle.

### 5.3. Regras a definir antes de qualquer atributo novo

1. Cada atributo declara: valor base, tipo de modificador (aditivo ou multiplicativo), limite, ordem de aplicação e arredondamento.
2. Bônus da mesma fonte somam; fontes diferentes multiplicam (regra atual, a manter ou substituir por decisão).
3. Limites explícitos para atributos que quebram o jogo (velocidade de ataque, redução de recarga, invulnerabilidade).
4. Imunidades e interações (ex.: chefes imunes a controle) documentadas por inimigo.

**Dependências:** armas, inimigos, progressão. **Testes:** um teste de efeito por modificador (padrão já usado em `tests/suites/progressao.gd`).

---

## 6. Sistema de combate

### 6.1. Formas de ataque

| Forma | D | I | V | Exemplo atual |
|---|---|---|---|---|
| Combate automático | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | todas as armas atacam sozinhas |
| Projéteis | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | Raio arcano; projéteis do Lançador e do chefe |
| Auras | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | Aura de brasas (dano por pulso) |
| Ataques orbitais | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | Lâmina orbital |
| Explosões | `APROVADO` (inimigos) | `IMPLEMENTADO_PARCIALMENTE` | `TESTADO` | Volátil e erupção do chefe; nenhuma arma do jogador explode |
| Combate contextual, corpo a corpo, raios, áreas persistentes, invocações, armadilhas, ataques direcionados, cadeias, retornos, ondas | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` | `NÃO_TESTADO` | — |

### 6.2. Regras atuais de dano

- Todo dano a inimigos passa por `EnemyManager.damage(índice, dano, arma)`: desconta a resistência, registra a vida realmente tirada e a arma de origem, faz o inimigo piscar e remove quem morre.
- O jogador recebe dano de contato (soma de até 5 inimigos encostados, por segundo), projéteis, explosões e ataques do chefe. A esquiva bloqueia todos.
- Não há crítico nem tipos de dano.
- **0.4 (PR #10):** a ordem do dano passou a ser: armadura do elite Blindado (−30%), escudo do Tecelão (−40%), chefe exposto (+50%), registro e morte. Golpes no chefe e em elites mostram um número de dano.

### 6.3. Estados de combate e reações

**Estados implementados na 0.4 (PR #10).** Guardados em arrays do `EnemyManager`, sem nós por inimigo, como pede a regra abaixo:

| Estado | D | I | V | Regra (código) | Contrajogo e leitura |
|---|---|---|---|---|---|
| Queimadura | `PROPOSTO_NAO_APROVADO` (experimental) | `IMPLEMENTADO` (PR #10) | `TESTADO` | Coroa de cinzas: 40% do dano do pulso por segundo, por 3 s; renova, não acumula | inimigo alaranjado |
| Lentidão | `PROPOSTO_NAO_APROVADO` (experimental) | `IMPLEMENTADO` (PR #10) | `TESTADO` | Vendaval de lâminas: velocidade ×0,55 por 1,5 s; o chefe é imune | inimigo azulado |
| Empurrão | `PROPOSTO_NAO_APROVADO` (experimental) | `IMPLEMENTADO` (PR #10) | `TESTADO` | Raio: 1,2 m/s por acerto; Vendaval: 4 m/s para fora; Couraçado e elites ×0,3; o chefe é imune | some em ~0,1 s |
| Escudo | `PROPOSTO_NAO_APROVADO` (experimental) | `IMPLEMENTADO` (PR #10) | `TESTADO` | Tecelão: −40% de dano em quem está a até 3,5 m dele; não protege a si mesmo nem o chefe | inimigo ciano; derrubar o Tecelão desfaz |
| Vulnerabilidade | `PROPOSTO_NAO_APROVADO` (experimental) | `IMPLEMENTADO` (PR #10) | `TESTADO` | chefe atordoado 2 s depois da investida: +50% de dano | chefe pisca branco e aviso "Ponto fraco exposto" |
| Reação queimado + raio | `PROPOSTO_NAO_APROVADO` (experimental) | `IMPLEMENTADO` (PR #10) | `TESTADO` | o Raio em cadeia salta para 3 alvos (em vez de 2), com +25%, se o primeiro estiver queimando | sinergia Raio + Aura |

Estados ainda só a estudar (`PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO`): crítico, atordoamento, lentidão, congelamento, queimadura, envenenamento, sangramento, choque, vulnerabilidade, medo, enraizamento, maldição, marcação, silêncio, resistência temporária.

Elementos a estudar: fogo, gelo, eletricidade, veneno, terra, vento, luz, sombra e arcano. A Aura **de brasas** e o Raio **arcano** têm nomes elementais, mas **não** existe sistema de elementos no código: são só nomes.

Reações a investigar: combustão; congelamento e estilhaçamento; sobrecarga elétrica; condutividade; acúmulo de veneno; explosões elementais; reações entre áreas; conversão de dano; propagação de estados.

Exigências para qualquer estado ou reação futura: regra clara de aplicação e duração; limite de acúmulo; contrajogo (como o jogador ou o inimigo evita); indicação visual legível; custo de desempenho aceitável com 300 inimigos (estado guardado em arrays do `EnemyManager`, nunca em nós).

**Dependências:** atributos, armas, inimigos, efeitos visuais. **Testes futuros:** aplicação, duração, acúmulo, limite, imunidade, interação entre dois estados.

---

## 7. Mobilidade e controles

### 7.1. O que existe

| Elemento | D | I | V | Regra (código) |
|---|---|---|---|---|
| Movimento | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | velocidade constante, sem aceleração nem desaceleração |
| Joystick flutuante | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | raio 90, zona morta 12%, centro acompanha o dedo |
| Teclado | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | WASD e setas; Espaço esquiva; 1–3 escolhem; R troca |
| Esquiva por duplo toque com direção | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | toque ≤ 0,22 s e < 28 de arrasto; 2º toque em ≤ 0,32 s a ≤ 140; peteleco de 40 em 0,3 s dá a direção |
| Esquiva: efeito | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | 4 m em 0,18 s; 0,32 s invulnerável; recarga 1,4 s |
| Retomada do joystick depois da pausa | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | o dedo que ficou na tela volta a controlar; se foi solto, neutro (corrigido na manutenção pós-0.3) |
| Joystick fixo (opção) | `APROVADO` | `IMPLEMENTADO` (PR #10) | `TESTADO` | o toque pode começar em qualquer lugar, mas o centro fica parado no lado do polegar (x 72% destro, 28% canhoto) e na altura escolhida (66%, 76% ou 84% da tela) |
| Tamanho do joystick | `APROVADO` | `IMPLEMENTADO` (PR #10) | `TESTADO` | pequeno ×0,8 · médio ×1,0 · grande ×1,25 do raio de 90 (limites seguros: 72 a 112,5) |
| Botão de pausa "II" | `APROVADO` | `IMPLEMENTADO` (PR #10) | `TESTADO` | 76 × 64, no canto de cima, do lado oposto ao polegar; tocar nele não liga o joystick; Esc ou P no computador |
| Tremor de câmera | `PROPOSTO_NAO_APROVADO` (experimental) | `IMPLEMENTADO` (PR #10) | `TESTADO` | explosões, dano forte, chefe, elites; pode ser desligado |
| Colisão com cenário | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` | — | não há obstáculos |
| Habilidades de movimento além da esquiva | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` | — | — |

### 7.2. Diretrizes mobile aprovadas pelo proprietário

| Diretriz | D | I | V |
|---|---|---|---|
| Operação com um dedo | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |
| Joystick flutuante como controle central | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |
| Ataques automáticos | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |
| Esquiva por duplo toque com direção | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |
| Layout para destros e canhotos | `APROVADO` | `IMPLEMENTADO` (PR #10) | `TESTADO` |
| Espelhamento dos controles | `APROVADO` | `IMPLEMENTADO` (PR #10) | `TESTADO` |
| Persistência da preferência | `APROVADO` | `IMPLEMENTADO` (PR #10) | `TESTADO` |
| Ajuste de posição e tamanho do joystick, dentro de limites seguros | `APROVADO` | `IMPLEMENTADO` (PR #10) | `TESTADO` |
| Ações contextuais para reduzir botões | `APROVADO` | `NÃO_IMPLEMENTADO` | `NÃO_TESTADO` |
| Compatibilidade com teclado e PC | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |

**Como ficou (0.4, PR #10):** tela de pausa com as configurações, salvas em `user://configuracoes.json` (versão 1, escrita em arquivo temporário e renomeada; arquivo inválido vira cópia `.corrompido` e valores inválidos voltam ao padrão). Opções: mão (destro/canhoto), joystick (flutuante/fixo), tamanho, altura (só no modo fixo), som, tremor e números de dano. O modo canhoto espelha o botão de pausa, o texto de estado, o indicador de esquiva e o lugar do joystick fixo. "Posição" virou a escolha entre flutuante (qualquer lugar) e fixo (lado do polegar, 3 alturas). **Testado:** Godot (`tests/suites/despertar.gd`) e Playwright nos 3 perfis (pausa pelo toque, troca para canhoto, retomada). **Não testado em celular físico.** Ações contextuais continuam não implementadas: o jogo segue sem botões de ataque e de esquiva.

---

## 8. Armas

### 8.1. Modelo de dados de uma arma

Campos obrigatórios (ver [`catalogos/MODELO_ENTRADA.md`](catalogos/MODELO_ENTRADA.md)): ID permanente · nome · categoria · elemento · tipo de dano · raridade (quando houver) · dano base · frequência · alcance · projéteis · área · duração · recarga · nível · limite · evoluções · sinergias · efeitos visuais · efeitos sonoros · requisitos · estados D/I/V.

Hoje o código guarda, por arma, em `WeaponCatalog.DEFINITIONS`: `id`, `name`, `kind` (projetil/aura/orbital), `description`, `max_level` e a tabela `levels` com os atributos completos de cada nível. **Não existem** no código: elemento, tipo de dano, raridade, evoluções, sons e requisitos.

### 8.2. Armas existentes (resumo; detalhes no [catálogo de armas](catalogos/03-armas.md))

| ID | Nome | Família | D | I | V |
|---|---|---|---|---|---|
| `raio_arcano` | Raio arcano | foco arcano / projétil | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |
| `aura_de_brasas` | Aura de brasas | arma de área | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |
| `lamina_orbital` | Lâmina orbital | arma orbital | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |

### 8.3. Aquisição, níveis e balanceamento atuais

- Arsenal com **4 espaços**; o Raio começa ocupando um. A arma nova entra pelo level-up (seção 19).
- Aura e Lâmina têm níveis 1 a 5; o Raio tem nível único e cresce pelas passivas.
- Equilíbrio medido só com simulação (`tests/balance_simulation.gd`, relatório da 0.3).

### 8.4. Famílias a estudar (`PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO`)

Espadas · Lâminas · Lanças · Machados · Martelos · Arcos · Bestas · Armas de fogo · Cajados · Varinhas · Focos arcanos · Orbes · Artefatos · Armas invocadoras · Armadilhas · Armas orbitais (já tem 1) · Armas de área (já tem 1).

Regras para uma arma nova: precisa de uma forma de ataque diferente das existentes **ou** de uma função tática nova (ex.: controle, alvo único forte); entra no catálogo com todos os campos antes de ser codificada; segue o padrão da decisão 0010 (definição no catálogo, um nó de execução, dano pelo `EnemyManager`).

**Dependências:** atributos, combate, inimigos (colisão e dano), progressão (ofertas), estatísticas. **Testes:** dano, intervalo, alcance, quantidade, limite de nível, espaço próprio, reinício (padrão de `tests/suites/armas_e_ofertas.gd`).

---

## 9. Habilidades, poderes e magias

**Estado:** nenhuma habilidade ativa, suprema ou recurso de mana existe. A esquiva é a única ação do jogador e não consome recurso. Todo o conteúdo abaixo é `PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO` · `NÃO_TESTADO`.

**Tipos a estudar:** ativas · automáticas · passivas · supremas · auras · invocações · maldições · marcas · armadilhas · mobilidade · defesa · controle de grupo · poderes elementais.

**Modificadores modulares a estudar:** aumentar dano · adicionar projéteis · alterar área · converter elemento · acrescentar ricochete · aplicar estados · criar efeitos secundários · mudar duração · modificar recarga · ativar efeitos condicionais.

**Recursos a avaliar:** mana, energia arcana, cargas, espírito, recursos de classe. Regra: **nenhum recurso existe só por tradição de RPG**. Um recurso precisa criar uma decisão que a recarga sozinha não cria.

**Restrição mobile:** com controle de um dedo, habilidades ativas precisam ser automáticas, contextuais ou ligadas a gestos simples; um botão novo exige decisão explícita (a diretriz atual é reduzir botões).

**Dependências:** atributos, estados (6), interface (27), controles (7).

---

## 10. Passivos, amuletos, anéis e equipamentos

### 10.1. Passivos existentes

As 6 melhorias passivas da partida (`Upgrades.DEFINITIONS`) são os únicos "passivos". Todas `APROVADO` · `IMPLEMENTADO` · `TESTADO`. Detalhes no [catálogo de passivos](catalogos/05-passivos.md).

### 10.2. Equipamentos

O roadmap aprova, para depois do protótipo, **"loot que muda regras (itens com efeitos especiais)"** (`APROVADO` · `NÃO_IMPLEMENTADO`). A forma desse loot não foi decidida. Tudo abaixo é `PROPOSTO_NAO_APROVADO`:

- **Espaços:** cabeça, peitoral, luvas, calças, botas, armas, escudos, focos, amuletos, anéis, relíquias. A existência de cada espaço depende de decisão de design; com controle mobile e partidas curtas, poucos espaços podem ser melhores que muitos.
- **Afixos:** fixos, variáveis, especiais, condicionais, elementais, por classe, por habilidade, negativos compensados.
- **Raridades e personalização:** aprimoramento, reforja, encantamento, componentes, alteração de propriedades, extração de poderes, transferência, reciclagem, desmontagem.

**Princípio a respeitar (do roadmap):** o loot deve **mudar regras** (comportamento), não só somar números.

**Dependências:** atributos, inventário e persistência (30), economia (21), interface (27).

---

## 11. Relíquias, runas e catalisadores

**Estado:** nenhum existe. Tudo `PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO`.

- **Relíquias (funções a estudar):** desbloquear sistemas; modificar regras; criar sinergias; alterar habilidades; transformar armas; modificar recompensas; liberar regiões; abrir conteúdo secreto.
- **Runas:** inserção; combinações; efeitos individuais; conjuntos; fabricação; remoção; descoberta.
- **Catalisadores:** evolução de armas; modificação de habilidades; ativação de sinergias; desbloqueio de propriedades; alteração de efeitos elementais.

Risco a evitar: três sistemas (relíquia, runa, catalisador) com funções sobrepostas. Antes de aprovar qualquer um, definir a fronteira: o que um faz que os outros não fazem.

**Dependências:** armas, habilidades, elementos (6), coleções (18), persistência.

---

## 12. Evoluções, sinergias e builds

### 12.1. O que existe

| Elemento | D | I | V | Como é |
|---|---|---|---|---|
| Sinergia arma + passivo | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | Poder arcano em todas as armas; Cadência no Raio e na Aura; Campo de ruptura no Raio (+20%) e na Aura (+10%) |
| Evolução por nível | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | Aura e Lâmina, níveis 1–5 |
| Evolução que transforma a arma | `PROPOSTO_NAO_APROVADO` (experimental) | `IMPLEMENTADO` (PR #10) | `TESTADO` | carta dourada "EVOLUÇÃO" no level-up quando a arma e as passivas cumprem os requisitos; uma vez por arma (detalhes abaixo) |
| Melhoria de risco (Pacto do eco) | `PROPOSTO_NAO_APROVADO` (experimental) | `IMPLEMENTADO` (PR #10) | `TESTADO` | +25% de dano e +15% de XP por nível, mas +20% de dano recebido; até 3 |

**Evoluções da 0.4 (PR #10):**

| Evolução | Arma e requisito | Efeito | DPS medido (`--modo=dps`, mesma build sem → com) |
|---|---|---|---|
| Raio em cadeia | Raio + Projétil adicional 2 + Poder arcano 3 | cada acerto salta para 2 vizinhos a até 4 m com 60% do dano (3 vizinhos e +25% se o alvo queima) | 73/s → 161/s |
| Coroa de cinzas | Aura 5 + Cadência 2 | +15% de raio; o pulso queima (40% do dano por segundo, 3 s) | 204/s → 311/s |
| Vendaval de lâminas | Lâmina 5 + Passos ligeiros 2 | +2 lâminas (até 6); o raio "respira" ±0,9 m; o corte deixa lento e empurra | 71/s → 87/s |

### 12.2. A estudar (`PROPOSTO_NAO_APROVADO`)

- **Combinações:** arma + passivo · arma + catalisador · arma + arma · habilidade + modificador · relíquia + elemento · amuleto + arma · conjuntos · estados combinados · combinações de eventos.
- **Tipos de evolução:** direta · união de armas · transformação · catalisador · especialização · condição de combate · secreta · alternativa.

### 12.3. Identificação de uma build

Uma build deve poder ser descrita por: armas (e níveis), passivos, habilidades, relíquias, equipamentos, elementos, estilo (distância, área, corpo a corpo), pontos fortes e limitações. **Hoje** a tela de resultados já mostra armas com nível, dano e abates, e as melhorias com nível: é a base para identificar builds.

### 12.4. Detectar combinações problemáticas

Ferramenta existente: `tests/balance_simulation.gd` (`--modo=dps` compara cargas de armas; `--modo=partida` com escolhas por prioridade ou aleatórias). Proposta (`PROPOSTO_NAO_APROVADO`): ampliar para varrer combinações e marcar as **dominantes** (muito acima da média), **inviáveis** (abaixo de um piso), **redundantes** (mesmo efeito de outra) e **dependentes de um só componente**.

---

## 13. Inimigos

### 13.1. Arquétipos existentes (resumo; detalhes no [catálogo de inimigos](catalogos/12-inimigos.md))

| Arquétipo | Inimigo | D | I | V |
|---|---|---|---|---|
| Comum | Errante | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |
| Rápido | Espreitador | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |
| Resistente | Couraçado | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |
| Atirador | Lançador | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |
| Explosivo | Volátil | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |

Comportamentos existentes: perseguição (todos), interceptação (Espreitador), manter distância + ataque à distância com aviso (Lançador), aproximação + explosão com aviso (Volátil), separação entre inimigos, reaparecimento quando ficam longe demais.

### 13.1.1. Implementado na 0.4 (PR #10)

| Arquétipo | Inimigo | D | I | V | Regra (código) |
|---|---|---|---|---|---|
| Suporte | Tecelão | `PROPOSTO_NAO_APROVADO` (experimental) | `IMPLEMENTADO` (PR #10) | `TESTADO` | vida ×2, mantém 7–9,5 m do jogador; escudo de −40% em quem está a até 3,5 m; surge a partir dos 4:30 (peso até 0,07) |
| Controlador | Semeador | `PROPOSTO_NAO_APROVADO` (experimental) | `IMPLEMENTADO` (PR #10) | `TESTADO` | vida ×1,6; a cada 4,5 s deixa uma poça de cinzas (raio 1,6 m, aviso de 0,6 s, 12 de dano por segundo, 5 s); surge a partir dos 5:30 (peso até 0,09) |
| Elite | Veloz, Blindado, Gerador | `PROPOSTO_NAO_APROVADO` (experimental) | `IMPLEMENTADO` (PR #10) | `TESTADO` | vida ×5, tamanho ×1,45, contato ×1,5, brilho dourado; Veloz ×1,5 de velocidade; Blindado −30% de dano; Gerador chama 2 Errantes a cada 7 s. Recompensa: orbe de 12, cura de 15 e aviso na tela |

### 13.2. A estudar (`PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO`)

- **Arquétipos:** voador · invocador · suporte · curandeiro · controlador · caçador · emboscador · defensor · elite · especial.
- **Comportamentos:** patrulha · fuga · proteção · invocação · formações · defesa territorial · ataques coordenados.
- **Atributos:** resistências e vulnerabilidades por elemento (dependem da seção 6); recompensas além de XP; estados.
- **Elites e modificadores:** acelerado · fortificado · explosivo · vampírico · elétrico · congelante · invocador · regenerativo · espelhado · protetor. Cada modificador deve ser **legível** (cor, forma ou aviso próprio) e ter contrajogo.

**Regra técnica (decisão 0010):** todo inimigo novo vive nos arrays do `EnemyManager`, com um `MultiMesh` por tipo (desenhado pelo `EnemyRenderer`, onde fica a forma de cada tipo) e comportamento no `match` de `_move()`. **Testes:** atributos, comportamento, ataques com aviso, morte e remoção, entrada por tempo (padrão de `tests/suites/inimigos_e_chefe.gd`).

---

## 14. Chefes e minibosses

### 14.1. Existente

| Chefe | Categoria | D | I | V |
|---|---|---|---|---|
| Sentinela do Eco | chefe do encontro final da partida | `APROVADO` | `IMPLEMENTADO` | `TESTADO` (sem balanceamento validado com pessoas) |

Ficha completa no [catálogo de chefes](catalogos/14-chefes.md): vida 3.800, investida/erupção/rajada com avisos, recuperação de 1,4 s, fase 2 abaixo de 50%, contato 24/s, recompensa de vitória e 40 Ecos. Não tem história, nome de região, vulnerabilidades nem resistências.

### 14.2. A estudar (`PROPOSTO_NAO_APROVADO`)

- **Categorias:** miniboss · chefe de estágio · chefe de região · chefe de evento · chefe secreto · chefe final · chefe de desafio. O roadmap aprova "1 chefe" para a vertical slice (fase 2); se ele será o Sentinela ou outro não foi decidido.
- **Ficha obrigatória:** identidade, história, aparência, barra de vida, ataques, fases, habilidades, vulnerabilidades, resistências, indicadores visuais, recompensas, condições de surgimento.
- **Padrões:** mudanças de comportamento, invocações, áreas perigosas, ataques direcionados, janelas de vulnerabilidade, mudanças de arena, enfurecimento.

**0.4 (PR #10):** o Sentinela ganhou uma **janela de vulnerabilidade** (atordoado 2 s depois de cada investida, recebendo +50%) e um 4º ataque, a **Prisão de ecos** (anel de 10 círculos a 3,6 m do jogador com uma saída de 2 círculos; aviso de 1,3 s; 26 de dano em quem fica em cima). Na fase 2, o primeiro reforço é um Tecelão. Todos `PROPOSTO_NAO_APROVADO` (experimental) · `IMPLEMENTADO` (PR #10) · `TESTADO`. No piloto automático (`--modo=chefe`, sementes 1–3) o chefe foi derrotado nas 3 rodadas (166 a 264 s); na 0.3 o piloto não o derrotava. **Precisa de teste com pessoas.**

**Princípio:** chefes exigem movimentação, leitura de padrões e decisões de build; vida alta não substitui mecânica. O Sentinela segue isso (todos os ataques avisados e uma janela de recuperação), mas o tempo para derrotá-lo ainda não foi medido com pessoas.

---

## 15. Estágios, regiões e mapas

**Estado atual:** um único ambiente, o chão de grade provisório (grade de 2 m, sem paredes, obstáculos ou bordas, que acompanha o jogador). `APROVADO` (protótipo) · `IMPLEMENTADO` · `TESTADO`.

O roadmap aprova **"1 fase com arte e som finais"** para a vertical slice (`APROVADO` · `NÃO_IMPLEMENTADO`). Tudo o mais é `PROPOSTO_NAO_APROVADO`:

- **Hierarquia:** continentes → regiões → biomas → estágios → subáreas; masmorras, arenas, áreas secretas, zonas de desafio.
- **Ficha de estágio:** nome, tema, história, identidade visual, música, ambientação, inimigos, chefes, eventos, interações, recompensas, dificuldade.
- **Geografia funcional:** obstáculos, corredores, áreas abertas, terreno perigoso, proteção, elementos destrutíveis, pontos de interesse, rotas alternativas, segredos.
- **Modificadores de estágio:** mais inimigos, menos visibilidade, tempestades, corrupção, alterações elementais, recursos escassos, chefes adicionais, recompensas aumentadas.

**Impacto técnico a resolver antes:** obstáculos exigem colisão para jogador, inimigos e projéteis, e o surgimento "fora da tela" precisa evitar paredes. A câmera atual (14 m de largura) mostra pouco mapa na tela deitada.

---

## 16. Eventos, missões e desafios

**Estado:** a 0.4 (PR #10) traz um **diretor de eventos** (`scripts/event_director.gd`) com três eventos, todos `PROPOSTO_NAO_APROVADO` (experimental) · `IMPLEMENTADO` (PR #10) · `TESTADO`. Eles param no encontro final e quando as hordas automáticas estão desligadas.

| Evento | Quando | Regra |
|---|---|---|
| Elite | 2:00 e depois a cada 1:15 | um elite de um tipo já presente, na borda da tela, com aviso |
| Fenda do Eco | 2:30 e depois a cada 2:45 | círculo de 2,4 m perto do jogador; ficar 6 s dentro (no total) num prazo de 25 s dá um nível de escolha e cura de 20%; enquanto o jogador está dentro, as hordas dobram |
| Maré e Calmaria | 4:00 e depois a cada 3:00 | 15 s de hordas ×2,5, seguidos de 10 s de hordas ×0,25 |

Missões continuam inexistentes. Lista a estudar (`PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO`):

- **Eventos dinâmicos:** hordas especiais · proteção de objetivos · eliminação de alvos · sobrevivência · caça a elites · defesa de estruturas · rupturas dimensionais · invasões · escoltas · tesouros · arenas temporárias.
- **Missões:** principais · secundárias · diárias e semanais **só se justificadas** (o projeto não tem servidor; nada pode depender de serviço externo) · combate · descoberta · personagem · facção · secretas.
- **Ficha de missão:** condições, progresso, recompensas, requisitos, dificuldade, registro e estado de conclusão.

**Dependências:** estágios, eventos, recompensas, persistência, interface.

---

## 17. Captadores, coletáveis e recompensas

### 17.1. Existente

| Coletável | D | I | V | Regras (código) |
|---|---|---|---|---|
| Orbe de experiência | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | nasce onde o inimigo morreu; ímã a 3 m (acelera de 4 m/s, +30 m/s²); coleta a 0,6 m; não some; limite de 400 no chão, e acima disso o valor soma no orbe mais antigo |
| Ecos (recompensa de fim de partida) | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | ver 20 |

Detalhes no [catálogo de captadores](catalogos/18-captadores.md).

### 17.2. A estudar (`PROPOSTO_NAO_APROVADO`)

- **Coletáveis:** ouro, cura, escudos, energia, cargas, recursos temporários, fragmentos, baús, recompensas especiais.
- **Captadores especiais:** eliminação de inimigos elegíveis, congelamento, explosão, dano temporário aumentado, invulnerabilidade, coleta global, velocidade, recuperação.
- **Regras a definir por coletável:** coleta, magnetismo, permanência, limite no chão, prioridade, empilhamento, conversão de excesso, coleta automática, feedback.
- **Baús:** comuns, especiais, de chefe, secretos, de evento.
- **Economia de drops:** probabilidades, pesos, garantias, proteção contra azar, regras por estágio e por chefe, limites e repetição.

Pendência registrada desde a 0.1: o que fazer com orbes distantes (sumir, fundir ou puxar de longe) continua sem decisão.

---

## 18. Coleções, bestiário e descobertas

**Estado:** nada existe. Tudo `PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO`.

- **Coleções:** armas, evoluções, passivos, equipamentos, amuletos, anéis, relíquias, runas, catalisadores, captadores, personagens, estágios, chefes, inimigos, eventos.
- **Bestiário (ficha):** nome, imagem, categoria, região, história, atributos descobertos, habilidades, resistências, vulnerabilidades, recompensas, quantidade derrotada. O jogo **já conta** abates por tipo de inimigo durante a partida (`RunStats.kills_by_kind`), mas não guarda isso entre partidas.
- **Descobertas:** primeira obtenção, primeira evolução, primeiro chefe derrotado, segredo, estágio concluído, combinação, personagem desbloqueado.
- **Conteúdo oculto:** pistas sem revelar todas as respostas.

**Dependências:** persistência (o save já tem versão e migração, seção 30), identificação dos conteúdos por ID permanente, interface.

---

## 19. Progressão durante a partida

### 19.1. Existente (todos `APROVADO` · `IMPLEMENTADO` · `TESTADO`)

| Elemento | Regra (código) |
|---|---|
| XP por inimigo | Errante 1, Espreitador 1, Couraçado 4, Lançador 2, Volátil 2; chefe 0 |
| Curva | XP para sair do nível n = `round(4 × n^1,35)` (4, 10, 18, 26, 35…; nível 10 = 90) |
| Vários níveis de uma vez | cada nível abre sua escolha, em sequência |
| Cura por nível | 12% da vida máxima |
| Pausa | `SceneTree.paused`; o painel trava 0,35 s ao abrir |
| Ofertas | até 3, distintas e válidas: arma nova (com espaço livre), evolução (abaixo do nível 5), melhoria (abaixo do limite) |
| Pesos | arma nova 2,2 nas 6 primeiras telas e 1,4 depois; evolução 1,4; Núcleo vital 2,0 com vida abaixo de 50%; demais 1,0 |
| Trocar (reroll) | 2 por partida (+1 por nível de Renovação); não consome o nível; evita repetir as opções da tela |
| Bloquear | 2 por partida; remove a oferta da partida e põe outra no cartão; recusado se for a última opção válida |
| Sem ofertas válidas | o nível conta e o jogador recupera 25 de vida |

### 19.2. A estudar (`PROPOSTO_NAO_APROVADO`)

Habilidades e modificadores como ofertas; recompensas especiais no level-up; ofertas que consideram sinergias declaradas no catálogo (hoje o peso não olha sinergias).

**Testes existentes:** `tests/suites/progressao.gd` e `tests/suites/armas_e_ofertas.gd`; Playwright toca em Trocar, Bloquear e nos cartões.

---

## 20. Progressão permanente

### 20.1. Existente

| Elemento | D | I | V | Regra (código) |
|---|---|---|---|---|
| Ecos | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | 1 a cada 20 s, 1 a cada 15 abates, 40 por chefe derrotado |
| Vigor ancestral | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | +8% de vida/nível; 5 níveis; 15, 30, 50, 75, 110 Ecos |
| Fúria latente | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | +5% de dano/nível; 5 níveis; 20, 40, 65, 95, 130 |
| Atração do eco | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | +20% de raio do ímã/nível; 3 níveis; 12, 25, 45 |
| Renovação | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | +1 troca/nível; 2 níveis; 40, 90 |
| Save versionado | `APROVADO` | `IMPLEMENTADO` | `TESTADO` | `user://progresso.json`, versão 1; ver 30 |

Todos os bônus permanentes têm **limite**, o que segue o princípio de evitar bônus cumulativos ilimitados.

### 20.2. A estudar (`PROPOSTO_NAO_APROVADO`)

Desbloqueios (personagens, armas, estágios); maestria de armas, personagens, elementos, estágios e chefes; outros recursos permanentes. Princípio: ampliar possibilidades **sem** tornar a habilidade do jogador irrelevante. Cidade simples (roadmap, fase 2, `APROVADO` · `NÃO_IMPLEMENTADO`) pode ser o lugar da loja permanente; isso não foi decidido.

---

## 21. Economia, comércio e fabricação

**Estado:** a economia atual tem **um recurso**, os Ecos, com origem (fim da partida), finalidade (4 melhorias), limite (as melhorias têm nível máximo; os Ecos não têm teto) e destino (loja na tela de resultados). Não há comércio, NPCs nem fabricação.

Tudo abaixo é `PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO`:

- **Ficha de recurso:** origem, finalidade, raridade, limites, destino.
- **Fabricação:** criação, aprimoramento, reforja, conversão, desmontagem, reciclagem, componentes, catalisadores.
- **NPCs especialistas:** mercador, ferreiro, artesão, alquimista, colecionador, pesquisador, especialista em relíquias.
- **Princípios de economia saudável:** evitar inflação; evitar recursos sem finalidade; evitar custos desproporcionais; permitir decisões significativas; evitar grind obrigatório.

Observação sobre os Ecos: quando todas as melhorias chegam ao máximo, os Ecos passam a não ter finalidade (inflação). Isso deve ser resolvido antes de aumentar a economia.

---

## 22. NPCs e facções

**Estado:** não existem. Tudo `PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO`.

- **Ficha de NPC:** identidade, função, história, localização, diálogos, serviços, missões, relações.
- **Facções:** aliadas, neutras, hostis, organizações, cultos, ordens, povos, mercenários.
- **A estudar:** reputação, alianças, recompensas, consequências, desbloqueios.

**Dependências:** narrativa (23), cidade (roadmap fase 2), missões (16), economia (21).

---

## 23. História, narrativa e lore

**Estado:** não existe lore. Os nomes atuais (Eudora, Raio arcano, Aura de brasas, Lâmina orbital, Errante, Espreitador, Couraçado, Lançador, Volátil, Sentinela do Eco, Ecos, Vigor ancestral, Fúria latente, Atração do eco, Renovação) são nomes de jogo, **sem história definida**. Tudo abaixo é `PROPOSTO_NAO_APROVADO`:

- **Mundo:** origem, história, cosmologia, elementos, magia, conflitos, civilizações, catástrofes, personagens históricos.
- **Narrativa:** história principal, regional, de personagens, de chefes, de facções; registros; segredos; consequências.
- **Codex:** regiões, criaturas, personagens, facções, itens, relíquias, eventos, história, descobertas.

**Regra:** todo conteúdo pertence à identidade original de Crônicas de Eudora (seção 35). O nome "Eco" já aparece em Ecos, Sentinela do Eco e Atração do eco; se ele virar um conceito do mundo, isso será uma decisão narrativa a registrar.

---

## 24. Interação com o ambiente

**Estado:** o ambiente não tem objetos interativos. Tudo `PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO`.

A estudar: destruição de objetos, baús, alavancas, portais, altares, santuários, rupturas, fontes elementais, armadilhas, estruturas secretas, objetos de missão, pontos de extração.

**Regra:** toda interação tem resposta visual e funcional clara. No celular, a interação deve ser **contextual** (encostar, ficar perto), seguindo a diretriz aprovada de reduzir botões.

---

## 25. Modos de jogo e dificuldade

**Estado:** um modo (partida de 10 minutos com chefe final) e uma dificuldade fixa. `APROVADO` · `IMPLEMENTADO` · `TESTADO`.

Tudo abaixo é `PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO`:

- **Modos:** campanha, sobrevivência, arena, desafio, chefe, exploração, infinito, eventos especiais.
- **Dificuldades:** normal, difícil, extrema, desafios modificados.
- **Modificadores:** inimigos, vida, dano, recursos, tempo, resistências, chefes adicionais, recompensas.

**Princípio:** a dificuldade aumenta o desafio de forma compreensível (novos padrões, novos tipos, menos respiro), e não só multiplica vida e dano. Os valores atuais de crescimento (vida +35%/min, leva +1 a cada 30 s) são o ponto de partida medido em simulação, ainda sem validação com pessoas.

---

## 26. Conquistas e objetivos de longo prazo

**Estado:** não existem. O save guarda só partidas, vitórias, melhor tempo e abates totais. Tudo `PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO`.

A estudar: conquistas, marcos, maestria, coleções, chefes derrotados, builds descobertas, regiões concluídas, objetivos secretos. **Regra:** cada conquista tem uma condição verificável (que um teste automático consiga conferir) e uma recompensa coerente. Sem serviços externos de conquistas (custo zero).

---

## 27. Interface e experiência do jogador

### 27.1. Telas

| Tela | D | I | V |
|---|---|---|---|
| Partida (HUD) | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |
| Level-up | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |
| Resultados (com loja permanente) | `APROVADO` | `IMPLEMENTADO` | `TESTADO` |
| Configurações (pausa) | `APROVADO` (necessária para destro/canhoto e joystick) | `IMPLEMENTADO` (PR #10) | `TESTADO` |
| Menu principal, seleção de personagem, seleção de estágio, base, inventário, equipamentos, habilidades, coleções, bestiário, codex, fabricação, missões | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` | — |

### 27.2. HUD atual

Tempo e abates; barra de vida; nível e barra de XP; linha das armas com níveis (★ e o nome da evolução, quando evoluída); barra do chefe (só no encontro); avisos no meio da tela; indicador "Esquiva pronta"; FPS e número de inimigos. **0.4 (PR #10):** botão de pausa "II" e uma linha de evento (progresso da Fenda do Eco, Maré, Calmaria). Na tela deitada, as barras ficam numa coluna central de até 720 de largura. **Não existem:** efeitos/estados, objetivos e recursos no HUD.

### 27.3. Mobile e desktop

Ver seção 7.2 para as diretrizes mobile aprovadas. Desktop atual: WASD, setas, Espaço, 1–3, R e mouse (o mouse funciona como dedo). Proporções: retrato (base 720 × 1280) e paisagem testados por emulação.

---

## 28. Acessibilidade

**Estado:** não há opções de acessibilidade. Existem só práticas no design atual: avisos de ataque por **forma** (faixa, círculos, anel) além da cor, e uma pausa segura (o level-up congela tudo; o joystick retoma sem gestos fantasmas).

A estudar (`PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO`): escala de interface, contraste, tamanho de texto, indicadores visuais, redução de efeitos, redução de tremor, áudio, controles configuráveis, alternativas a informações só por cor, pausa e retomada seguras (manual, fora do level-up).

---

## 29. Áudio e identidade sensorial

**0.4 (PR #10):** som **procedural** (gerado no código ao abrir o jogo, sem arquivos de áudio nem serviços externos; 12 sons: golpe, abate, orbe, dano, explosão, esquiva, nível, alerta, evolução, fenda, chefe, vitória; 10 vozes, com intervalo mínimo por som para não saturar), números de dano só em golpes no chefe e em elites (até 24 ao mesmo tempo), estouro colorido no chão em cada abate (até 6 por quadro) e tremor de câmera. Tudo `PROPOSTO_NAO_APROVADO` (experimental) · `IMPLEMENTADO` (PR #10) · `TESTADO`, com opções para desligar som, tremor e números. **O som não foi ouvido por uma pessoa** nesta etapa: só a geração e a reprodução foram conferidas por teste.

**Estado até a 0.3:** o jogo **não tinha som**. Os efeitos visuais são provisórios: piscada branca ao levar dano, brilho dos inimigos antes de atacar, círculos e faixas de aviso, anel da esquiva, onda da Aura, rastro da Lâmina. Arte e som finais: `APROVADO` para a fase 2 ("1 fase com arte e som finais") · `NÃO_IMPLEMENTADO`.

A estudar (`PROPOSTO_NAO_APROVADO`): música por região, chefes e combate; sons de habilidades, armas, impactos, coleta, evoluções, alertas e interface; ambiência; identidade elemental, de raridade, de dano, de perigo e de estados. **Regra:** evitar poluição visual e perda de legibilidade; com 300 inimigos na tela, cada efeito novo precisa caber no orçamento de desempenho.

---

## 30. Arquitetura técnica e dados

### 30.1. Arquitetura atual (fonte: `docs/TECNICO.md`, decisões 0001–0010)

- Godot 4.7.2, GDScript, Compatibility Renderer, exportação Web sem threads, GitHub Pages (`gh-pages`).
- Partida montada em código (`scripts/main.gd`); um `class_name` por sistema.
- **Definições de conteúdo:** `WeaponCatalog`, `EnemyTypes`, `Upgrades.DEFINITIONS`, `MetaProgress.UPGRADES` (constantes em GDScript).
- **Estado da partida:** `Arsenal`, `Upgrades` (pilhas), `LevelUpOffers`, `Progression`, `RunStats`.
- **Estado permanente:** `MetaProgress`.
- **Regras de cálculo:** `Upgrades.refresh()` (recalcula da base).
- **Execução de combate:** `AutoWeapon`, `AuraWeapon`, `OrbitBlades`, `EnemyManager` (desenho no `EnemyRenderer`), `EnemyProjectiles`, `BossController`, `GroundEffects`.
- **Interface:** `Hud`, `LevelUpPanel`, `ResultsScreen`, `FloatingJoystick`.
- **Persistência:** JSON versionado com escrita atômica, migração, proteção contra versão futura e validação de estrutura e de campos (manutenção pós-0.3).
- **Telemetria:** `RunStats` e as simulações de `tests/`.
- **Builds:** produção (`Web`, publicada) e QA (`Web QA`, com a ponte de testes, só no CI).

### 30.2. Desempenho de referência (atual)

Até 300 inimigos (o chefe fora do limite) e 400 orbes; arrays + `MultiMesh`; grade espacial de 1,5 m; remoção por troca com o último; limites de 160 efeitos e 240 projéteis inimigos; sem um nó por entidade. Medições: relatório da 0.3 (tempos de CPU sem renderização; não representam celular).

### 30.3. Arquitetura planejada e recomendações

| Item | D | I |
|---|---|---|
| Configurações persistentes (destro/canhoto, joystick) | `APROVADO` | `IMPLEMENTADO` (PR #10, `GameSettings`, `user://configuracoes.json`) |
| Definições de conteúdo em arquivos de dados (JSON ou recursos) em vez de constantes | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` |
| Estruturas para habilidades, itens, relíquias, estágios, eventos, missões, recompensas | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` |
| Estados de combate em arrays do `EnemyManager` | `PROPOSTO_NAO_APROVADO` (experimental) | `IMPLEMENTADO` (PR #10) |
| Pooling | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` (os arrays atuais já evitam criar e destruir objetos) |
| Persistência de coleções, conquistas e inventário | `PROPOSTO_NAO_APROVADO` | `NÃO_IMPLEMENTADO` |

Regra: toda estrutura nova preserva a arquitetura compatível com mobile (decisão 0003) e todo formato salvo tem versão e migração (AGENTS.md).

---

## 31. Telemetria e balanceamento

### 31.1. O que já é medido (`RunStats`, todos `IMPLEMENTADO` · `TESTADO`)

Tempo de sobrevivência; dano por arma; dano por tipo de inimigo; abates por arma e por tipo; dano recebido por origem; esquivas; explosões; momento em que o chefe surgiu e caiu; dano dado e recebido no encontro; XP coletada.

**Não medido:** escolhas de level-up, rerolls e bloqueios usados, evoluções, uso de itens, builds (registro agregado), dano por habilidade. Nada é enviado para fora do jogo: não há telemetria online (custo zero e privacidade).

### 31.2. Ferramentas

`tests/balance_simulation.gd` (`dps`, `partida`, `chefe`) e `tests/long_simulation.gd`. **Regra:** balancear com evidência; registrar números e mudanças no relatório da versão. O piloto automático é simples e **não** substitui pessoas.

---

## 32. Testes e validação

### 32.1. O que existe hoje

| Tipo | Ferramenta | Situação |
|---|---|---|
| Unitários e de integração | `tests/run_tests.gd` + 5 suítes (51 testes) | `TESTADO` no CI |
| Ponta a ponta sem tela | `tests/smoke_test.gd` | `TESTADO` |
| Desempenho e reinícios | `tests/long_simulation.gd` (300 s no CI) | `TESTADO` |
| Balanceamento | `tests/balance_simulation.gd` | rodado manualmente, fora do CI |
| Navegador (emulação) | Playwright: computador 1366 × 768, Pixel 7 em pé 412 × 915 e deitado 915 × 412, na build de QA; a build de produção também é aberta para conferir que não tem a ponte de testes | `TESTADO` |
| Estilo do código | `gdlint`, `gdformat` | `TESTADO` |
| Celular físico | — | **nunca feito** |
| Jogabilidade com pessoas | — | **nunca feito** |

### 32.2. Planejado (`PROPOSTO_NAO_APROVADO`, exceto o teste com pessoas)

- **Teste com 5 a 10 pessoas em celular** (critério de saída da fase 1 no roadmap): `APROVADO` · `NÃO_IMPLEMENTADO`.
- Unitários para atributos, estados, drops, combinações; integração entre armas e passivos, habilidades e modificadores, relíquias e elementos, inimigos e estados, chefes e ataques, recompensas e inventário.
- Jogabilidade: builds fracas, fortes e híbridas; dificuldades; chefes; eventos; derrota; vitória.

**Regra:** sempre distinguir teste automático, emulação e teste físico.

---

## 33. Catálogos Mestres

Os 30 catálogos estão indexados em [`catalogos/README.md`](catalogos/README.md), com escopo, dependências, estado e localização. O formato de cada entrada está em [`catalogos/MODELO_ENTRADA.md`](catalogos/MODELO_ENTRADA.md).

Nesta versão 0.1, foram criados os catálogos que já têm conteúdo comprovado no código: **01 Personagens e classes**, **02 Atributos**, **03 Armas**, **05 Passivos**, **12 Inimigos**, **14 Chefes**, **18 Captadores**, **26 Recursos e economia** e **30 Testes e balanceamento**. Os outros 21 estão indexados como planejados, **sem entradas fictícias**.

---

## 34. Matriz de dependências entre sistemas

Legenda: **●** depende diretamente · **○** depende em parte. A coluna "Hoje" diz se a dependência já existe no código.

| Sistema | Depende de | Hoje |
|---|---|---|
| Armas | atributos ●, dano ●, colisão ● (`EnemyManager`), inimigos ●, progressão ● (ofertas), estatísticas ○ | sim |
| Passivos | atributos ●, armas ● | sim |
| Ofertas do level-up | armas ●, passivos ●, arsenal ●, progressão ●, progressão permanente ○ (Renovação) | sim |
| Inimigos | combate ●, efeitos no chão ○, projéteis inimigos ○, progressão ○ (XP) | sim |
| Chefe | inimigos ● (corpo no `EnemyManager`), IA ● (`BossController`), ataques ●, avisos ●, recompensas ○ | sim |
| Esquiva | controles ●, invulnerabilidade ●, efeitos ○ | sim |
| Resultados | estatísticas ●, armas ●, passivos ●, progressão permanente ● | sim |
| Progressão permanente | resultados ●, persistência ●, atributos ● | sim |
| Evoluções | armas ●, passivos ●, catalisadores ○, aquisição ● | não |
| Relíquias | efeitos globais ●, modificadores ● | não |
| Estágios | geografia ●, inimigos ●, eventos ○, progressão ○ | não |
| Captadores | drops ●, coleta ●, inventário ○, economia ○ | parcial (orbes) |
| Coleções | descoberta ●, persistência ● | não |
| Fabricação | recursos ●, receitas ●, inventário ● | não |
| Missões | objetivos ●, eventos ●, progresso ●, recompensas ● | não |
| Bestiário | identificação ●, descoberta ●, registro de inimigos ● (`RunStats.kills_by_kind` existe só na partida) | não |
| Configurações de controle | persistência ●, joystick ●, interface ● | não |
| Balanceamento | telemetria ● (`RunStats`), simulações ● | sim |

Cada entrada de catálogo declara as próprias dependências (campo obrigatório do modelo).

---

## 35. Diretrizes de produção de conteúdo

Cada entrada de conteúdo tem, conforme aplicável: ID permanente · nome original · categoria · descrição · função · valores · efeitos · requisitos · sinergias · limitações · raridade · referência visual · estado de design · estado de implementação · estado de validação (modelo em [`catalogos/MODELO_ENTRADA.md`](catalogos/MODELO_ENTRADA.md)).

Regras (do proprietário, `APROVADO`):

1. **Não copiar** nomes, textos, imagens, personagens, mapas, ícones ou propriedades de outras franquias.
2. A inspiração é **conceitual e mecânica**, nunca de conteúdo.
3. Crônicas de Eudora tem identidade própria.
4. O **ID permanente** não muda depois de publicado (ele aparece no save e nas estatísticas). IDs atuais: `raio_arcano`, `aura_de_brasas`, `lamina_orbital`, `poder_arcano`, `cadencia`, `nucleo_vital`, `passos_ligeiros`, `projetil_adicional`, `campo_de_ruptura`, `vigor_ancestral`, `furia_latente`, `atracao_do_eco`, `renovacao`. Inimigos usam um número de tipo (`EnemyTypes.COMUM` = 0 … `CHEFE` = 5), não um texto.
5. Nada de conteúdo em massa sem regras aprovadas para a categoria.

---

## 36. Ordem recomendada de desenvolvimento

> **Proposta de organização (`PROPOSTO_NAO_APROVADO`).** Não substitui nem altera o roadmap oficial. A próxima entrega aprovada continua sendo a definida no `docs/ROADMAP.md` (teste com pessoas e pendências da fase 1).

| Fase | Conteúdo | Já existe |
|---|---|---|
| **Fundação** | arquitetura de dados, atributos, combate, estados, dano, progressão básica | arquitetura, atributos básicos, dano, progressão; **sem** estados |
| **Combate expandido** | armas, habilidades, passivos, inimigos, chefes, evoluções, sinergias | 3 armas, 6 passivos, 5 inimigos, 1 chefe, sinergias simples |
| **Mundo** | estágios, regiões, eventos, objetivos, exploração, interações | — |
| **Progressão** | equipamentos, relíquias, coleções, bestiário, economia, fabricação, desbloqueios | Ecos e 4 melhorias |
| **Profundidade** | classes, especializações, missões, facções, história, conteúdo secreto, modos | — |
| **Qualidade** | balanceamento, acessibilidade, interface, áudio, desempenho, testes, documentação | testes e documentação |

Dependência mais forte: estados de combate e elementos (Fundação) precisam vir antes de relíquias, runas, catalisadores e elites com modificadores elementais.

---

## 37. Regras de governança

1. O Documento Mestre **não autoriza** automaticamente a implementação das propostas.
2. O `docs/ROADMAP.md` continua definindo as entregas aprovadas.
3. Novas ideias entram como `PROPOSTO_NAO_APROVADO`.
4. Decisões aprovadas são registradas (em `docs/decisoes/` quando técnicas, e atualizando o estado de design aqui, com a fonte).
5. Mudanças de escopo são explícitas.
6. Nenhum conteúdo é `VALIDADO` sem teste com pessoas.
7. Nenhum sistema é duplicado por falta de consulta: antes de criar algo, procure aqui e nos catálogos.
8. A documentação acompanha a implementação (um PR que muda um sistema atualiza os estados deste documento).
9. A `main` permanece protegida.
10. Alterações são entregues por Pull Request.
11. Os estados de design, implementação e validação são independentes.
12. A documentação não substitui o código como evidência do funcionamento atual.

**Manutenção:** o Claude Code atualiza os estados de implementação e validação quando entrega uma etapa; mudanças no estado de design só com decisão do proprietário (ver `AGENTS.md`).

---

## 38. Fontes de pesquisa e histórico do documento

### 38.1. Referências de design

As quatro fontes indicadas pelo proprietário servem para estudar **princípios e estruturas**, nunca para copiar conteúdo:

| Fonte | Endereço | Sistemas a estudar | Consultada nesta versão? |
|---|---|---|---|
| Diablo IV (wiki Fextralife) | https://diablo4.wiki.fextralife.com/Diablo_4_Wiki | classes, habilidades, atributos, equipamentos, afixos, aspectos, aprimoramento, chefes, masmorras, eventos, regiões, progressão | **Não** |
| Vampire Survivors (wiki) | https://vampire.survivors.wiki/ | personagens, armas, evoluções, passivos, PowerUps, captadores, relíquias, Arcanas, estágios, inimigos, coleções, segredos | **Não** |
| Path of Exile (wiki) | https://www.poewiki.net/wiki/Path_of_Exile_Wiki | classes, habilidades, gemas, suportes, árvore passiva, modificadores, equipamentos, criação, economia, estados, monstros, mapas, chefes | **Não** |
| Path of Exile 2 (wiki) | https://www.poewiki.net/wiki/Path_of_Exile_2 | classes, especializações, habilidades, gemas, suportes, habilidades de itens, equipamentos, recursos, fabricação, chefes, regiões | **Não** |

Nesta versão **nenhuma fonte foi consultada**: o acesso às páginas pedia uma aprovação que não foi respondida durante a sessão. Por isso não há, ainda, o registro de "princípio observado → aplicação → adaptação". Quando uma fonte for consultada, registre na tabela abaixo:

| Fonte | Data | Sistema estudado | Princípio ou mecanismo observado | Possível aplicação em Eudora | Adaptação para identidade original | Estado da ideia |
|---|---|---|---|---|---|---|
| — | — | — | — | — | — | — |

### 38.2. Histórico do Documento Mestre

| Versão | Conteúdo | Situação |
|---|---|---|
| 0.1 | estrutura geral das 38 áreas, inventário da 0.3-alpha com os três estados, índice dos 30 catálogos, modelo de entrada, 9 catálogos com conteúdo comprovado | 26/11/2026 |
| **0.1.1** | estados atualizados com a etapa "O Despertar de Eudora" (PR #10): estados de combate, evoluções, Pacto do eco, Tecelão, Semeador, elites, chefe, eventos, configurações mobile, som e retorno visual | 26/11/2026 |
| **0.1.2** | 0.4-alpha integrada: estados `EM_DESENVOLVIMENTO (PR #10)` → `IMPLEMENTADO (PR #10)`; texto da Atração do eco corrigido no jogo; desenho dos inimigos separado no `EnemyRenderer` | **esta versão** (27/11/2026) |
| 0.2 | catálogos detalhados e matrizes de relações | planejada |
| 0.3 | regras completas de sistemas e dados | planejada |
| 0.4 | conteúdo original e balanceamento inicial | planejada |
| 1.0 | documento mestre aprovado | planejada |

As versões futuras são planejamento, não entregas realizadas.
