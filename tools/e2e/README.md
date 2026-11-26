# Testes de navegador (Playwright)

Testes da **versão Web realmente exportada** pelo Godot, abertos no Chromium. Rodam no GitHub Actions, dentro do job "Testar e exportar". Não fazem parte do jogo: nada desta pasta vai para o site publicado.

## O que é testado

`testes/jogo.spec.js`, em 3 perfis (`playwright.config.js`):

| Perfil | Tela | Toque |
|---|---|---|
| `computador` | 1366 × 768 | não |
| `celular-retrato` | Pixel 7, 412 × 915 | sim |
| `celular-paisagem` | Pixel 7, 915 × 412 | sim |

- O motor inicia: a página do Godot remove o `#status` ao terminar o `engine.startGame()`. Se der erro, o teste mostra a mensagem de `#status-notice`.
- O console mostra "Godot Engine v4.7.2".
- O navegador tem WebGL 2. O renderizador usado aparece no log como `WebGL 2: ...`.
- `index.html`, `index.js`, `index.wasm` e `index.pck` respondem 200, e nenhuma requisição falha.
- O `#canvas` está visível, dentro da tela, ocupando a janela, e com resolução interna válida.
- A imagem do canvas muda com o tempo, ou seja, a partida está rodando.
- Nenhum erro de JavaScript (exceções ou `console.error`).
- Nos perfis de celular, o toque está ativo e a orientação está certa.

`testes/jogabilidade.spec.js`, nos mesmos 3 perfis, joga com **controles de verdade** (eventos de toque do Chromium nos perfis de celular, mouse no computador):

- arrastar o joystick move o personagem; arrastar não esquiva;
- dois toques separados por 0,7 s não esquivam; o duplo toque rápido esquiva uma vez só;
- no computador, a tecla Espaço esquiva;
- level-up: tocar em "Trocar opções", em "Bloquear" e num cartão; confere contadores, pausa e a arma adquirida;
- encontro final: o chefe surge, a vitória abre os resultados e "Jogar de novo" (tocado) começa uma partida limpa;
- derrota: os resultados abrem e "Jogar de novo" recomeça.

Esses testes rodam na build **Web QA** (`E2E_MODO=qa`), a única que tem a ponte `scripts/web_bridge.gd`. Ela escreve o estado da partida em `window.__eudora` (posição, vida, esquivas, tela de level-up, resultados e a posição dos botões em frações da tela) e aceita comandos em `window.__eudoraComandos` só para **preparar** situações (dar XP, chamar o chefe, desligar as hordas). A build de produção (`E2E_MODO=producao`, a publicada) não tem a ponte: `testes/producao.spec.js` confere isso abrindo a página com e sem `?teste=1`. Os toques e gestos testados são reais.

Os eventos são enviados pelo protocolo do Chromium (`Input.dispatchTouchEvent` e `Input.dispatchMouseEvent`). Cada evento só volta depois que a página o processa, o que leva um quadro ou mais com renderização por software (~25 quadros por segundo). Por isso um toque curto envia "encostar" e "soltar" juntos (`ajudantes.js`).

> A emulação de Pixel 7 é só tamanho de tela, toque e user agent num Chromium de computador. **Não equivale a testar num celular de verdade** (GPU, desempenho, navegador do aparelho).

## Versões

- `@playwright/test` **1.65.1**, exata no `package.json` e no `package-lock.json`. Instalação só com `npm ci`.
- Só o Chromium, instalado com `npx playwright install --with-deps chromium`.
- Node.js 22 (`actions/setup-node`).

## Renderizador

No CI, o Playwright roda dentro do `xvfb-run` com `--use-angle=gl`, e o Chromium usa **Mesa/llvmpipe** (OpenGL 4.5). Sem a tela virtual ele cai no **SwiftShader**, que não mostra as atualizações de MultiMesh do Godot (ver `docs/IA/ESTADO_ATUAL.md`). Para forçar o SwiftShader: `E2E_RENDERIZADOR=swiftshader`.

## Evidências

Screenshot e trace **só quando um teste falha**. O workflow guarda `playwright-report/` e `test-results/` no artefato `playwright-falha` por 7 dias, e só em caso de falha.

## Rodar fora do CI (opcional)

Precisa de uma exportação Web em alguma pasta (por exemplo, a de `tools/ci/construir_parte.sh`):

```bash
cd tools/e2e
npm ci
npx playwright install chromium
E2E_DIR=/caminho/da/exportacao xvfb-run -a npx playwright test
```

Variáveis: `E2E_DIR` (pasta exportada), `E2E_PORTA` (padrão 8060), `E2E_RENDERIZADOR` (`mesa` ou `swiftshader`), `E2E_CHROME` (usar um Chrome já instalado). O servidor HTTP local é iniciado sozinho se ainda não estiver rodando.

## Atualizar o Playwright

1. Troque a versão exata no `package.json`.
2. Gere o lockfile num ambiente com acesso ao npm: `npm install --package-lock-only --ignore-scripts`.
3. Abra um PR e confira no log do job "Testar e exportar" os 5 testes aprovados e a linha `WebGL 2: ...`.
