# 0007: Wiki com gerador estático próprio em Python (só biblioteca padrão)

| | |
|---|---|
| **Situação** | Aceita |
| **Data** | 26/11/2026 |

## Contexto

O projeto precisa de uma Wiki pública, gratuita, sem serviços externos nem bibliotecas por CDN, editável artigo por artigo por outra IA (ChatGPT) diretamente no GitHub.

## Decisão

- Fontes em `wiki-src/`: um arquivo Markdown por artigo, com cabeçalho `titulo/resumo/estado/versao/ordem`.
- `tools/wiki/build_wiki.py` converte com um conversor de Markdown próprio (`markdown_mini.py`). Não instala nada.
- Links internos `[[caminho]]` são validados: a geração falha com link quebrado, estado desconhecido ou artigo sem título.
- A busca é feita no navegador sobre `search-index.json`, sem servidor.
- A saída é determinística, e as fontes nunca são alteradas pela geração.
- Changelog, relatórios e decisões são lidos de `docs/` e viram páginas somente leitura.

## Consequências

Recursos de Markdown limitados ao necessário. Gerar a Wiki inteira leva menos de 1 s, então não há geração incremental.
