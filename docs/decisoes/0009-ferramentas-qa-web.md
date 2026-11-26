# 0009: Ferramentas de QA no CI (GDScript Toolkit e Playwright), sem custo e fora do jogo

| | |
|---|---|
| **Situação** | Aceita |
| **Data** | 26/11/2026 |

## Contexto

Os testes do jogo rodam no Godot sem tela, mas nada verificava o **estilo e a sintaxe do GDScript** antes da execução, nem se a **versão Web exportada** abria de fato num navegador. O proprietário trabalha só pelo navegador, e a proteção da `main` exige os checks `Testar e exportar` e `Publicar`. Nenhum custo é permitido.

## Decisão

- **GDScript Toolkit 4.5.0** (`gdlint`, `gdformat`), instalado com versões fixadas (`requirements-ci.txt`) num ambiente virtual temporário do runner.
  - `gdlint` em `scripts/` e `tests/`, com **todas as regras padrão** da versão 4.5.0, sem `gdlintrc` e sem exceções. Para ver a lista: `gdlint --dump-default-config`.
  - `gdformat --check` **só nos arquivos `.gd` alterados** em relação ao commit-base do PR. O código antigo não foi reformatado em massa; cada arquivo passa a seguir o `gdformat` na primeira vez que é alterado.
  - Antes de integrar, o parser do 4.5.0 leu sem erro todos os 15 arquivos GDScript do projeto (Godot 4.7.2).
- **Playwright Test 1.65.1** em `tools/e2e/` (`package.json` + `package-lock.json`, instalação com `npm ci`), só Chromium, instalado pela ferramenta oficial no runner.
  - Abre o **jogo realmente exportado** pelo Godot, servido por `python3 -m http.server` em `127.0.0.1:8060`.
  - 3 perfis: computador 1366 × 768; Pixel 7 em pé, 412 × 915, com toque; Pixel 7 deitado, 915 × 412.
  - Verificações objetivas, sem esperas fixas: `#status` removido pela página do Godot ao terminar o `startGame()`; versão "Godot Engine v4.7.2" no console; WebGL 2; `index.html`, `.js`, `.wasm` e `.pck` com 200; nenhuma falha de rede; canvas visível, dentro da tela e ocupando a janela; imagem do canvas mudando; nenhum erro de JavaScript.
  - **Renderizador:** o Chromium roda dentro do `xvfb-run` com `--use-angle=gl`. Assim usa Mesa/llvmpipe (OpenGL 4.5), que desenha corretamente o MultiMesh do Godot. Sem tela virtual, ele caía no SwiftShader (verificado no runner). O renderizador usado é impresso no log.
  - Evidências (screenshot e trace) só em falha, guardadas por 7 dias.
- **Node.js 22** configurado com `actions/setup-node`. O teste de busca da Wiki em JavaScript fica obrigatório no CI (`EXIGIR_NODE=1`).
- Tudo dentro do job existente `testar` ("Testar e exportar"). Nenhum job obrigatório novo.

## Alternativas consideradas

- **Serviços de navegadores na nuvem** (BrowserStack, LambdaTest): pagos. Descartados.
- **Firefox e WebKit no Playwright:** adiados para não aumentar o tempo e o cache do CI nesta primeira etapa.
- **Reformatar todo o GDScript de uma vez:** descartado para não misturar mudanças de estilo em massa com o histórico. A formatação avança arquivo por arquivo.

## Consequências

- **Dependências de desenvolvimento** (gdtoolkit, Playwright, Chromium) existem **só no runner do GitHub Actions**, com versões fixadas. Não entram no `.pck`, porque `tools/` tem `.gdignore`, nem no site publicado. O jogo continua sem dependências externas em execução.
- Atualizar o Playwright exige gerar um novo `package-lock.json` (`npm install --package-lock-only` com a versão nova) e conferir o log do teste.
- A emulação de Pixel 7 **não substitui** o teste num celular físico.
- O job `Testar e exportar` ganhou cerca de 1 minuto, para instalar o Chromium e rodar 5 testes de navegador.
