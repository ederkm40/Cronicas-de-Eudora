# Crônicas de Eudora

Jogo de hordas isométrico para celular: partidas curtas no estilo *survivors*, com a progressão de personagem e loot de um ARPG. Feito em **Godot 4.7**, quase todo construído por IA.

| | |
|---|---|
| **Jogar (versão oficial)** | https://ederkm40.github.io/Cronicas-de-Eudora/ |
| **Wiki** | https://ederkm40.github.io/Cronicas-de-Eudora/wiki/ |
| **Prévias em teste** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/ |

A versão oficial é a do branch `main` e se atualiza sozinha alguns minutos depois de cada merge. Cada Pull Request ganha uma **prévia jogável** em `/previews/pr-<número>/`, com a própria Wiki, para ser testada antes da aprovação. O endereço aparece num comentário automático no PR.

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

| Para | Leia |
|---|---|
| Jogadores | a [Wiki](https://ederkm40.github.io/Cronicas-de-Eudora/wiki/) (fontes em `wiki-src/`) |
| Qualquer IA que for trabalhar no projeto | [AGENTS.md](AGENTS.md), depois [docs/IA/](docs/IA/) |
| Claude Code | [CLAUDE.md](CLAUDE.md) |
| Como o jogo funciona | [docs/TECNICO.md](docs/TECNICO.md) |
| O que vem a seguir | [docs/ROADMAP.md](docs/ROADMAP.md) |
| Histórico | [docs/CHANGELOG.md](docs/CHANGELOG.md), [docs/versoes/](docs/versoes/) (relatórios), [docs/decisoes/](docs/decisoes/) |

## Como o projeto é feito

- **Claude Code** desenvolve o jogo, os testes e a infraestrutura.
- **ChatGPT** acompanha as entregas e mantém a Wiki e o changelog.
- O **proprietário** testa as prévias e aprova os Pull Requests.
- Tudo usa só ferramentas gratuitas: GitHub Free, GitHub Pages, GitHub Actions e Godot.

## Testes

Rodam sem tela e também no GitHub Actions, antes de cada publicação:

```bash
godot --headless --path . --import
godot --headless --path . --fixed-fps 60 --script res://tests/run_tests.gd        # testes específicos
godot --headless --path . --fixed-fps 60 --script res://tests/smoke_test.gd       # partida de ponta a ponta
godot --headless --path . --fixed-fps 60 --script res://tests/long_simulation.gd -- --segundos=600
python3 tools/wiki/test_wiki.py && python3 tools/site/test_montar_site.py        # Wiki e site
```
