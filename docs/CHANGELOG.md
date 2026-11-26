# Changelog

Registro das mudanças funcionais de Crônicas de Eudora, da mais recente para a mais antiga.

**Responsável editorial: ChatGPT.** O Claude Code entrega os dados de cada etapa em `docs/IA/ENTREGA_PARA_CHATGPT.md`. As entradas abaixo até a etapa de infraestrutura foram escritas pelo Claude Code, para iniciar o registro.

Categorias: **Jogabilidade**, **Interface**, **Desempenho**, **Correção**, **Testes**, **Infraestrutura**, **Documentação**.

---

## 0.3-alpha: grande expansão do combate (em revisão)

**Data:** 26/11/2026 · **Pull Request:** #5 · *Entrada escrita pelo Claude Code a pedido do proprietário; a revisão editorial continua com o ChatGPT.* Detalhes e números em `docs/versoes/0.3-alpha/RELATORIO.md`.

| Categoria | Descrição | Motivo | Efeito no jogo | Arquivos | Testes |
|---|---|---|---|---|---|
| Jogabilidade | Armas novas **Aura de brasas** (pulsos de dano em área) e **Lâmina orbital** (lâminas que giram e cortam), cada uma num espaço próprio, com 5 níveis | Variedade de combate (0.3) | Mais escolhas de build; o Raio arcano continua como arma inicial | `scripts/weapon_catalog.gd`, `arsenal.gd`, `aura_weapon.gd`, `orbit_blades.gd` | suíte `armas_e_ofertas` |
| Jogabilidade | Level-up oferece arma nova, evolução de arma ou melhoria; **trocar opções** (2 por partida) e **bloquear** (2 por partida) | Escolhas com mais controle | Cartões com o tipo da oferta e o que muda | `scripts/level_up_offers.gd`, `level_up_panel.gd` | suíte `armas_e_ofertas`, navegador |
| Jogabilidade | 4 inimigos novos: Espreitador (rápido), Couraçado (resistente), Lançador (atira com aviso), Volátil (explode com aviso) | Antecipação da 0.4 | Entram aos 45 s, 100 s, 150 s e 210 s | `scripts/enemy_types.gd`, `enemy_manager.gd`, `enemy_projectiles.gd`, `ground_effects.gd` | suíte `inimigos_e_chefe` |
| Jogabilidade | **Sentinela do Eco** aos 10 minutos: investida, erupção e rajada com aviso, fase 2 abaixo de 50% | Antecipação da 0.4 e do fim de partida da 0.6 | A partida só é vencida derrotando o chefe | `scripts/boss_controller.gd`, `main.gd` | suíte `inimigos_e_chefe`, navegador |
| Jogabilidade | **Esquiva** por duplo toque no joystick (ou Espaço): 4 m, invulnerável por 0,32 s, recarga de 1,4 s | Antecipação da 0.5 | Mais recursos de movimento sem botão novo | `scripts/floating_joystick.gd`, `player.gd` | suíte `esquiva_e_encerramento`, navegador |
| Interface | Tela de **resultados** (vitória ou derrota) com estatísticas reais e reinício limpo; barra do chefe, linha de armas e indicador de esquiva no HUD | Antecipação da 0.6 | Resumo de cada partida | `scripts/results_screen.gd`, `run_stats.gd`, `hud.gd` | suíte `esquiva_e_encerramento`, navegador |
| Jogabilidade | **Ecos** e 4 melhorias permanentes, salvos no navegador | Primeira progressão entre partidas | Bônus moderados a partir da partida seguinte | `scripts/meta_progress.gd` | suíte `esquiva_e_encerramento` |
| Jogabilidade | Equilíbrio: vida dos inimigos +35%/min (era 60%), leva +1 a cada 30 s (era 25 s), cada nível cura 12% da vida, Poder arcano vale para todas as armas | Simulações mostraram derrota antes dos 5 min sem cura | Partidas mais longas; o chefe é alcançável | `scripts/enemy_manager.gd`, `main.gd`, `upgrades.gd` | `tests/balance_simulation.gd` |
| Desempenho | Colisão dos projéteis do Raio pela grade espacial (antes, cada projétil comparava com todos os inimigos) | Mais projéteis e inimigos | Sem efeito visível | `scripts/enemy_manager.gd` | testes de efeito, simulação longa |
| Testes | 25 testes novos (41 no total) em 4 suítes; testes de navegador com controles reais; falha automática com erro de script no log | Cobrir os sistemas novos | — | `tests/`, `tools/e2e/`, `tools/ci/rodar_godot.sh` | CI |

---

## Infraestrutura: Wiki, prévias e memória (em revisão)

**Data:** 26/11/2026 · **Versão do jogo:** continua 0.2-alpha · **Pull Request:** ver `docs/versoes/0.2-alpha-infra/RELATORIO.md`

| Categoria | Descrição | Motivo | Efeito no jogo | Arquivos | Testes |
|---|---|---|---|---|---|
| Infraestrutura | Publicação passa a usar o branch `gh-pages`: jogo oficial na raiz, Wiki em `/wiki/`, prévias em `/previews/pr-N/` | Permitir testar cada Pull Request antes do merge sem substituir a versão oficial | nenhum | `.github/workflows/publicar.yml`, `tools/site/` | `tools/site/test_montar_site.py` |
| Infraestrutura | Prévia jogável e Wiki candidata para cada Pull Request do próprio repositório, atualizada a cada envio e removida ao fechar | O proprietário precisa testar antes de aprovar | nenhum | `.github/workflows/publicar.yml` | verificação de URL no workflow |
| Documentação | Wiki pública com 12 categorias e painel de desenvolvimento, gerada por script próprio em Python | Documentação acessível, editável artigo por artigo | nenhum | `wiki-src/`, `tools/wiki/` | `tools/wiki/test_wiki.py` |
| Documentação | `AGENTS.md`, `docs/IA/`, relatórios por versão, decisões técnicas e este changelog | Permitir que qualquer IA continue o projeto | nenhum | `AGENTS.md`, `docs/` | — |

## 0.2-alpha: Ecos da Evolução

**Data:** 26/11/2026 · **Pull Request:** #1 · **Merge:** `e516f21`

| Categoria | Descrição | Motivo | Efeito no jogo | Arquivos | Testes |
|---|---|---|---|---|---|
| Jogabilidade | Inimigos derrotados deixam orbes de experiência (1 XP), puxados a 3 m e coletados a 0,6 m | Primeiro sistema de progressão na partida | O jogador precisa circular para coletar | `scripts/xp_orbs.gd`, `scripts/main.gd` | `test_inimigo_derrotado_gera_orbe`, `test_coleta_de_orbes_por_proximidade` |
| Jogabilidade | Níveis com XP crescente: `round(4 × nível^1,35)` | Ritmo de evolução | 4, 10, 18, 26, 35… XP por nível | `scripts/progression.gd` | `test_acumulo_de_experiencia`, `test_subida_de_nivel`, `test_varios_niveis_de_uma_vez` |
| Jogabilidade | Level-up pausa tudo e oferece 3 melhorias diferentes | Escolhas de build | Partida congela durante a escolha | `scripts/main.gd`, `scripts/level_up_panel.gd` | `test_tres_opcoes_distintas`, `test_pausa_e_retomada` |
| Jogabilidade | 6 melhorias com limites: Poder arcano, Cadência, Núcleo vital, Passos ligeiros, Projétil adicional, Campo de ruptura | Primeiro conjunto de melhorias | Ver tabela em `docs/TECNICO.md` | `scripts/upgrades.gd`, `scripts/auto_weapon.gd`, `scripts/player.gd` | 6 testes de efeito + `test_acumulo_e_limites_das_melhorias` |
| Interface | Barra de XP e "Nv." no HUD; tela de derrota mostra o nível | Mostrar a progressão | — | `scripts/hud.gd` | `test_acumulo_de_experiencia` |
| Correção | Seta "→" dos cartões trocada por "»" | A fonte da versão web não tinha o símbolo (aparecia um quadradinho) | — | `scripts/upgrades.gd` | verificação visual no navegador |
| Testes | `run_tests.gd` (16 testes), smoke test ampliado, `long_simulation.gd` | Garantir que a progressão funciona de ponta a ponta | — | `tests/` | — |
| Infraestrutura | Workflow testa Pull Requests sem publicar | Não publicar versão em revisão | — | `.github/workflows/web.yml` | — |

## 0.1-alpha: Projeto base

**Data:** 26/11/2026 · **Commit:** `0dd647f` (enviado direto ao `main`, antes da regra de Pull Requests)

| Categoria | Descrição | Motivo | Efeito no jogo | Arquivos | Testes |
|---|---|---|---|---|---|
| Jogabilidade | Personagem com 100 de vida e 5 m/s, joystick flutuante, WASD e setas | Controles para celular com uma mão | — | `scripts/player.gd`, `scripts/floating_joystick.gd` | `smoke_test.gd` |
| Jogabilidade | Câmera isométrica ortográfica fixa, em retrato | Visão escolhida para o projeto | — | `scripts/camera_rig.gd` | `smoke_test.gd` |
| Jogabilidade | Arma automática (10 de dano, 0,45 s, 11 m) e hordas de até 300 inimigos | Núcleo do gênero | — | `scripts/auto_weapon.gd`, `scripts/enemy_manager.gd` | `smoke_test.gd` |
| Interface | HUD com tempo, abates, vida, FPS e inimigos; tela de derrota e reinício | — | — | `scripts/hud.gd` | `smoke_test.gd` |
| Desempenho | Inimigos e projéteis em arrays + MultiMesh, separação com grade espacial ordenada | 300 inimigos no navegador do celular | — | `scripts/enemy_manager.gd` | medição local |
| Infraestrutura | Exportação Web sem threads publicada no GitHub Pages a cada envio ao `main` | Testar no celular pelo navegador | — | `.github/workflows/web.yml` | — |
