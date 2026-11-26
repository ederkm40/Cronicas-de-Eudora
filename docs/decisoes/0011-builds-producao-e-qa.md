# 0011: Build de produção sem a ponte de testes; build de QA só no CI

| | |
|---|---|
| **Situação** | Aceita |
| **Data** | 26/11/2026 |

## Contexto

Na 0.3-alpha, a ponte de testes do navegador (`scripts/web_bridge.gd`) ia em toda exportação Web e ligava com `?teste=1` no endereço. Ela aceita comandos que mudam a partida (`xp`, `hordas`, `invulneravel`, `limpar`, `chefe`, `chefe_vida`, `morrer`). Não havia placar nem dado online afetado, mas uma ferramenta de QA não deve estar no jogo publicado nem nas prévias públicas.

## Decisão

- Dois presets de exportação no `export_presets.cfg`:
  - **`Web` (produção):** `exclude_filter` tira `scripts/web_bridge.gd` do `.pck`. É o único usado por `tools/ci/construir_parte.sh`, portanto o único publicado (site oficial e prévias).
  - **`Web QA`:** funcionalidade de exportação personalizada `qa`. Exportado por `tools/ci/construir_qa.sh` dentro do job "Testar e exportar", em `$RUNNER_TEMP/qa`. Nunca é enviado ao job "Publicar".
- `main.gd` carrega a ponte por caminho (`load`) só quando `OS.has_feature("web")` e `OS.has_feature("qa")`. A ponte não tem `class_name`, para que nada no jogo dependa dela e a produção compile sem o arquivo.
- O endereço (`?teste=1`) deixou de ser o critério.
- `tools/ci/verificar_producao.sh` falha se o `.pck` de produção contiver o caminho `scripts/web_bridge`. Ele exige também que o de QA contenha, para a verificação não passar por engano.
- Playwright roda duas vezes no mesmo job: na QA (`jogo.spec.js` e `jogabilidade.spec.js`) e na produção (`jogo.spec.js` e `producao.spec.js`, que confere a ausência da ponte com e sem `?teste=1`).
- Nenhum job ou check novo: os checks obrigatórios continuam "Testar e exportar" e "Publicar".

## Alternativas consideradas

- **Manter a ponte e protegê-la por senha ou parâmetro secreto:** o código continuaria no jogo publicado. Descartado.
- **Testar só a produção, sem ponte:** os testes de jogabilidade (level-up, chefe, vitória) dependem de ler o estado e preparar situações. Descartado.
- **Apagar o arquivo da ponte antes da exportação de produção:** frágil e fácil de esquecer fora do CI. O `exclude_filter` do preset vale em qualquer exportação.

## Consequências

- Exportar localmente com o preset `Web` gera a build de produção. Para os testes de jogabilidade, exporte o preset `Web QA`.
- A build de QA testada não é byte a byte a publicada (difere pela ponte e pela funcionalidade `qa`). Por isso a produção também passa pelo `jogo.spec.js` e pelo `producao.spec.js`.
