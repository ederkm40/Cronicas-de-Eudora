// Testes do jogo Web realmente exportado pelo Godot, aberto no Chromium.
// Cada teste roda nos 3 projetos da configuração: computador (1366x768),
// celular-retrato (Pixel 7, 412x915, toque) e celular-paisagem (915x412, toque).
//
// IMPORTANTE: a emulação de Pixel 7 é só tamanho de tela, toque e user agent num Chromium de
// computador. NÃO equivale a testar num celular físico (GPU, desempenho, navegador do aparelho).
const { test, expect } = require("@playwright/test");

const ARQUIVOS_ESSENCIAIS = ["index.html", "index.js", "index.wasm", "index.pck"];

/** Abre o jogo e acompanha erros de JavaScript, de console e de rede. */
async function abrirJogo(page) {
  const registro = { erros: [], console: [], respostas: new Map(), falhasDeRede: [] };
  page.on("pageerror", (erro) => registro.erros.push(`exceção: ${erro.message}`));
  page.on("console", (msg) => {
    registro.console.push(msg.text());
    if (msg.type() === "error") registro.erros.push(`console.error: ${msg.text()}`);
  });
  page.on("requestfailed", (req) => registro.falhasDeRede.push(`${req.url()} (${req.failure()?.errorText})`));
  page.on("response", (resp) => {
    // A página principal é pedida como "/", que o servidor responde com index.html.
    const nome = new URL(resp.url()).pathname.split("/").pop() || "index.html";
    registro.respostas.set(nome, resp.status());
  });

  const resposta = await page.goto("./", { waitUntil: "load" });
  expect(resposta?.status(), "a página do jogo deveria responder 200").toBe(200);
  return registro;
}

/**
 * Espera o motor Godot terminar de iniciar: a página exportada remove o elemento #status quando
 * engine.startGame() conclui. Em caso de falha, ela mostra a mensagem em #status-notice.
 */
async function esperarMotor(page) {
  await page.waitForFunction(() => {
    const status = document.getElementById("status");
    const aviso = document.getElementById("status-notice");
    return !status || (aviso && aviso.textContent.trim().length > 0);
  }, null, { timeout: 90_000 });
  // Lê tudo de uma vez: depois da inicialização o #status (e o aviso dentro dele) não existe mais.
  const estado = await page.evaluate(() => ({
    statusPresente: !!document.getElementById("status"),
    aviso: (document.getElementById("status-notice")?.textContent || "").trim(),
  }));
  expect(estado.statusPresente, `o Godot não iniciou: ${estado.aviso}`).toBe(false);
}

async function infoWebGL(page) {
  return page.evaluate(() => {
    const gl = document.createElement("canvas").getContext("webgl2");
    if (!gl) return { webgl2: false };
    const dbg = gl.getExtension("WEBGL_debug_renderer_info");
    return {
      webgl2: true,
      renderizador: dbg ? gl.getParameter(dbg.UNMASKED_RENDERER_WEBGL) : gl.getParameter(gl.RENDERER),
    };
  });
}

test("o jogo carrega, o motor inicia e a tela é desenhada", async ({ page }, testInfo) => {
  const registro = await abrirJogo(page);

  // WebGL 2 é exigido pelo renderizador Compatibility do Godot.
  const gl = await infoWebGL(page);
  const descricao = gl.webgl2 ? gl.renderizador : "indisponível";
  testInfo.annotations.push({ type: "WebGL", description: descricao });
  console.log(`[${testInfo.project.name}] WebGL 2: ${descricao}`);
  expect(gl.webgl2, "o navegador precisa de WebGL 2").toBe(true);

  await esperarMotor(page);

  // O motor escreve a própria versão no console ao iniciar.
  await expect
    .poll(() => registro.console.some((linha) => linha.includes("Godot Engine v4.7.2")), {
      message: "o Godot 4.7.2 deveria se anunciar no console",
    })
    .toBe(true);

  // Arquivos essenciais carregados com sucesso.
  for (const nome of ARQUIVOS_ESSENCIAIS) {
    expect(registro.respostas.get(nome), `${nome} deveria carregar com status 200`).toBe(200);
  }
  expect(registro.falhasDeRede, "nenhuma requisição deveria falhar").toEqual([]);

  // O canvas existe, está visível e cabe na tela.
  const canvas = page.locator("#canvas");
  await expect(canvas).toBeVisible();
  const caixa = await canvas.boundingBox();
  const tela = page.viewportSize();
  expect(caixa, "o canvas deveria ter posição e tamanho").not.toBeNull();
  expect(caixa.width).toBeGreaterThan(0);
  expect(caixa.height).toBeGreaterThan(0);
  expect(caixa.x).toBeGreaterThanOrEqual(0);
  expect(caixa.y).toBeGreaterThanOrEqual(0);
  expect(caixa.x + caixa.width).toBeLessThanOrEqual(tela.width + 1);
  expect(caixa.y + caixa.height).toBeLessThanOrEqual(tela.height + 1);
  // A exportação usa canvasResizePolicy 2 (adaptativo): o canvas ocupa a janela inteira.
  expect(Math.abs(caixa.width - tela.width), "o canvas deveria ocupar a largura da tela").toBeLessThanOrEqual(2);
  expect(Math.abs(caixa.height - tela.height), "o canvas deveria ocupar a altura da tela").toBeLessThanOrEqual(2);
  const resolucao = await canvas.evaluate((c) => ({ w: c.width, h: c.height }));
  expect(resolucao.w, "a resolução interna do canvas deveria ser válida").toBeGreaterThan(0);
  expect(resolucao.h).toBeGreaterThan(0);

  // O jogo está rodando: a imagem do canvas muda com o tempo (relógio da partida, inimigos, disparos).
  const primeiraImagem = await canvas.screenshot();
  await expect
    .poll(async () => !(await canvas.screenshot()).equals(primeiraImagem), {
      message: "a imagem do jogo deveria mudar enquanto a partida roda",
      timeout: 20_000,
    })
    .toBe(true);

  expect(registro.erros, "não deveria haver erros de JavaScript").toEqual([]);
});

test("toque está habilitado nos perfis de celular", async ({ page }, testInfo) => {
  test.skip(testInfo.project.name === "computador", "verificação só para os perfis de celular");
  await abrirJogo(page);
  await esperarMotor(page);
  const toque = await page.evaluate(() => ({ pontos: navigator.maxTouchPoints, evento: "ontouchstart" in window }));
  expect(toque.pontos, "o contexto de celular deveria ter toque").toBeGreaterThan(0);
  expect(toque.evento).toBe(true);
  const tela = page.viewportSize();
  if (testInfo.project.name === "celular-retrato") {
    expect(tela.height, "retrato: altura maior que largura").toBeGreaterThan(tela.width);
  } else {
    expect(tela.width, "paisagem: largura maior que altura").toBeGreaterThan(tela.height);
  }
});
