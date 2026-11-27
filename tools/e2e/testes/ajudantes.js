// Ajudantes dos testes de jogabilidade: abrir o jogo em modo de teste, ler o estado da partida
// e tocar na tela com gestos de verdade (toque pelo protocolo do Chromium nos perfis de celular,
// mouse no perfil de computador, como um jogador faria).
const { expect } = require("@playwright/test");

/** Abre a build de QA (que tem a ponte de testes) e espera o menu inicial aparecer. */
async function abrirMenu(page) {
  const erros = [];
  page.on("pageerror", (erro) => erros.push(`exceção: ${erro.message}`));
  page.on("console", (msg) => {
    if (msg.type() === "error") erros.push(`console.error: ${msg.text()}`);
  });
  const resposta = await page.goto("./", { waitUntil: "load" });
  expect(resposta?.status()).toBe(200);
  await page.waitForFunction(() => !document.getElementById("status"), null, { timeout: 90_000 });
  await page.waitForFunction(() => window.__eudora && window.__eudora.tela === "menu", null, { timeout: 30_000 });
  return erros;
}

/** Abre o jogo, toca em JOGAR no menu (como um jogador) e espera a partida começar. */
async function abrirPartida(page, testInfo) {
  const erros = await abrirMenu(page);
  const dedo = await criarDedo(page, testInfo);
  // Espera um pouco: o primeiro quadro do menu ainda pode estar montando o layout.
  await page.waitForTimeout(300);
  await dedo.tocar(await centro(page, (await estado(page)).menu.jogar));
  await page.waitForFunction(() => window.__eudora && window.__eudora.partida, null, { timeout: 30_000 });
  return erros;
}

/** Estado atual da partida, escrito pelo jogo a cada 0,1 s. */
async function estado(page) {
  return page.evaluate(() => window.__eudora);
}

/** Espera uma condição sobre o estado do jogo. */
async function esperarEstado(page, condicao, mensagem, timeout = 20_000) {
  await expect.poll(async () => condicao(await estado(page)), { message: mensagem, timeout }).toBe(true);
}

/** Manda comandos de preparação (ver scripts/web_bridge.gd). */
async function comandos(page, ...lista) {
  await page.evaluate((itens) => window.__eudoraComandos.push(...itens), lista);
  // Os comandos são lidos no próximo ciclo da ponte (0,1 s).
  await page.waitForTimeout(250);
}

/** Converte um retângulo em frações da tela (vindo do jogo) para o centro em pixels da página. */
async function centro(page, ret) {
  const caixa = await page.locator("#canvas").boundingBox();
  return {
    x: caixa.x + (ret[0] + ret[2] / 2) * caixa.width,
    y: caixa.y + (ret[1] + ret[3] / 2) * caixa.height,
  };
}

/** Ponto da tela em frações (0 a 1), em pixels da página. */
async function ponto(page, fx, fy) {
  const caixa = await page.locator("#canvas").boundingBox();
  return { x: caixa.x + fx * caixa.width, y: caixa.y + fy * caixa.height };
}

/**
 * Dedo virtual, com eventos de entrada reais do Chromium (protocolo DevTools): toque nos
 * perfis de celular, mouse no perfil de computador (o Godot converte o mouse em toque).
 *
 * Cada evento só "volta" depois que a página o processa. Com renderização por software
 * (llvmpipe, ~25 quadros por segundo) isso leva um quadro ou mais, então um toque feito com
 * espera entre encostar e soltar dura bem mais que um toque real. Por isso `tocar` envia
 * encostar e soltar juntos: o toque fica curto como o de um dedo de verdade.
 */
async function criarDedo(page, testInfo) {
  const toque = testInfo.project.name !== "computador";
  const cdp = await page.context().newCDPSession(page);
  const evento = (tipo, p) => {
    if (toque) {
      const nomes = { encostar: "touchStart", mover: "touchMove", soltar: "touchEnd" };
      const pontos = tipo === "soltar" ? [] : [{ x: p.x, y: p.y }];
      return cdp.send("Input.dispatchTouchEvent", { type: nomes[tipo], touchPoints: pontos });
    }
    const nomes = { encostar: "mousePressed", mover: "mouseMoved", soltar: "mouseReleased" };
    const botao = tipo === "mover" ? { buttons: 1 } : { button: "left", clickCount: 1 };
    return cdp.send("Input.dispatchMouseEvent", { type: nomes[tipo], x: p.x, y: p.y, ...botao });
  };
  let ultimo = { x: 0, y: 0 };
  return {
    async encostar(p) {
      ultimo = p;
      await evento("encostar", p);
    },
    async mover(p) {
      ultimo = p;
      await evento("mover", p);
    },
    async soltar() {
      await evento("soltar", ultimo);
    },
    /** Toque curto: encostar e soltar enviados juntos. */
    async tocar(p) {
      ultimo = p;
      await Promise.all([evento("encostar", p), evento("soltar", p)]);
    },
  };
}

module.exports = { abrirMenu, abrirPartida, estado, esperarEstado, comandos, centro, ponto, criarDedo };
