# Crônicas de Eudora

Jogo de hordas isométrico para celular: partidas curtas no estilo *survivors*, com a progressão de personagem e loot de um ARPG. Feito em **Godot 4.7**, quase todo construído por IA.

**Jogar no navegador (celular ou PC):** https://ederkm40.github.io/Cronicas-de-Eudora/

O link mostra sempre a versão do branch `main`. Ele é atualizado sozinho alguns minutos depois de cada merge.

## Estado atual: 0.2-alpha "Ecos da Evolução"

O que já dá para jogar:

- **Controles:** joystick flutuante (toque em qualquer ponto da tela e arraste). No PC, WASD ou as setas.
- **Câmera:** isométrica ortográfica fixa, tela em retrato (720 x 1280).
- **Combate:** arma automática que atira no inimigo mais próximo.
- **Hordas:** crescem com o tempo, até 300 inimigos, cada vez mais resistentes.
- **Experiência:** cada inimigo derrotado deixa um orbe azul-claro. Chegando perto, ele voa até o personagem e é coletado. A barra azul abaixo da vida mostra quanto falta para o próximo nível (Nv.).
- **Level-up:** ao completar a barra, a partida pausa por completo e aparecem 3 melhorias diferentes. Toque em uma (no PC, teclas 1, 2 ou 3) e a partida continua. Dá para subir vários níveis na mesma partida.
- **Fim de partida:** tela de derrota com tempo, nível e abates, e o botão "Jogar de novo", que começa tudo do zero.
- **Desempenho:** contador de FPS e de inimigos no rodapé.

### As 6 melhorias

| Melhoria | Efeito por nível | Limite |
| --- | --- | --- |
| Poder arcano | +20% de dano | 10 níveis (+200%) |
| Cadência | +15% de velocidade de disparo | 8 níveis (+120%) |
| Núcleo vital | +25% de vida máxima e recupera 25 de vida | 8 níveis (+200%) |
| Passos ligeiros | +15% de velocidade de movimento | 5 níveis (+75%) |
| Projétil adicional | +1 projétil por disparo, em leque | 4 níveis (5 por disparo) |
| Campo de ruptura | +20% de alcance da arma | 5 níveis (+100%) |

Os efeitos se somam sobre o valor base (dois níveis de Poder arcano = +40%, não +44%). Uma melhoria que chegou ao limite para de aparecer nos sorteios.

A arte ainda é provisória (cápsulas e cristais): o objetivo agora é testar se o ciclo de jogo é divertido no celular.

## Documentação

- [Documentação técnica](docs/TECNICO.md): como o jogo funciona por dentro, números de ajuste e testes.
- [Roadmap](docs/ROADMAP.md): o que já foi feito e as próximas etapas.
- [CLAUDE.md](CLAUDE.md): regras para a IA que trabalha no projeto.

## Testes

Todos rodam sem tela e também no GitHub Actions, antes de cada exportação:

```bash
godot --headless --path . --import
godot --headless --path . --fixed-fps 60 --script res://tests/run_tests.gd        # testes específicos
godot --headless --path . --fixed-fps 60 --script res://tests/smoke_test.gd       # partida de ponta a ponta
godot --headless --path . --fixed-fps 60 --script res://tests/long_simulation.gd -- --segundos=600
godot --headless --path . --export-release "Web" build/web/index.html
```
