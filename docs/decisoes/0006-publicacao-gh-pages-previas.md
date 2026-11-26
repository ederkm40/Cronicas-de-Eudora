# 0006: Publicação pelo branch `gh-pages`, com prévias por Pull Request

| | |
|---|---|
| **Situação** | Aceita, substitui a publicação por artefato do GitHub Actions (`web.yml`, de 25/11/2026) |
| **Data** | 26/11/2026 |

## Contexto

Até a 0.2-alpha, o workflow `web.yml` publicava com `actions/deploy-pages`. Esse método troca o site **inteiro** a cada publicação, e o ambiente `github-pages` só aceita publicações vindas do `main`. O proprietário precisa testar cada Pull Request **antes** do merge, sem substituir a versão oficial e sem nenhum custo.

## Decisão

- O site publicado fica no branch `gh-pages`, que vira a origem do GitHub Pages ("Deploy from a branch").
- A raiz guarda o jogo oficial, `/wiki/` a Wiki oficial e `/previews/pr-N/` o jogo e a Wiki de cada Pull Request aberto.
- Cada publicação troca **só a sua pasta** (`tools/site/montar_site.py`), preservando o resto.
- As publicações passam por um único grupo de concorrência (`gh-pages`), uma de cada vez.
- A cada publicação, o workflow confere se a raiz corresponde ao `main` atual. Se não corresponder, reconstrói a raiz. Isso corrige publicações que tenham sido canceladas na fila.
- Prévias só para Pull Requests do próprio repositório. Forks são testados com permissão só de leitura e não publicam. Não se usa `pull_request_target`.
- Ao fechar um Pull Request, a prévia é apagada. Toda publicação do `main` também remove prévias de PRs que já não estão abertos.

**Alternativas descartadas:** publicação por artefato com montagem do site inteiro a cada vez, porque exigiria reconstruir todas as prévias e liberar outras branches no ambiente `github-pages`; hospedagem externa, que tem custo.

## Consequências

- **Ajuste único do proprietário:** Settings → Pages → Source: *Deploy from a branch*, branch `gh-pages`, pasta `/ (root)`.
- O branch `gh-pages` cresce aos poucos: o `.wasm` de 39 MB é igual entre versões e fica guardado uma vez só.
- Custo zero: GitHub Pages e Actions são gratuitos para repositório público.
