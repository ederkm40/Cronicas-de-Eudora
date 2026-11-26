# Entrega para o ChatGPT

*Pacote de fatos técnicos da última entrega do Claude Code. Use para atualizar a Wiki (`wiki-src/`), revisar o `docs/CHANGELOG.md` e o relatório. Não é um artigo: são dados. Números completos em `docs/TECNICO.md` e `docs/versoes/0.3-alpha/RELATORIO.md`.*

## Identificação

| | |
|---|---|
| **Etapa** | 0.3-alpha: grande expansão do combate |
| **Branch** | `feat/grande-expansao-combate-03` (a partir do `main` `70cf85f`) |
| **Pull Request** | https://github.com/ederkm40/Cronicas-de-Eudora/pull/5 |
| **Prévia do jogo** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-5/ |
| **Prévia da Wiki** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-5/wiki/ |

## Contexto

O PR #4 (ferramentas de QA) foi integrado em `70cf85f`. Na Wiki, ele pode passar a `{PUBLICADO}` e ganhar a linha no changelog (ainda não existe).

## Conteúdo novo (estado: `{TESTADO}` até o merge do PR #5)

**Armas** (cada uma num espaço próprio, 5 níveis; o Raio arcano continua como inicial):
- *Aura de brasas*: círculo de brasas que dá dano em todos dentro dele a cada pulso. Nível 1: 6 de dano, 2,2 m, pulso 0,6 s. Nível 5: 14, 3,2 m, 0,45 s.
- *Lâmina orbital*: lâminas que giram e cortam. Nível 1: 1 lâmina, 14 de dano, 1,9 m. Nível 5: 4 lâminas, 26, 2,5 m. Cada inimigo só é cortado de novo depois de 0,35 s.
- O Raio arcano mira o chefe quando ele está ao alcance.

**Level-up:** cartões de "NOVA ARMA", "ARMA · Nv. n » n+1" (com o que muda) e "MELHORIA · n/limite". Botão **Trocar opções** (2 por partida; tecla R) e **Bloquear** em cada cartão (2 por partida; a opção some da partida). Poder arcano agora vale para todas as armas; Cadência acelera também a Aura; Campo de ruptura dá +10% de área à Aura. Cada nível ganho cura 12% da vida.

**Inimigos** (todos com aparência e comportamento próprios):
- *Espreitador* (a partir de 45 s): rápido, frágil, mira à frente do jogador.
- *Couraçado* (100 s): cubo cinza-azulado, 5× vida, ignora 35% do dano, lento.
- *Lançador* (150 s): prisma roxo; fica a 6–8,5 m, para e brilha antes de atirar (8 de dano); só atira de dentro da tela.
- *Volátil* (210 s): esfera laranja; perto do jogador, para, pisca e mostra um círculo; explode 0,85 s depois (26 de dano, 2,4 m). Pode ser eliminado antes.
- O comum se chama *Errante* no código.

**Chefe — Sentinela do Eco:** aparece aos 10:00 (aviso aos 9:50) na borda de cima da tela, com coroa giratória e barra de vida (3.800). Ataques com aviso: *investida* (faixa vermelha no chão), *erupção* (círculos no chão onde o jogador está e vai estar) e *rajada* (anel de 14 projéteis; o chefe brilha lilás antes). Abaixo de 50%, fase de fúria: avisos mais curtos, mais erupções, rajada dupla e reforços. Durante o encontro, as hordas diminuem e não nascem Lançadores novos. **A vitória é derrotar o chefe**: a partida não termina sozinha aos 10 minutos.

**Esquiva:** duplo toque no joystick (sem botão). Toque + toque arrastando = esquiva para onde arrastou; dois toques curtos = para onde o personagem está indo. No computador, Espaço. 4 m, invulnerável por 0,32 s, recarga de 1,4 s, indicador "Esquiva pronta" no rodapé.

**Fim de partida:** tela de Vitória ou "Você caiu!" com tempo, nível, abates, dano causado e recebido, esquivas, chefes derrotados, tempo contra o chefe, cada arma (nível, dano, abates) e as melhorias. "Jogar de novo" começa do zero.

**Progressão permanente:** *Ecos* (1 a cada 20 s, 1 a cada 15 abates, 40 pelo chefe), salvos no navegador. Loja na tela de resultados: Vigor ancestral (+8% de vida), Fúria latente (+5% de dano), Atração do eco (+20% de coleta), Renovação (+1 troca). Valem a partir da próxima partida. Se o jogador limpar os dados do site, o progresso some.

## Pendente (estado `{PLANEJADO}` ou fora da Wiki)

- Destro/canhoto e ajuste do joystick.
- Equilíbrio com pessoas; teste em celular físico.
- Som e arte final.

## Testes realizados (resumo)

41 testes do Godot em 4 suítes; smoke; simulação de 5 min; Playwright com controles reais em 3 perfis (18 aprovados, 3 pulados de propósito); simulações de balanceamento (fora do CI). **Nenhum teste em celular físico.**

## Para a Wiki e o changelog

- Revisar a entrada "0.3-alpha" do `docs/CHANGELOG.md` (escrita pelo Claude Code a pedido do proprietário).
- Páginas de armas, inimigos, chefe, controles (esquiva) e progressão: criar ou atualizar com os dados acima.
- Painel de desenvolvimento: suítes novas de testes, testes de jogabilidade no navegador, simulação de balanceamento.
- Roadmap: 0.4 implementada na 0.3; 0.5 e 0.6 em parte (ver `docs/ROADMAP.md`). Não marcar 0.5 e 0.6 como concluídas.
