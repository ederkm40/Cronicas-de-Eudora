---
titulo: Funcionalidades
resumo: Funcionalidades presentes na versão oficial 0.4-alpha e conteúdo ainda planejado.
ordem: 30
---
## No jogo oficial

| Funcionalidade | Desde | Estado | Artigo |
|---|---|---|---|
| Joystick flutuante | 0.1-alpha | {PUBLICADO} | [[controles/joystick-flutuante]] |
| Teclado (WASD e setas) | 0.1-alpha | {PUBLICADO} | [[controles/teclado]] |
| Câmera isométrica em retrato | 0.1-alpha | {PUBLICADO} | [[mapas/chao-de-grade]] |
| Raio arcano automático | 0.1-alpha | {PUBLICADO} | [[armas/arma-automatica]] |
| Hordas de até 300 inimigos | 0.1-alpha | {PUBLICADO} | [[combate/hordas]] |
| Dano por contato, derrota e reinício | 0.1-alpha | {PUBLICADO} | [[combate/dano-e-derrota]] |
| Contador de FPS e de inimigos | 0.1-alpha | {PUBLICADO} | [[desenvolvimento/desempenho]] |
| Orbes de experiência com ímã | 0.2-alpha | {PUBLICADO} | [[progressao/orbes-de-experiencia]] |
| Orbes, barra de XP e curva de experiência | 0.2-alpha | {PUBLICADO} | [[progressao/experiencia]] |
| Level-up com pausa e melhorias | 0.2-alpha | {PUBLICADO} | [[progressao/level-up]] |
| Seis melhorias passivas | 0.2-alpha | {PUBLICADO} | [[melhorias]] |
| Aura de brasas e Lâmina orbital, até 5 níveis | 0.3-alpha | {PUBLICADO} | [[armas]] |
| Ofertas de arma nova, evolução e melhoria | 0.3-alpha | {PUBLICADO} | [[combate/arsenal]] |
| Duas trocas e dois bloqueios por partida | 0.3-alpha | {PUBLICADO} | [[progressao/level-up]] |
| Espreitador, Couraçado, Lançador e Volátil | 0.3-alpha | {PUBLICADO} | [[inimigos]] |
| Sentinela do Eco aos 10 min | 0.3-alpha | {PUBLICADO} | [[chefes/sentinela-do-eco]] |
| Esquiva por duplo toque e Espaço | 0.3-alpha | {PUBLICADO} | [[controles/esquiva]] |
| Vitória, derrota, resultados e reinício limpo | 0.3-alpha | {PUBLICADO} | [[progressao/resultados]] |
| Ecos e quatro melhorias permanentes | 0.3-alpha | {PUBLICADO} | [[progressao/melhorias-permanentes]] |
| Estatísticas reais por arma e origem do dano | 0.3-alpha | {PUBLICADO} | [[progressao/resultados]] |
| Pausa manual e configurações mobile persistentes | 0.4-alpha | {PUBLICADO} | [[controles/pausa-e-configuracoes]] |
| Layout espelhado para canhotos; joystick fixo/flutuante, três tamanhos e três alturas | 0.4-alpha | {PUBLICADO} | [[controles/pausa-e-configuracoes]] |
| Três evoluções de armas: Raio em cadeia, Coroa de cinzas e Vendaval de lâminas | 0.4-alpha | {PUBLICADO} | [[armas]] |
| Pacto do Eco, melhoria de risco/recompensa | 0.4-alpha | {PUBLICADO} | [[progressao]] |
| Tecelão, Semeador e elites Veloz, Blindado e Gerador | 0.4-alpha | {PUBLICADO} | [[inimigos]] |
| Fenda do Eco, Maré e Calmaria | 0.4-alpha | {PUBLICADO} | [[desenvolvimento/eventos-da-partida]] |
| Atordoamento após investida e ataque Prisão de ecos | 0.4-alpha | {PUBLICADO} | [[chefes]] |
| Som procedural, estouros nos abates, números de dano seletivos e tremor de câmera | 0.4-alpha | {PUBLICADO} | [[desenvolvimento/eventos-da-partida]] |
| Estatísticas de elites, Fendas fechadas e armas evoluídas nos resultados | 0.4-alpha | {PUBLICADO} | [[progressao/resultados]] |

As mecânicas novas de gameplay da 0.4 estão publicadas como **experimentos** e permanecem PROPOSTO_NAO_APROVADO no eixo de design até decisão do proprietário. A personalização mobile já estava aprovada.

## Infraestrutura

| Funcionalidade | Estado |
|---|---|
| Publicação automática no GitHub Pages | {PUBLICADO} |
| Testes automáticos e verificação estática no CI | {PUBLICADO} |
| Wiki pública gerada a partir de wiki-src/ | {PUBLICADO} |
| Prévia de jogo e Wiki por Pull Request | {PUBLICADO} |
| Testes Playwright em computador e dois perfis de Pixel 7 emulado | {PUBLICADO} |
| Documentação permanente para desenvolvimento assistido por IA | {PUBLICADO} |
| Build de produção sem ponte de QA; build Web QA restrita ao CI | {PUBLICADO} |
| Validação de estrutura e tipos do save, com recuperação de dados inválidos | {PUBLICADO} |
| Retomada do joystick após pausa do level-up | {PUBLICADO}, testado em Godot e Chromium emulado; falta teste físico |
| Documento Mestre de Sistemas (38 áreas e 30 catálogos) | {PUBLICADO} como documentação; propostas não aprovam implementação |

## Planejado ou pendente

| Funcionalidade | Situação |
|---|---|
| Teste com 5 a 10 pessoas em celulares físicos e validação da vontade de jogar novamente | {PLANEJADO}; adiado pelo proprietário até uma fase posterior de evolução |
| Medir FPS em aparelhos reais com a horda cheia | {PLANEJADO} |
| Aprovar ou rejeitar individualmente as mecânicas experimentais da 0.4 | {PLANEJADO}; decisão do proprietário |
| Loot que muda regras (itens com efeitos especiais) | {PLANEJADO}, fase 2 |
| Cidade simples | {PLANEJADO}, fase 2 |
| Uma classe completa | {PLANEJADO}, fase 2 |
| Uma fase com arte e som finais | {PLANEJADO}, fase 2 |
| Exportação Android (APK) | {PLANEJADO}, fase 2 |

Os sistemas planejados não devem ser confundidos com funcionalidades presentes na versão oficial.
