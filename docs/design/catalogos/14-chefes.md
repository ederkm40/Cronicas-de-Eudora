# Catálogo 14: Chefes

### Sentinela do Eco

| Campo | Valor |
|---|---|
| **ID permanente** | tipo `EnemyTypes.CHEFE` (5) |
| **Categoria** | chefe do encontro final da partida |
| **Descrição** | surge aos 10:00 na borda de cima da tela; derrotá-lo vence a partida |
| **Função** | encontro final que exige movimentação e leitura de avisos |
| **Valores** | vida 3.800; contato 24/s; persegue a 2,4 m/s por 2,2 s entre ataques; recuperação 1,4 s (`scripts/boss_controller.gd`, `scripts/enemy_types.gd`) |
| **Ataques** | **Investida:** faixa vermelha por 1 s; atravessa 9 m a 16 m/s; 28 de dano · **Erupção:** círculos de 2 m por 1,1 s onde o jogador está, onde vai estar e 2 ao redor; 30 de dano · **Rajada:** brilho lilás por 0,7 s; anel de 14 projéteis de 12 de dano |
| **Fases** | fase 2 com vida ≤ 50%: avisos e pausas 25% mais curtos, 4 erupções ao redor em vez de 2, rajada dupla, 6 reforços (Voláteis e Espreitadores) |
| **Vulnerabilidades / resistências** | — / — |
| **Indicadores visuais** | coroa giratória, barra de vida no HUD, brilho nos avisos, piscada de dano |
| **Recompensas** | vitória e 40 Ecos |
| **Condições de surgimento** | 600 s de partida (aviso aos 590 s); hordas caem para 30% e sem Lançadores novos |
| **História** | — (não definida) |
| **Dependências** | `EnemyManager` (corpo), `BossController` (estados), `GroundEffects`, `EnemyProjectiles`, `RunStats` |
| **Estado de design** | `APROVADO` (0.3-alpha, antecipado da 0.4) |
| **Estado de implementação** | `IMPLEMENTADO` |
| **Estado de validação** | `TESTADO` (`inimigos_e_chefe.gd`: surgimento, avisos antes dos ataques, fase 2, vitória; Playwright: vitória e reinício). **Equilíbrio não validado com pessoas:** na última simulação o piloto automático sobreviveu, mas não derrotou o chefe |
| **Histórico** | 0.3: criado; vida 7.000 → 4.500 → 3.800 durante o balanceamento por simulação |

### Implementado na 0.4-alpha (PR #10, integrada à `main` em `f51db23`)

**D** `PROPOSTO_NAO_APROVADO` (experimental) · **I** `IMPLEMENTADO` (PR #10) · **V** `TESTADO` (`tests/suites/despertar.gd`).

| Mudança | Regra |
|---|---|
| Atordoado depois da investida | 2 s parado, com +50% de dano recebido; aviso "Ponto fraco exposto: ataque agora!" e brilho branco |
| Prisão de ecos (4º ataque) | anel de 10 círculos (raio 1,25 m) a 3,6 m do jogador, com uma saída de 2 círculos; aviso de 1,3 s (×0,75 na fase 2); 26 de dano em quem fica em cima |
| Ordem dos ataques | investida → erupção → rajada → prisão (repete) |
| Reforços da fase 2 | o primeiro dos 6 é um Tecelão (o escudo não protege o chefe) |
| Som | alerta no início de cada aviso; som próprio na fase 2 |

Piloto automático (`--modo=chefe`, sementes 1–3, build típica): 3 vitórias, 166 a 264 s de luta. Na 0.3, o piloto não derrotava o chefe. **O chefe pode ter ficado fácil demais: revisar no teste com pessoas.**
