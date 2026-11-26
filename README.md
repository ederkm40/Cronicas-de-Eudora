# Crônicas de Eudora

Jogo de hordas isométrico para celular: partidas curtas no estilo *survivors*, com a progressão de personagem e loot de um ARPG. Feito em **Godot 4.7**, quase todo construído por IA.

| | |
|---|---|
| **Jogar (versão oficial)** | https://ederkm40.github.io/Cronicas-de-Eudora/ |
| **Wiki** | https://ederkm40.github.io/Cronicas-de-Eudora/wiki/ |
| **Prévias em teste** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/ |

A versão oficial é a do branch `main` e se atualiza sozinha alguns minutos depois de cada merge. Cada Pull Request ganha uma **prévia jogável** em `/previews/pr-<número>/`, com a própria Wiki, para ser testada antes da aprovação. O endereço aparece num comentário automático no PR.

## Estado atual

A versão oficial é a **0.3-alpha "Grande expansão do combate"**, integrada pelo PR #5. O que ela traz:

- **Controles:** joystick flutuante (toque em qualquer ponto e arraste); no PC, WASD ou setas. **Esquiva:** duplo toque no joystick (ou Espaço no PC).
- **Armas:** Raio arcano (inicial), **Aura de brasas** e **Lâmina orbital**, cada uma com espaço próprio e 5 níveis.
- **Level-up:** pausa e mostra até 3 ofertas (arma nova, evolução de arma ou melhoria), com **Trocar opções** e **Bloquear** (2 de cada por partida). No PC: 1, 2, 3 e R.
- **Inimigos:** Errante, Espreitador (rápido), Couraçado (resistente), Lançador (atira com aviso) e Volátil (explode com aviso), entrando aos poucos. Até 300 na tela.
- **Encontro final:** aos 10 minutos surge o **Sentinela do Eco**. Derrotá-lo vence a partida.
- **Resultados:** vitória ou derrota com estatísticas reais da partida e "Jogar de novo".
- **Progressão permanente:** Ecos ganhos em cada partida compram 4 melhorias permanentes, salvas no navegador.
- **Desempenho:** contador de FPS e de inimigos no rodapé.

Detalhes, números e testes: `docs/TECNICO.md` e `docs/versoes/0.3-alpha/RELATORIO.md`.

## Documento Mestre de Sistemas

A referência central de design (sistemas, conteúdos, dependências, estados de design, implementação e validação) fica em [`docs/design/DOCUMENTO_MESTRE_SISTEMAS.md`](docs/design/DOCUMENTO_MESTRE_SISTEMAS.md), com os catálogos em [`docs/design/catalogos/`](docs/design/catalogos/README.md). Ele **não autoriza** implementar nada: as entregas aprovadas estão em `docs/ROADMAP.md`.

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

Rodam no GitHub Actions, no job "Testar e exportar", antes de cada publicação. Os checks **Testar e exportar** e **Publicar** são obrigatórios para integrar no `main`.

- **GDScript:** `gdlint` em todo o código e `gdformat --check` nos arquivos alterados (GDScript Toolkit 4.5.0).
- **Jogo:** testes específicos, partida de ponta a ponta e simulação prolongada (Godot sem tela).
- **Wiki e site:** geração, links, busca (com Node.js) e montagem das prévias.
- **Navegador:** o jogo exportado é aberto no Chromium (Playwright 1.65.1) no computador, no Pixel 7 em pé e no Pixel 7 deitado. A emulação não substitui o teste num celular físico.

As ferramentas de teste só existem no CI. O jogo publicado não carrega nenhuma dependência externa.

```bash
godot --headless --path . --import
godot --headless --path . --fixed-fps 60 --script res://tests/run_tests.gd        # testes específicos
godot --headless --path . --fixed-fps 60 --script res://tests/smoke_test.gd       # partida de ponta a ponta
godot --headless --path . --fixed-fps 60 --script res://tests/long_simulation.gd -- --segundos=600
python3 tools/wiki/test_wiki.py && python3 tools/site/test_montar_site.py        # Wiki e site
gdlint scripts tests                                                              # GDScript
cd tools/e2e && npm ci && E2E_DIR=<exportação> xvfb-run -a npx playwright test     # navegador
```

Para relatar um erro ou dar uma opinião sobre o jogo, use os formulários em **Issues → New issue**.
