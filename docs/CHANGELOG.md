# Changelog

Registro das mudanças funcionais de Crônicas de Eudora, da mais recente para a mais antiga.

**Responsável editorial: ChatGPT.** O Claude Code entrega os dados de cada etapa em `docs/IA/ENTREGA_PARA_CHATGPT.md`. As entradas são mantidas editorialmente pelo ChatGPT a partir dos relatórios técnicos do Claude Code.

Categorias: **Jogabilidade**, **Interface**, **Desempenho**, **Correção**, **Testes**, **Infraestrutura**, **Documentação**.

---

## Manutenção pós-0.3-alpha + Documento Mestre de Sistemas

**Data:** 26/11/2026 · **Pull Request:** [#7](https://github.com/ederkm40/Cronicas-de-Eudora/pull/7) · **Merge:** `202965a3f1f0f9b18de0d63773da93e2a1ded475`. Esta etapa **não é uma nova versão de gameplay**: a versão oficial continua 0.3-alpha. Não houve mudança de equilíbrio, conteúdo, progressão ou economia.

| Categoria | Descrição | Motivo | Efeito no jogo | Arquivos | Testes |
|---|---|---|---|---|---|
| Infraestrutura | Separação definitiva entre build de produção (`Web`), sem ponte de QA, e build `Web QA`, usada somente nos testes automatizados | Impedir que ferramentas de teste sejam incluídas no jogo publicado | `?teste=1` não ativa mais a ponte; somente a build de produção é publicada | `export_presets.cfg`, `scripts/main.gd`, `scripts/web_bridge.gd`, `tools/ci/`, workflow | Verificação: produção 0 referências à ponte, QA 3; Playwright em produção |
| Correção | Validação de estrutura e tipos do arquivo de progresso | Evitar que saves danificados interrompam a leitura ou apaguem dados válidos | Estrutura inválida é preservada em cópia `.corrompido` e inicia progresso novo; campo inválido é corrigido individualmente; versão futura não é sobrescrita | `scripts/meta_progress.gd` | Suíte `save_e_joystick`; conferência ao contrário |
| Correção | Retomada correta do joystick após o level-up | Evitar que o jogador precise soltar e tocar novamente depois da pausa | Dedo mantido retoma o controle; dedo solto deixa o joystick neutro; toques durante a pausa não viram movimento ou esquiva | `scripts/floating_joystick.gd` | 5 testes Godot e Playwright nos 3 perfis emulados |
| Testes | Executor registra suíte inválida como falha, em vez de travar; cobertura ampliada | Tornar falhas de testes visíveis e confiáveis | Nenhuma mudança de gameplay | `tests/run_tests.gd`, `tests/suites/save_e_joystick.gd` | 51 testes, 4.482 verificações, 0 falhas |
| Documentação | Criação do Documento Mestre de Sistemas, com 38 áreas e 30 catálogos | Organizar sistemas, dependências e estados de design, implementação e validação | Não autoriza implementação nem altera a roadmap | `docs/design/DOCUMENTO_MESTRE_SISTEMAS.md`, `docs/design/catalogos/` | 9 catálogos com conteúdo comprovado pelo código; 21 planejados sem entradas fictícias |
| Limpeza | Remoção de `scripts/main.gd.orig` | Retirar arquivo temporário versionado | Nenhum | `scripts/main.gd.orig` | Busca por temporários versionados |

**Validação registrada no PR #7:** smoke test e simulação de 300 s aprovados; Wiki (14 testes) e montagem do site (7 testes) aprovadas; Playwright na QA (21 aprovados, 3 pulados por desenho) e na produção (11 aprovados, 1 pulado por desenho), nos três perfis. Não houve teste em celular físico nem teste com pessoas. Detalhes: `docs/versoes/manutencao-pos-0.3/RELATORIO.md`.

---

## 0.3-alpha: grande expansão do combate (publicada)

**Data:** 26/11/2026 · **Pull Request:** #5 Detalhes e números em `docs/versoes/0.3-alpha/RELATORIO.md`.

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
