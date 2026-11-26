// Configuração dos testes de navegador (Playwright) da versão Web exportada pelo Godot.
// Só roda no CI (GitHub Actions). Nada daqui entra no jogo publicado.
//
// Variáveis de ambiente:
//   E2E_DIR           pasta com a exportação (index.html, .js, .pck, .wasm). Padrão: ../../build/parte
//   E2E_PORTA         porta do servidor local. Padrão: 8060
//   E2E_RENDERIZADOR  "mesa" (padrão: pede Mesa/llvmpipe via ANGLE-GL) ou "swiftshader".
//                     "mesa" só funciona com uma tela (no CI: xvfb-run); sem tela o Chromium
//                     cai no SwiftShader. O renderizador usado de verdade é impresso pelo teste.
//   E2E_CHROME        caminho de um Chrome já instalado (só para rodar fora do CI)
//   E2E_MODO          "qa" (padrão): build "Web QA", com a ponte de testes → jogo.spec e
//                     jogabilidade.spec. "producao": build "Web" publicada → jogo.spec e
//                     producao.spec (confere que a ponte de testes NÃO existe).
const path = require("path");
const { defineConfig, devices } = require("@playwright/test");

const porta = Number(process.env.E2E_PORTA || 8060);
const pasta = path.resolve(process.env.E2E_DIR || path.join(__dirname, "..", "..", "build", "parte"));
const renderizador = process.env.E2E_RENDERIZADOR || "mesa";
const modo = process.env.E2E_MODO || "qa";
const arquivos = modo === "producao"
  ? ["jogo.spec.js", "producao.spec.js"]
  : ["jogo.spec.js", "jogabilidade.spec.js"];

// SwiftShader (o padrão do Chromium sem placa de vídeo) não mostra atualizações de MultiMesh
// do Godot (ver docs/IA/ESTADO_ATUAL.md). Mesa/llvmpipe pelo ANGLE-GL renderiza corretamente.
const argumentos = renderizador === "mesa"
  ? ["--use-angle=gl", "--ignore-gpu-blocklist", "--enable-unsafe-swiftshader"]
  : ["--use-angle=swiftshader", "--enable-unsafe-swiftshader"];

// No CI usamos o Chromium completo do Playwright (channel "chromium", modo headless novo), que
// aceita os mesmos argumentos de GPU do navegador normal. Fora do CI dá para apontar um Chrome local.
const navegador = process.env.E2E_CHROME
  ? { launchOptions: { args: argumentos, executablePath: process.env.E2E_CHROME } }
  : { channel: "chromium", launchOptions: { args: argumentos } };

module.exports = defineConfig({
  testDir: "./testes",
  testMatch: arquivos,
  timeout: 120_000,
  expect: { timeout: 30_000 },
  fullyParallel: false,
  workers: 1,
  retries: 0,
  forbidOnly: !!process.env.CI,
  reporter: [["list"], ["html", { open: "never", outputFolder: `playwright-report/${modo}` }]],
  outputDir: `test-results/${modo}`,
  use: {
    baseURL: `http://127.0.0.1:${porta}/`,
    screenshot: "only-on-failure",
    trace: "retain-on-failure",
    video: "off",
  },
  // Servidor HTTP temporário com os arquivos exportados. No CI ele já é iniciado pelo workflow
  // (reuseExistingServer); fora do CI o próprio Playwright inicia e encerra.
  webServer: {
    command: `python3 -m http.server ${porta} --bind 127.0.0.1 --directory "${pasta}"`,
    url: `http://127.0.0.1:${porta}/index.html`,
    reuseExistingServer: true,
    timeout: 30_000,
  },
  projects: [
    {
      name: "computador",
      use: { ...devices["Desktop Chrome"], viewport: { width: 1366, height: 768 }, ...navegador },
    },
    {
      // Perfil Pixel 7 (toque, densidade de pixels, user agent) com a tela inteira do aparelho.
      name: "celular-retrato",
      use: { ...devices["Pixel 7"], viewport: { width: 412, height: 915 }, ...navegador },
    },
    {
      name: "celular-paisagem",
      use: { ...devices["Pixel 7 landscape"], viewport: { width: 915, height: 412 }, ...navegador },
    },
  ],
});
