# Changelog

Registro das mudanças funcionais de Crônicas de Eudora, da mais recente para a mais antiga.

**Responsável editorial: ChatGPT.** O Claude Code entrega os dados de cada etapa em docs/IA/ENTREGA_PARA_CHATGPT.md. As entradas são mantidas editorialmente pelo ChatGPT a partir dos relatórios técnicos do Claude Code.

Categorias: **Jogabilidade**, **Interface**, **Desempenho**, **Correção**, **Testes**, **Infraestrutura**, **Documentação**.

---

## Manutenção pós-0.4-alpha (PR #12)

**Data:** 27/11/2026 · **Merge:** PR #12 · **Versão do jogo:** permanece 0.4-alpha. Esta manutenção não alterou equilíbrio, conteúdo, progressão ou economia.

| Categoria | Descrição | Motivo | Efeito no jogo | Arquivos / sistemas | Testes |
|---|---|---|---|---|---|
| Correção | Texto da Atração do eco corrigido para “+20% no raio do ímã dos orbes por nível” | Descrever o efeito real da melhoria | Nenhuma mudança no efeito ou nos preços; a distância final de coleta continua em 0,6 m | scripts/meta_progress.gd | Teste de texto e efeito com dois níveis salvos; ímã resultante de 4,2 m |
| Arquitetura | Desenho dos inimigos extraído para EnemyRenderer | Liberar espaço no EnemyManager, que havia atingido o limite de 20 métodos públicos do gdlint | Nenhuma mudança visual, funcional ou de desempenho identificada | scripts/enemy_renderer.gd, scripts/enemy_manager.gd, scripts/camera_rig.gd; decisão técnica 0013 | Teste de desenho por tipo e geometria da tela |
| Documentação | Relatório da manutenção, decisão 0013, pacote de fatos para IA, Documento Mestre e catálogos atualizados | Alinhar documentação ao estado integrado da 0.4-alpha | Nenhum efeito na build | docs/versoes/manutencao-pos-0.4/, docs/decisoes/, docs/design/, docs/IA/ | Testes da Wiki e montagem do site aprovados |
| Testes | Cobertura ampliada em duas verificações | Proteger a correção do texto/efeito e a extração do desenho | Nenhum efeito na build | tests/suites/ | 73 testes, 4.624 verificações, 0 falhas; lint, smoke e simulação de 300 s aprovados |

**Desempenho:** a simulação de 300 s no main e na branch produziu resultados idênticos. As medições de CPU por quadro ficaram dentro do ruído do servidor, sem ganho ou perda identificável. Isso não representa medição em celular.

**Limites mantidos:** sem teste em celular físico ou com pessoas; os demais problemas conhecidos da 0.4 permanecem. A prévia do PR #12 e os testes de navegador foram verificados pelo workflow do GitHub, com perfis móveis emulados no Chromium.

Relatório técnico: [manutenção pós-0.4-alpha](https://github.com/ederkm40/Cronicas-de-Eudora/blob/main/docs/versoes/manutencao-pos-0.4/RELATORIO.md) · [PR #12](https://github.com/ederkm40/Cronicas-de-Eudora/pull/12) · [pacote de fatos](https://github.com/ederkm40/Cronicas-de-Eudora/blob/main/docs/IA/ENTREGA_PARA_CHATGPT.md).

---

## 0.4-alpha — O Despertar de Eudora (publicada)

**Data:** 26/11/2026 · **Pull Request:** [#10](https://github.com/ederkm40/Cronicas-de-Eudora/pull/10) · **Merge:** [f51db236fd0ae3954178b4354c6641729c58fdf8](https://github.com/ederkm40/Cronicas-de-Eudora/commit/f51db236fd0ae3954178b4354c6641729c58fdf8). A publicação no GitHub Pages foi concluída com sucesso no workflow [#45902410165](https://github.com/ederkm40/Cronicas-de-Eudora/actions/runs/45902410165).

| Categoria | Descrição | Motivo | Efeito no jogo | Arquivos / sistemas | Testes |
|---|---|---|---|---|---|
| Interface | Pausa manual pelo botão II no celular e por Esc/P no computador; painel de configurações | Permitir interromper a partida e ajustar a experiência sem sair do jogo | A pausa abre opções e não substitui as pausas de level-up/resultados | PauseMenu, HUD, controles | Godot e Playwright nos 3 perfis |
| Interface | Configurações persistentes: destro/canhoto, joystick fixo/flutuante, tamanho e altura, som, tremor e números de dano | Adaptar a operação ao jogador | Layout canhoto espelhado; preferências salvas separadas do progresso | GameSettings, FloatingJoystick, PauseMenu | Testes de arquivo, valores inválidos, canhoto, joystick e pausa |
| Jogabilidade | Três evoluções de armas: **Raio em cadeia**, **Coroa de cinzas** e **Vendaval de lâminas** | Criar transformações perceptíveis de build | Cartas douradas de evolução quando os requisitos são cumpridos; uma evolução por arma | WeaponCatalog, Arsenal e sistemas de armas | Suíte despertar e simulações de DPS |
| Jogabilidade | **Pacto do Eco**, melhoria de risco/recompensa | Dar ao jogador uma escolha ofensiva com custo defensivo | Por nível: +25% dano e +15% XP, mas +20% dano recebido; máximo 3 | Upgrades e progressão | Suíte despertar e simulações |
| Jogabilidade | Estados de combate: queimadura, lentidão, empurrão, escudo e vulnerabilidade | Fazer armas e inimigos interagirem | Estados alteram dano, velocidade, proteção e resposta ao impacto | EnemyManager e sistemas de armas | Suíte despertar |
| Jogabilidade | **Tecelão** (suporte) e **Semeador** (controle de área) | Criar ameaças com funções distintas | Tecelão protege inimigos próximos; Semeador cria poças de cinzas anunciadas | EnemyTypes, EnemyManager e GroundEffects | Suíte despertar e simulação prolongada |
| Jogabilidade | Elites **Veloz**, **Blindado** e **Gerador** | Inserir encontros especiais e recompensas | Elites são anunciados, têm modificadores e concedem orbe de 12 XP e cura de 15 | EventDirector, EnemyManager e RunStats | Suíte despertar e smoke test |
| Jogabilidade | Eventos **Fenda do Eco**, **Maré da horda** e **Calmaria** | Variar o ritmo das partidas e criar escolhas de risco | Fenda recompensa permanência por 6 s com escolha extra e cura; Maré acelera hordas e Calmaria reduz sua intensidade | EventDirector e sistemas de eventos | Suíte despertar; recompensa da Fenda ainda sem avaliação humana |
| Jogabilidade | Sentinela do Eco: atordoamento de 2 s e +50% de dano recebido após investida; novo ataque **Prisão de ecos** | Criar uma janela de contra-ataque e ampliar os padrões do chefe | O jogador precisa ler o anel e encontrar sua saída | BossController, EnemyManager e GroundEffects | Suíte despertar e simulações de chefe |
| Interface | Som procedural (12 efeitos), estouros no chão em abates, números de dano seletivos e tremor de câmera | Dar retorno sensorial sem poluir a tela | Opções de som, tremor e números podem ser desligadas | SoundBank e GameFeel | Testes de geração e reprodução; áudio não foi ouvido por uma pessoa |
| Jogabilidade | Raio arcano aplica pequeno empurrão; câmera em paisagem revela 11 m na vertical; resultados exibem elites, Fendas fechadas e armas evoluídas | Melhorar leitura e registro da partida | Feedback e estatísticas ampliados | AutoWeapon, CameraRig, ResultsScreen e RunStats | Testes Godot, smoke e navegador |

**Estado de design:** a personalização mobile já era aprovada. As novas mecânicas de gameplay (evoluções, Pacto do Eco, estados, novos inimigos, elites, eventos e mudanças do chefe) permanecem **PROPOSTO_NAO_APROVADO (experimental)** até decisão individual do proprietário. A integração e publicação não significam aprovação de design nem validação humana.

**Testes registrados na entrega:** 71 testes em 6 suítes, 4.613 verificações e 0 falhas; smoke test; simulação de 300 s no CI; simulações locais de 600 s e 720 s; Playwright QA (24 aprovados, 3 pulados) e produção (11 aprovados, 1 pulado), em desktop e perfis móveis emulados; testes da Wiki e montagem do site aprovados. O workflow pós-merge publicou a build e verificou que o site abriu.

**Limitações:** nenhum teste em celular físico ou com pessoas; FPS real em aparelho não medido; chefe venceu 3/3 simulações automáticas e pode estar fácil; Fenda do Eco não foi avaliada pelo piloto automático; som provisório não foi ouvido por pessoa; pausa não conferida em telas com entalhe. Custo médio por quadro subiu cerca de 10% a 20% e p99 cerca de 33% no servidor de testes, sem equivalência direta com FPS de celular. Detalhes: docs/versoes/0.4-alpha/RELATORIO.md.

---

## Manutenção pós-0.3-alpha + Documento Mestre de Sistemas

**Data:** 26/11/2026 · **Pull Request:** [#7](https://github.com/ederkm40/Cronicas-de-Eudora/pull/7) · **Merge:** `202965a3f1f0f9b18de0d63773da93e2a1ded475`. Esta etapa **não é uma nova versão de gameplay**: a versão oficial na ocasião continuou 0.3-alpha. Não houve mudança de equilíbrio, conteúdo, progressão ou economia.

| Categoria | Descrição | Motivo | Efeito no jogo | Arquivos | Testes |
|---|---|---|---|---|---|
| Infraestrutura | Separação definitiva entre build de produção (Web), sem ponte de QA, e build Web QA, usada somente nos testes automatizados | Impedir que ferramentas de teste sejam incluídas no jogo publicado | ?teste=1 não ativa mais a ponte; somente a build de produção é publicada | export_presets.cfg, scripts/main.gd, scripts/web_bridge.gd, tools/ci/, workflow | Verificação: produção 0 referências à ponte, QA 3; Playwright em produção |
| Correção | Validação de estrutura e tipos do arquivo de progresso | Evitar que saves danificados interrompam a leitura ou apaguem dados válidos | Estrutura inválida é preservada em cópia .corrompido e inicia progresso novo; campo inválido é corrigido individualmente; versão futura não é sobrescrita | scripts/meta_progress.gd | Suíte save_e_joystick; conferência ao contrário |
| Correção | Retomada correta do joystick após o level-up | Evitar que o jogador precise soltar e tocar novamente depois da pausa | Dedo mantido retoma o controle; dedo solto deixa o joystick neutro; toques durante a pausa não viram movimento ou esquiva | scripts/floating_joystick.gd | 5 testes Godot e Playwright nos 3 perfis emulados |
| Testes | Executor registra suíte inválida como falha, em vez de travar; cobertura ampliada | Tornar falhas de testes visíveis e confiáveis | Nenhuma mudança de gameplay | tests/run_tests.gd, tests/suites/save_e_joystick.gd | 51 testes, 4.482 verificações, 0 falhas |
| Documentação | Criação do Documento Mestre de Sistemas, com 38 áreas e 30 catálogos | Organizar sistemas, dependências e estados de design, implementação e validação | Não autoriza implementação nem altera a roadmap | docs/design/DOCUMENTO_MESTRE_SISTEMAS.md, docs/design/catalogos/ | 9 catálogos com conteúdo comprovado pelo código; 21 planejados sem entradas fictícias |
| Limpeza | Remoção de scripts/main.gd.orig | Retirar arquivo temporário versionado | Nenhum | scripts/main.gd.orig | Busca por temporários versionados |

**Validação registrada no PR #7:** smoke test e simulação de 300 s aprovados; Wiki (14 testes) e montagem do site (7 testes) aprovadas; Playwright na QA (21 aprovados, 3 pulados por desenho) e na produção (11 aprovados, 1 pulado por desenho), nos três perfis. Não houve teste em celular físico nem teste com pessoas. Detalhes: docs/versoes/manutencao-pos-0.3/RELATORIO.md.

---

## 0.3-alpha: grande expansão do combate (publicada)

**Data:** 26/11/2026 · **Pull Request:** [#5](https://github.com/ederkm40/Cronicas-de-Eudora/pull/5). Detalhes e números em docs/versoes/0.3-alpha/RELATORIO.md.

| Categoria | Descrição | Motivo | Efeito no jogo | Arquivos | Testes |
|---|---|---|---|---|---|
| Jogabilidade | Armas novas **Aura de brasas** (pulsos de dano em área) e **Lâmina orbital** (lâminas que giram e cortam), cada uma num espaço próprio, com 5 níveis | Variedade de combate (0.3) | Mais escolhas de build; o Raio arcano continua como arma inicial | scripts/weapon_catalog.gd, arsenal.gd, aura_weapon.gd, orbit_blades.gd | suíte armas_e_ofertas |
| Jogabilidade | Level-up oferece arma nova, evolução de arma ou melhoria; **trocar opções** (2 por partida) e **bloquear** (2 por partida) | Escolhas com mais controle | Cartões com o tipo da oferta e o que muda | scripts/level_up_offers.gd, level_up_panel.gd | suíte armas_e_ofertas |
| Jogabilidade | 4 inimigos novos: Espreitador (rápido), Couraçado (resistente), Lançador (atira com aviso), Volátil (explode com aviso) | Antecipação da 0.4 | Entram aos 45 s, 100 s, 150 s e 210 s | scripts/enemy_types.gd, enemy_manager.gd, enemy_projectiles.gd, ground_effects.gd | suíte inimigos_e_chefe |
| Jogabilidade | **Sentinela do Eco** aos 10 minutos: investida, erupção e rajada com aviso, fase 2 abaixo de 50% | Antecipação da 0.4 e do fim de partida da 0.6 | A partida só é vencida derrotando o chefe | scripts/boss_controller.gd, main.gd | suíte inimigos_e_chefe, navegador |
| Jogabilidade | **Esquiva** por duplo toque no joystick (ou Espaço): 4 m, invulnerável por 0,32 s, recarga de 1,4 s | Antecipação da 0.5 | Mais recursos de movimento sem botão novo | scripts/floating_joystick.gd, player.gd | suíte esquiva_e_encerramento, navegador |
| Interface | Tela de **resultados** (vitória ou derrota) com estatísticas reais e reinício limpo; barra do chefe, linha de armas e indicador de esquiva no HUD | Antecipação da 0.6 | Resumo de cada partida | scripts/results_screen.gd, run_stats.gd, hud.gd | suíte esquiva_e_encerramento |
| Jogabilidade | **Ecos** e 4 melhorias permanentes, salvos no navegador | Primeira progressão entre partidas | Bônus moderados a partir da partida seguinte | scripts/meta_progress.gd | suíte esquiva_e_encerramento |
| Jogabilidade | Equilíbrio: vida dos inimigos +35%/min (era 60%), leva +1 a cada 30 s (era 25 s), cada nível cura 12% da vida, Poder arcano vale para todas as armas | Simulações mostraram derrota antes dos 5 min sem cura | Partidas mais longas; o chefe é alcançável | scripts/enemy_manager.gd, main.gd, upgrades.gd | tests/balance_simulation.gd |
| Desempenho | Colisão dos projéteis do Raio pela grade espacial (antes, cada projétil comparava com todos os inimigos) | Mais projéteis e inimigos | Sem efeito visível | scripts/enemy_manager.gd | testes de efeito, simulação longa |
| Testes | 25 testes novos (41 no total) em 4 suítes; testes de navegador com controles reais; falha automática com erro de script no log | Cobrir os sistemas novos | — | tests/, tools/e2e/, tools/ci/rodar_godot.sh | CI |

---

## Infraestrutura: Wiki, prévias e memória (publicada)

**Data:** 26/11/2026 · **Versão do jogo na ocasião:** 0.2-alpha · **Pull Request:** ver docs/versoes/0.2-alpha-infra/RELATORIO.md.

| Categoria | Descrição | Motivo | Efeito no jogo | Arquivos | Testes |
|---|---|---|---|---|---|
| Infraestrutura | Publicação passa a usar o branch gh-pages: jogo oficial na raiz, Wiki em /wiki/, prévias em /previews/pr-N/ | Permitir testar cada Pull Request antes do merge sem substituir a versão oficial | nenhum | .github/workflows/publicar.yml, tools/site/ | tools/site/test_montar_site.py |
| Infraestrutura | Prévia jogável e Wiki candidata para cada Pull Request do próprio repositório, atualizada a cada envio e removida ao fechar | O proprietário precisa testar antes de aprovar | nenhum | .github/workflows/publicar.yml | verificação de URL no workflow |
| Documentação | Wiki pública com 12 categorias e painel de desenvolvimento, gerada por script próprio em Python | Documentação acessível, editável artigo por artigo | nenhum | wiki-src/, tools/wiki/ | tools/wiki/test_wiki.py |
| Documentação | AGENTS.md, docs/IA/, relatórios por versão, decisões técnicas e este changelog | Permitir que qualquer IA continue o projeto | nenhum | AGENTS.md, docs/ | — |

## 0.2-alpha: Ecos da Evolução

**Data:** 26/11/2026 · **Pull Request:** [#1](https://github.com/ederkm40/Cronicas-de-Eudora/pull/1) · **Merge:** e516f21.

| Categoria | Descrição | Motivo | Efeito no jogo | Arquivos | Testes |
|---|---|---|---|---|---|
| Jogabilidade | Inimigos derrotados deixam orbes de experiência (1 XP), puxados a 3 m e coletados a 0,6 m | Primeiro sistema de progressão na partida | O jogador precisa circular para coletar | scripts/xp_orbs.gd, scripts/main.gd | test_inimigo_derrotado_gera_orbe, test_coleta_de_orbes_por_proximidade |
| Jogabilidade | Níveis com XP crescente: round(4 × nível^1,35) | Ritmo de evolução | 4, 10, 18, 26, 35… XP por nível | scripts/progression.gd | test_acumulo_de_experiencia, test_subida_de_nivel, test_varios_niveis_de_uma_vez |
| Jogabilidade | Level-up pausa tudo e oferece 3 melhorias diferentes | Escolhas de build | Partida congela durante a escolha | scripts/main.gd, scripts/level_up_panel.gd | test_tres_opcoes_distintas, test_pausa_e_retomada |
| Jogabilidade | 6 melhorias com limites: Poder arcano, Cadência, Núcleo vital, Passos ligeiros, Projétil adicional, Campo de ruptura | Primeiro conjunto de melhorias | Ver tabela em docs/TECNICO.md | scripts/upgrades.gd, scripts/auto_weapon.gd, scripts/player.gd | 6 testes de efeito + test_acumulo_e_limites_das_melhorias |
| Interface | Barra de XP e Nv. no HUD; tela de derrota mostra o nível | Mostrar a progressão | — | scripts/hud.gd | test_acumulo_de_experiencia |
| Correção | Seta dos cartões trocada por » | A fonte da versão web não tinha o símbolo (aparecia um quadradinho) | — | scripts/upgrades.gd | verificação visual no navegador |
| Testes | run_tests.gd (16 testes), smoke test ampliado, long_simulation.gd | Garantir que a progressão funciona de ponta a ponta | — | tests/ | — |
| Infraestrutura | Workflow testa Pull Requests sem publicar | Não publicar versão em revisão | — | .github/workflows/web.yml | — |

## 0.1-alpha: Projeto base

**Data:** 26/11/2026 · **Commit:** 0dd647f (enviado direto ao main, antes da regra de Pull Requests).

| Categoria | Descrição | Motivo | Efeito no jogo | Arquivos | Testes |
|---|---|---|---|---|---|
| Jogabilidade | Personagem com 100 de vida e 5 m/s, joystick flutuante, WASD e setas | Controles para celular com uma mão | — | scripts/player.gd, scripts/floating_joystick.gd | smoke_test.gd |
| Jogabilidade | Câmera isométrica ortográfica fixa, em retrato | Visão escolhida para o projeto | — | scripts/camera_rig.gd | smoke_test.gd |
| Jogabilidade | Arma automática (10 de dano, 0,45 s, 11 m) e hordas de até 300 inimigos | Núcleo do gênero | — | scripts/auto_weapon.gd, scripts/enemy_manager.gd | smoke_test.gd |
| Interface | HUD com tempo, abates, vida, FPS e inimigos; tela de derrota e reinício | — | — | scripts/hud.gd | smoke_test.gd |
| Desempenho | Inimigos e projéteis em arrays + MultiMesh, separação com grade espacial ordenada | 300 inimigos no navegador do celular | — | scripts/enemy_manager.gd | medição local |
| Infraestrutura | Exportação Web sem threads publicada no GitHub Pages a cada envio ao main | Testar no celular pelo navegador | — | .github/workflows/web.yml | — |
