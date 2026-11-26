# Catálogo 12: Inimigos

Fonte: `scripts/enemy_types.gd` e `scripts/enemy_manager.gd`. Vida = multiplicador × 20, e a base cresce +35% por minuto de partida. Todos: **D** `APROVADO` (Errante 0.1; os outros 4 na 0.3, antecipados da 0.4) · **I** `IMPLEMENTADO` · **V** `TESTADO` (`tests/suites/inimigos_e_chefe.gd`; sem teste com pessoas).

| Tipo (número) | Nome | Arquétipo | Vida | Velocidade | Contato | Resistência | XP | Entrada | Peso máximo |
|---|---|---|---|---|---|---|---|---|---|
| 0 | Errante | comum | 1× | 2,2 m/s | 9/s | 0 | 1 | 0:00 | 1 |
| 1 | Espreitador | rápido | 0,45× | 4,3 m/s | 7/s | 0 | 1 | 0:45 | 0,45 |
| 2 | Couraçado | resistente | 5× | 1,35 m/s | 15/s | 35% | 4 | 1:40 | 0,22 |
| 3 | Lançador | atirador | 1,2× | 2,4 m/s | 6/s | 0 | 2 | 2:30 | 0,15 |
| 4 | Volátil | explosivo | 0,9× | 3,0 m/s | 6/s | 0 | 2 | 3:30 | 0,2 |

O peso de cada tipo cresce de 0 até o máximo depois da entrada (Espreitador em 200 s; os outros em 300 s).

### Comportamento e ataques

| Nome | Comportamento | Ataque e aviso | Referência visual |
|---|---|---|---|
| Errante | persegue | contato | cápsula vermelha |
| Espreitador | mira à frente do jogador; ×1,3 de velocidade a menos de 4 m | contato | cápsula pequena verde-amarela |
| Couraçado | persegue devagar; quase não é empurrado | contato | cubo cinza-azulado |
| Lançador | fica entre 6 e 8,5 m; anda de lado; só atira de dentro da tela | para e brilha 0,55 s; projétil de 8, a 6,5 m/s, a cada ~3,2 s | prisma roxo |
| Volátil | aproxima-se; a menos de 1,9 m acende o pavio e para | círculo no chão por 0,85 s; explosão de 26 no raio de 2,4 m; eliminado antes, não explode e deixa orbe | esfera laranja que pisca |

Regras gerais: até 300 inimigos (todos os tipos); dano de contato de até 5 inimigos ao mesmo tempo; inimigos longe demais reaparecem fora da tela; todos piscam em branco ao levar dano. No encontro final, novos Lançadores não nascem.

Dependências: combate, `GroundEffects` (avisos), `EnemyProjectiles` (Lançador), progressão (XP), `RunStats`.

## Em desenvolvimento na 0.4-alpha (PR #10, ainda não na `main`)

**D** `PROPOSTO_NAO_APROVADO` (experimental) · **I** `EM_DESENVOLVIMENTO` (PR #10) · **V** `TESTADO` (`tests/suites/despertar.gd`; sem teste com pessoas).

| Tipo (número) | Nome | Arquétipo | Vida | Velocidade | Contato | XP | Entrada | Peso máximo | Comportamento | Referência visual |
|---|---|---|---|---|---|---|---|---|---|---|
| 6 | Tecelão | suporte | 2× | 1,9 m/s | 5/s | 3 | 4:30 | 0,07 | fica entre 7 e 9,5 m; dá escudo de −40% a quem está a até 3,5 m dele (não a si nem ao chefe) | pilar ciano; protegidos ficam ciano |
| 7 | Semeador | controlador | 1,6× | 2,1 m/s | 6/s | 3 | 5:30 | 0,09 | persegue; a cada 4,5 s deixa uma poça de cinzas: raio 1,6 m, 0,6 s de aviso, 12/s por 5 s (até 20 poças) | monte verde-oliva |

### Elites

Um elite é um inimigo comum com um **modificador**: vida ×5, tamanho ×1,45, contato ×1,5, brilho dourado pulsante, empurrão ×0,3. Recompensa: orbe de 12 de XP, cura de 15 e aviso "X derrotado!". Contados em `RunStats.elites_killed`. O diretor de eventos cria um aos 2:00 e depois a cada 1:15.

| Modificador | Efeito | Contrajogo |
|---|---|---|
| Veloz | velocidade ×1,5 | esquiva; armas de área |
| Blindado | −30% de dano recebido (soma-se à resistência, até 75%) | foco de dano; o empurrão quase não o afeta |
| Gerador | chama 2 Errantes a cada 7 s | derrubar cedo |
