// Testes de jogabilidade no jogo exportado, com controles de verdade: arrastar o joystick,
// duplo toque para esquivar, tocar nos cartões e botões do level-up e na tela de resultados.
// Rodam nos 3 perfis (computador com mouse; Pixel 7 em pé e deitado com toque).
// O jogo é aberto com ?teste=1, que liga a ponte scripts/web_bridge.gd: ela informa o estado
// da partida e a posição dos botões, e aceita comandos só para preparar situações
// (dar experiência, chamar o chefe). Os toques nos botões e os gestos são reais.
const { test, expect } = require("@playwright/test");
const { abrirPartida, estado, esperarEstado, comandos, centro, ponto, criarDedo } = require("./ajudantes");

test("joystick move o personagem e o duplo toque esquiva, sem esquiva acidental", async ({ page }, testInfo) => {
  const erros = await abrirPartida(page);
  await comandos(page, "hordas:0", "invulneravel:1", "limpar");
  const dedo = await criarDedo(page, testInfo);
  const base = await ponto(page, 0.5, 0.7);

  // Arrastar para a direita por ~1 s move o personagem.
  const antes = await estado(page);
  await dedo.encostar(base);
  for (let k = 1; k <= 10; k++) {
    await dedo.mover({ x: base.x + k * 8, y: base.y });
    await page.waitForTimeout(100);
  }
  await dedo.soltar();
  const depois = await estado(page);
  const andou = Math.hypot(depois.x - antes.x, depois.z - antes.z);
  expect(andou, `o joystick deveria mover o personagem (moveu ${andou.toFixed(2)} m)`).toBeGreaterThan(2);
  expect(depois.esquivas, "arrastar não deveria esquivar").toBe(0);

  // Toques separados por mais de 0,32 s não esquivam.
  await page.waitForTimeout(500);
  await dedo.tocar(base);
  await page.waitForTimeout(700);
  await dedo.tocar(base);
  await page.waitForTimeout(400);
  expect((await estado(page)).esquivas, "toques espaçados não deveriam esquivar").toBe(0);

  // Duplo toque rápido esquiva uma vez (o segundo toque sai logo depois do primeiro).
  await page.waitForTimeout(500);
  await dedo.tocar(base);
  await dedo.tocar(base);
  await esperarEstado(page, (e) => e.esquivas === 1, "o duplo toque deveria esquivar");
  await page.waitForTimeout(500);
  const final = await estado(page);
  expect(final.esquivas, "um gesto, uma esquiva").toBe(1);
  expect(final.gestos_esquiva).toBe(1);
  expect(erros, "sem erros de JavaScript").toEqual([]);
});

test("teclado: Espaço esquiva no computador", async ({ page }, testInfo) => {
  test.skip(testInfo.project.name !== "computador", "teclado só no perfil de computador");
  await abrirPartida(page);
  await comandos(page, "hordas:0", "invulneravel:1", "limpar");
  await page.locator("#canvas").click({ position: { x: 5, y: 5 } }); // foco no jogo
  await page.waitForTimeout(1600); // o clique acima pode ter contado como toque
  const antes = await estado(page);
  await page.keyboard.press("Space");
  await esperarEstado(page, (e) => e.esquivas === antes.esquivas + 1, "Espaço deveria esquivar");
});

test("level-up: trocar, bloquear e escolher tocando nos botões", async ({ page }, testInfo) => {
  const erros = await abrirPartida(page);
  await comandos(page, "hordas:0", "invulneravel:1", "limpar", "xp:4");
  await esperarEstado(page, (e) => e.painel.aberto && !e.painel.travado && e.pausado, "a escolha deveria abrir e pausar");
  const dedo = await criarDedo(page, testInfo);

  let e = await estado(page);
  const iniciais = e.painel.opcoes;
  expect(iniciais.length, "3 opções").toBe(3);
  expect(new Set(iniciais).size, "opções diferentes").toBe(3);

  // Trocar opções.
  await dedo.tocar(await centro(page, e.painel.trocar));
  await esperarEstado(page, (s) => s.painel.trocas === 1, "o botão de troca deveria ser contado");
  e = await estado(page);
  expect(e.painel.opcoes, "a troca deveria mudar as opções").not.toEqual(iniciais);

  // Bloquear a primeira.
  const bloqueada = e.painel.opcoes[0];
  await dedo.tocar(await centro(page, e.painel.bloquear[0]));
  await esperarEstado(page, (s) => s.painel.bloqueios === 1, "o bloqueio deveria ser contado");
  e = await estado(page);
  expect(e.painel.opcoes[0], "o cartão bloqueado deveria ser substituído").not.toBe(bloqueada);
  expect(e.painel.aberto && e.pausado, "trocar e bloquear não fecham a escolha").toBe(true);

  // Escolher a segunda opção.
  const escolhida = e.painel.opcoes[1];
  await dedo.tocar(await centro(page, e.painel.cartoes[1]));
  await esperarEstado(page, (s) => !s.painel.aberto && !s.pausado, "a escolha deveria fechar e despausar");
  e = await estado(page);
  expect(e.nivel).toBe(2);
  if (["aura_de_brasas", "lamina_orbital"].includes(escolhida)) {
    expect(e.armas[escolhida], `${escolhida} deveria ter sido adquirida`).toBe(1);
  }
  expect(erros).toEqual([]);
});

test("encontro final: vitória, resultados e reinício limpo", async ({ page }, testInfo) => {
  const erros = await abrirPartida(page);
  await comandos(page, "hordas:0", "invulneravel:1", "limpar", "chefe");
  await esperarEstado(page, (e) => e.chefe, "o chefe deveria surgir");
  const primeira = (await estado(page)).partida;
  await comandos(page, "chefe_vida:1");
  await esperarEstado(page, (e) => e.fim && e.vitoria, "derrotar o chefe deveria vencer", 40_000);
  await esperarEstado(page, (e) => e.resultados.aberto, "a tela de resultados deveria abrir");
  const dedo = await criarDedo(page, testInfo);
  await page.waitForTimeout(300);
  await dedo.tocar(await centro(page, (await estado(page)).resultados.reiniciar));
  await esperarEstado(page, (e) => e.partida !== primeira, "Jogar de novo deveria abrir uma partida nova");
  const nova = await estado(page);
  expect(nova.fim || nova.vitoria || nova.chefe || nova.resultados.aberto, "partida nova limpa").toBe(false);
  expect(Object.keys(nova.armas), "só a arma inicial").toEqual(["raio_arcano"]);
  expect(nova.tempo).toBeLessThan(5);
  expect(erros).toEqual([]);
});

test("derrota: resultados e reinício pelo toque", async ({ page }, testInfo) => {
  const erros = await abrirPartida(page);
  await comandos(page, "hordas:0", "limpar", "morrer");
  await esperarEstado(page, (e) => e.fim && !e.vitoria && e.resultados.aberto, "a derrota deveria abrir os resultados");
  const primeira = (await estado(page)).partida;
  const dedo = await criarDedo(page, testInfo);
  await page.waitForTimeout(300);
  await dedo.tocar(await centro(page, (await estado(page)).resultados.reiniciar));
  await esperarEstado(page, (e) => e.partida !== primeira && !e.fim && e.vivo, "a partida deveria recomeçar");
  expect(erros).toEqual([]);
});
