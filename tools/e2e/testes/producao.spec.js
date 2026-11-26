// Testes da build de PRODUÇÃO (preset "Web"), a mesma que vai para o site oficial e para
// as prévias. Conferem que a ponte de testes não existe, nem com ?teste=1, e que comandos
// de teste escritos na página não mudam nada.
const { test, expect } = require("@playwright/test");

async function abrir(page, endereco) {
  const resposta = await page.goto(endereco, { waitUntil: "load" });
  expect(resposta?.status()).toBe(200);
  await page.waitForFunction(() => !document.getElementById("status"), null, { timeout: 90_000 });
  // A ponte da QA escreve o estado a cada 0,1 s: 2 s é bem mais que o suficiente para aparecer.
  await page.waitForTimeout(2_000);
}

for (const endereco of ["./", "./?teste=1"]) {
  test(`produção sem ponte de testes (${endereco})`, async ({ page }) => {
    const erros = [];
    page.on("pageerror", (erro) => erros.push(erro.message));
    await abrir(page, endereco);
    const objetos = await page.evaluate(() => ({
      estado: typeof window.__eudora,
      comandos: typeof window.__eudoraComandos,
    }));
    expect(objetos.estado, "window.__eudora não deveria existir na produção").toBe("undefined");
    expect(objetos.comandos, "window.__eudoraComandos não deveria existir na produção").toBe("undefined");

    // Comandos de teste escritos na página não são lidos: a lista continua igual.
    await page.evaluate(() => { window.__eudoraComandos = ["morrer", "xp:500", "chefe"]; });
    await page.waitForTimeout(1_500);
    const depois = await page.evaluate(() => ({
      comandos: window.__eudoraComandos.length,
      estado: typeof window.__eudora,
    }));
    expect(depois.comandos, "ninguém deveria consumir os comandos").toBe(3);
    expect(depois.estado).toBe("undefined");

    // E o jogo continua rodando normalmente (a imagem muda com o tempo).
    const canvas = page.locator("#canvas");
    const antes = await canvas.screenshot();
    await expect
      .poll(async () => !(await canvas.screenshot()).equals(antes), { timeout: 20_000 })
      .toBe(true);
    expect(erros).toEqual([]);
  });
}
