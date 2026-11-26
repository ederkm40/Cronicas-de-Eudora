# Relatório da infraestrutura: Wiki, prévias e memória

| | |
|---|---|
| **Data** | 26/11/2026 |
| **Versão do jogo** | continua 0.2-alpha (sem mudança de gameplay) |
| **Branch** | `infra/wiki-previews-memoria` (a partir do `main` `e516f21`) |
| **Commits** | `6da13b1` (prévias e publicação), `a8665a1` (Wiki), `dd6ba05` (memória), mais os ajustes registrados no PR |
| **Pull Request** | https://github.com/ederkm40/Cronicas-de-Eudora/pull/2 |
| **Prévia do jogo** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-2/ |
| **Prévia da Wiki** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-2/wiki/ |

## Objetivo

Preparar o repositório para um desenvolvimento contínuo: prévia jogável de cada Pull Request antes da aprovação, Wiki pública gerada a partir do repositório, e memória permanente para que qualquer IA continue o projeto. Tudo sem custo.

## Funcionalidades implementadas

- **Workflow `publicar.yml`** (substitui o `web.yml`):
  - job `testar`: importa → 3 suítes do jogo → testes da Wiki e do site → exporta → gera a Wiki → verifica os arquivos;
  - job `publicar`: no `main`, publica na raiz e em `/wiki/`; em PR do próprio repositório, publica em `/previews/pr-N/`; confere e, se preciso, reconstrói a raiz a partir do `main`; limpa as prévias de PRs fechados; verifica o endereço; comenta no PR;
  - job `remover-previa`: apaga a prévia quando o PR fecha.
- **Montagem do site** (`tools/site/montar_site.py`): ações `oficial`, `previa`, `remover`, `limpar`. Mantém `publicacao.json`, `/previews/index.html` e `.nojekyll`.
- **Scripts de CI** (`tools/ci/`): instalar o Godot, construir a parte (jogo, Wiki e `versao.json`), abrir e enviar o `gh-pages`, verificar a publicação.
- **Wiki**: gerador `tools/wiki/build_wiki.py` com conversor de Markdown próprio. 56 páginas iniciais: página inicial, 12 categorias, 27 artigos, painel de desenvolvimento (10 páginas) e as páginas geradas a partir de `docs/` (changelog, 3 relatórios, 8 decisões, busca).
- **Memória**: `AGENTS.md`, `CLAUDE.md` reescrito, `docs/IA/` (4 documentos), `docs/CHANGELOG.md`, relatórios 0.1 e 0.2 (retroativos) e este, 8 decisões técnicas.

## Funcionalidades alteradas

- A publicação deixou de usar `actions/deploy-pages` e passou a usar o branch `gh-pages`.
- O workflow passou a rodar também os testes da Wiki e do site.
- `.gdignore` em `docs/`, `tools/` e `wiki-src/`: nada disso entra no `.pck` (o `.pck` continua com 73.664 bytes, igual ao do `main`).

## Correções

- Encontradas e corrigidas durante a etapa: `|` dentro de links em tabelas; lista com marcadores seguida de lista numerada que virava uma lista só; menu lateral vazio no computador; texto sem bloco no YAML com `: `; verificação que esperava 10 minutos mesmo com o Pages mal configurado. A pedido do proprietário, a verificação deixou de ser tolerada (`continue-on-error` removido): se a prévia não abrir no endereço público, o job `Publicar` falha, para o PR não ser aprovado sem prévia no ar.

## Valores e parâmetros modificados

Nenhum valor do jogo. Parâmetros da infraestrutura: espera máxima da verificação de 10 minutos; artefato guardado por 7 dias; grupo de concorrência `gh-pages`.

## Arquivos afetados

Novos: `.github/workflows/publicar.yml`, `tools/ci/*.sh` (5), `tools/site/montar_site.py`, `tools/site/test_montar_site.py`, `tools/wiki/build_wiki.py`, `tools/wiki/markdown_mini.py`, `tools/wiki/test_wiki.py`, `wiki-src/**` (45 arquivos), `AGENTS.md`, `docs/CHANGELOG.md`, `docs/IA/*` (4), `docs/versoes/*/RELATORIO.md` (3), `docs/decisoes/*` (9), `.gdignore` (3).
Alterados: `CLAUDE.md`, `README.md`, `docs/TECNICO.md`, `docs/ROADMAP.md`, `.gitignore`.
Removido: `.github/workflows/web.yml`.
Sem mudanças: `scripts/`, `scenes/`, `tests/`, `project.godot`, `export_presets.cfg`.

## Testes executados e resultados

| Teste | Onde | Resultado |
|---|---|---|
| `tests/run_tests.gd` | local e GitHub Actions (execução 45818565861) | **aprovado**: 16 testes, 1.627 verificações |
| `tests/smoke_test.gd` | local e Actions | **aprovado** |
| `tests/long_simulation.gd -- --segundos=300` | local e Actions | **aprovado** |
| `tools/wiki/test_wiki.py` (14 testes: links de todas as páginas, busca no Node, determinismo, fontes intactas, modo prévia, falhas esperadas, Markdown) | local e Actions | **aprovado** |
| `tools/site/test_montar_site.py` (7 testes: oficial × prévia, novo envio, remoção, limpeza, exportação incompleta, linha de comando) | local e Actions | **aprovado** |
| Exportação + verificação dos 4 arquivos do Godot | local e Actions | **aprovado** |
| Primeira publicação real no `gh-pages` (execução 45818565861) | Actions | raiz reconstruída a partir do `main` `e516f21`; prévia em `previews/pr-2/` com o commit `dd6ba05`; comentário publicado no PR |
| Conteúdo real do `gh-pages`, baixado e aberto no Chrome no mesmo caminho do Pages (celular em pé, deitado e computador) | local | jogo oficial e da prévia carregam e rodam; Wiki da prévia com faixa de aviso; busca "nucleo vital" → Núcleo vital; links internos e "Jogar" corretos; lista de prévias |
| Verificação do endereço público, antes do ajuste do Pages | Actions (45818565861) | **não abriu**, como esperado: o log mostrava o Pages em `build_type: workflow` |
| Verificação do endereço público, depois do ajuste do proprietário | Actions (45824707443) | **verificado no ar**: Pages em `legacy gh-pages`; `previews/pr-2/` (jogo, .js, .pck, .wasm, Wiki, busca, CSS) respondeu 200 com o commit `ec1ddba` |
| `verificar_publicacao.sh` contra o servidor local | local | aprova com o commit certo e acusa com o commit errado |

### Fluxo completo no GitHub (envios reais)

| Teste | Execução | Resultado |
|---|---|---|
| **Novo envio atualiza a prévia** | 45820818639 | `previews/pr-2/` passou de `dd6ba05` para `696e96e`; o mesmo comentário do PR foi atualizado, sem criar outro |
| **Segunda prévia ao mesmo tempo** (PR #3, descartável) | 45820854673 | `previews/pr-3/` publicada ao lado da `pr-2`; raiz intacta |
| **Publicações simultâneas** | as duas acima | serializadas pelo grupo `gh-pages`: PR #2 publicou das 12:34:33 às 12:34:49; PR #3 começou às 12:34:51. Nenhuma sobrescreveu a outra |
| **Remoção ao fechar o PR** | 45821063474 | PR #3 fechado sem merge → `previews/pr-3/` apagada, lista de prévias atualizada, comentário "Prévia removida"; `pr-2` e a raiz byte a byte iguais |
| **Aviso imediato de Pages mal configurado** | 45820818639 | comentário: "Ainda não está no ar: o GitHub Pages publica pelo método antigo (workflow main)…" |
| **Integração no `main`** (publicar oficial + remover a prévia do PR integrado) | — | não executado: o merge é decisão do proprietário. Os dois caminhos usam o mesmo código já exercitado (a publicação do oficial rodou na reconstrução da raiz; a remoção rodou no PR #3) e estão cobertos por `test_montar_site.py` |

O branch `teste/remocao-de-previa` não pôde ser apagado pela sessão do Claude Code (o proxy bloqueia). Ele não tem efeito e pode ser apagado pelo botão "Delete branch" do PR #3.

## Problemas conhecidos e limitações

- O GitHub Pages precisa continuar em *Deploy from a branch* → `gh-pages` / `(root)` (ajustado pelo proprietário). Na sessão do Claude Code na nuvem, a API de configuração do Pages fica bloqueada e `*.github.io` não abre, então a confirmação no ar vem pelo workflow.
- O caminho de falha da verificação (job `Publicar` vermelho) não foi observado depois da remoção do `continue-on-error`, porque o Pages já estava ajustado e a verificação passou. Antes, a mesma etapa falhava com o Pages no método antigo.
- A Wiki oficial (`/wiki/`) mostra um aviso até o merge. A Wiki completa está na prévia.
- A primeira publicação de uma prévia, quando a raiz está desatualizada, demora alguns minutos a mais, porque reconstrói o oficial.
- Envios só de documentação também rodam todos os testes, cerca de 5 minutos. É gratuito, mas não é instantâneo.
- Problemas do jogo: os mesmos da 0.2-alpha (ver `docs/IA/ESTADO_ATUAL.md`).

## Custo

Nenhum. GitHub Actions com runners padrão, gratuitos para repositório público; GitHub Pages; Godot; Python e Node já disponíveis nos runners. Sem dependências externas, CDN, banco de dados ou serviços pagos.
