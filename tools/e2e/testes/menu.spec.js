// Testes do menu inicial na build Web QA, com toques de verdade (ver ajudantes.js):
// navegação e "Voltar", o voltar do navegador (não pode sair do jogo), configurações que
// valem na partida, loja, JOGAR, "Encerrar partida" e "Voltar ao menu".
const { test, expect } = require("@playwright/test");
const { abrirMenu, estado, esperarEstado, comandos, centro, criarDedo } = require("./ajudantes");

async function tocarEm(page, dedo, escolher) {
  await page.waitForTimeout(300);
  await dedo.tocar(await centro(page, escolher(await estado(page))));
}

test("menu: telas, Voltar e o voltar do navegador", async ({ page }, testInfo) => {
  const erros = await abrirMenu(page);
  const dedo = await criarDedo(page, testInfo);
  const endereco = page.url();
  for (const tela of ["personagens", "missoes", "loja", "configuracoes"]) {
    await tocarEm(page, dedo, (e) => e.menu.botoes[tela]);
    await esperarEstado(page, (e) => e.menu.tela === tela, `deveria abrir ${tela}`);
    await tocarEm(page, dedo, (e) => e.menu.voltar);
    await esperarEstado(page, (e) => e.menu.tela === "inicio", `Voltar deveria sair de ${tela}`);
  }
  // O voltar do navegador (botão do celular) volta uma tela e NÃO sai da página do jogo.
  await tocarEm(page, dedo, (e) => e.menu.botoes.loja);
  await esperarEstado(page, (e) => e.menu.tela === "loja", "deveria abrir a loja");
  await page.goBack();
  await esperarEstado(page, (e) => e.tela === "menu" && e.menu.tela === "inicio", "o voltar deveria voltar à inicial");
  expect(page.url(), "continua na página do jogo").toBe(endereco);
  // De novo: o jogo repõe a entrada do histórico a cada voltar.
  await tocarEm(page, dedo, (e) => e.menu.botoes.missoes);
  await esperarEstado(page, (e) => e.menu.tela === "missoes", "deveria abrir as missões");
  await page.goBack();
  await esperarEstado(page, (e) => e.menu.tela === "inicio", "o segundo voltar também volta");
  expect(page.url()).toBe(endereco);
  expect(erros).toEqual([]);
});

test("menu: configuração e compra valem na partida; encerrar e voltar ao menu", async ({ page }, testInfo) => {
  const erros = await abrirMenu(page);
  const dedo = await criarDedo(page, testInfo);
  const menuInicial = (await estado(page)).menu.id;

  // Canhoto pelo menu.
  await tocarEm(page, dedo, (e) => e.menu.botoes.configuracoes);
  await esperarEstado(page, (e) => e.menu.tela === "configuracoes", "deveria abrir as configurações");
  await tocarEm(page, dedo, (e) => e.menu.mao);
  await esperarEstado(page, (e) => e.menu.canhoto, "deveria virar canhoto");
  await tocarEm(page, dedo, (e) => e.menu.voltar);

  // Compra na loja do menu.
  await comandos(page, "ecos:100");
  await tocarEm(page, dedo, (e) => e.menu.botoes.loja);
  await esperarEstado(page, (e) => e.menu.tela === "loja" && e.menu.ecos === 100, "loja com 100 Ecos");
  await tocarEm(page, dedo, (e) => e.menu.comprar_vigor);
  await esperarEstado(page, (e) => e.menu.vigor === 1 && e.menu.ecos === 85, "Vigor comprado");
  await tocarEm(page, dedo, (e) => e.menu.voltar);
  await esperarEstado(page, (e) => e.menu.tela === "inicio", "de volta à inicial");

  // JOGAR: a partida já abre canhota e com o Vigor.
  await tocarEm(page, dedo, (e) => e.menu.jogar);
  await esperarEstado(page, (e) => e.tela === "partida", "JOGAR deveria abrir a partida");
  await comandos(page, "hordas:0", "invulneravel:1", "limpar");
  const partida = await estado(page);
  expect(partida.pausa.canhoto, "a partida abre canhota").toBe(true);
  expect(partida.vida_max, "Vigor 1: 108 de vida").toBeCloseTo(108, 1);

  // Encerrar pela pausa pede dois toques e mostra os resultados.
  await tocarEm(page, dedo, (e) => e.pausa.botao);
  await esperarEstado(page, (e) => e.pausa.aberta, "a pausa deveria abrir");
  await tocarEm(page, dedo, (e) => e.pausa.encerrar);
  await page.waitForTimeout(500);
  expect((await estado(page)).fim, "um toque só não encerra").toBe(false);
  await tocarEm(page, dedo, (e) => e.pausa.encerrar);
  await esperarEstado(page, (e) => e.fim && e.resultados.aberto, "o segundo toque encerra");
  expect((await estado(page)).resultados.titulo).toBe("Partida encerrada");

  // Voltar ao menu.
  await tocarEm(page, dedo, (e) => e.resultados.menu);
  await esperarEstado(page, (e) => e.tela === "menu" && e.menu.id !== menuInicial, "deveria voltar ao menu");
  expect((await estado(page)).menu.tela).toBe("inicio");
  expect(erros).toEqual([]);
});

test("partida: o voltar do navegador abre a pausa e não sai do jogo", async ({ page }, testInfo) => {
  const erros = await abrirMenu(page);
  const dedo = await criarDedo(page, testInfo);
  const endereco = page.url();
  await tocarEm(page, dedo, (e) => e.menu.jogar);
  await esperarEstado(page, (e) => e.tela === "partida", "JOGAR deveria abrir a partida");
  await comandos(page, "hordas:0", "invulneravel:1");
  await page.goBack();
  await esperarEstado(page, (e) => e.pausa.aberta && e.pausado, "o voltar deveria pausar");
  expect(page.url()).toBe(endereco);
  await page.goBack();
  await esperarEstado(page, (e) => !e.pausa.aberta && !e.pausado, "o segundo voltar continua a partida");
  expect(erros).toEqual([]);
});
