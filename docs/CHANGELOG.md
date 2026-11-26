# Changelog

Registro das mudanças funcionais de Crônicas de Eudora, da mais recente para a mais antiga.

**Responsável editorial: ChatGPT.** O Claude Code entrega os dados de cada etapa em `docs/IA/ENTREGA_PARA_CHATGPT.md`. As entradas abaixo até a etapa de infraestrutura foram escritas pelo Claude Code, para iniciar o registro.

Categorias: **Jogabilidade**, **Interface**, **Desempenho**, **Correção**, **Testes**, **Infraestrutura**, **Documentação**.

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
