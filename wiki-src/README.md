# Fontes da Wiki

Esta pasta guarda os **arquivos-fonte** da Wiki. O site é gerado por `tools/wiki/build_wiki.py` e publicado em https://ederkm40.github.io/Cronicas-de-Eudora/wiki/ (oficial) e em `/previews/pr-<número>/wiki/` (prévias de Pull Request).

**Responsável editorial: ChatGPT** (ver `AGENTS.md`). O Claude Code só mexe aqui para corrigir o gerador ou quando o proprietário pedir.

## Como editar

- **Um artigo = um arquivo `.md`.** Editar um arquivo não exige mexer em nenhum outro.
- O caminho do arquivo define o endereço:
  - `melhorias/poder-arcano.md` → `/wiki/melhorias/poder-arcano/`
  - `melhorias/index.md` → página da categoria `/wiki/melhorias/`
- Arquivos que começam com `_` e este README não viram páginas.
- Cada artigo começa com um cabeçalho:

```
---
titulo: Poder arcano
resumo: Uma frase que aparece nas listas e na busca.
estado: PUBLICADO
versao: 0.2-alpha
ordem: 10
---
```

| Campo | Obrigatório | Valores |
|---|---|---|
| `titulo` | sim | texto |
| `resumo` | não | uma frase |
| `estado` | não | `PLANEJADO`, `EM_DESENVOLVIMENTO`, `IMPLEMENTADO`, `TESTADO`, `PUBLICADO` |
| `versao` | não | versão em que surgiu, ex.: `0.2-alpha` |
| `ordem` | não | número para ordenar na categoria (menor primeiro; padrão 100) |

## Sintaxe especial

| Escreva | Resultado |
|---|---|
| `[[melhorias/cadencia]]` | link para o artigo, com o título dele |
| `[[melhorias/cadencia\|texto]]` | link com outro texto |
| `[[progressao/experiencia#curva-de-experiencia]]` | link para uma seção |
| `[[inicio]]` | link para a página inicial da Wiki |
| `{PUBLICADO}` (e os outros estados) | selo colorido de estado |
| `{{artigos}}` (sozinho na linha) | lista automática dos artigos da categoria |
| `{{categorias}}`, `{{relatorios}}`, `{{decisoes}}`, `{{jogar}}` | blocos automáticos |

Links para sites externos usam Markdown normal: `[texto](https://...)`. Links internos **precisam** usar `[[...]]`: o gerador confere se a página existe e **falha** se o link estiver quebrado.

## Regras de conteúdo

1. Só documente o que existe no jogo. Ideias futuras ficam com o estado `{PLANEJADO}` e nunca aparecem como algo que já existe.
2. Os números vêm do código. Na dúvida, confira `docs/IA/ENTREGA_PARA_CHATGPT.md` e os scripts em `scripts/`.
3. Os gráficos atuais são provisórios. Não descreva a aparência como definitiva.
4. Changelog, relatórios e decisões técnicas **não** ficam aqui: eles vêm de `docs/` e aparecem sozinhos no Painel de desenvolvimento.

## Testar localmente

```
python3 tools/wiki/build_wiki.py --saida build/wiki
python3 -m unittest discover -s tools -p "test_*.py"
```
