# Entrega para o ChatGPT

*Pacote de fatos técnicos da última entrega do Claude Code. Use para atualizar a Wiki (`wiki-src/`), o `docs/CHANGELOG.md` e revisar o relatório. Não é um artigo: são dados.*

## Identificação

| | |
|---|---|
| **Etapa** | Infraestrutura: Wiki, prévias jogáveis e memória permanente |
| **Versão do jogo** | continua **0.2-alpha** (sem mudança de gameplay) |
| **Branch** | `infra/wiki-previews-memoria` |
| **Commit** | PENDENTE_COMMIT |
| **Pull Request** | PENDENTE_PR |
| **Prévia do jogo** | PENDENTE_PREVIA |
| **Prévia da Wiki** | PENDENTE_PREVIA`wiki/` |

## Resumo técnico

- A publicação deixou de usar `actions/deploy-pages` (workflow `web.yml`, removido) e passou a usar o **branch `gh-pages`** (workflow `publicar.yml`).
- Estrutura do site: `/` jogo oficial · `/wiki/` Wiki oficial · `/previews/` lista · `/previews/pr-N/` jogo do PR · `/previews/pr-N/wiki/` Wiki do PR.
- Cada PR do próprio repositório ganha prévia, atualizada a cada envio e apagada ao fechar ou integrar. PRs de forks só são testados.
- O workflow comenta no PR o endereço da prévia e o resultado da verificação real (busca `versao.json` com o commit e testa jogo e Wiki).
- A Wiki é gerada de `wiki-src/` por `tools/wiki/build_wiki.py` (Python, só biblioteca padrão). Changelog, relatórios e decisões vêm de `docs/` e aparecem no painel de desenvolvimento.

## Arquivos

| Novo | Alterado | Removido |
|---|---|---|
| `.github/workflows/publicar.yml`, `tools/ci/*.sh`, `tools/site/*`, `tools/wiki/*`, `wiki-src/**`, `AGENTS.md`, `docs/CHANGELOG.md`, `docs/versoes/**`, `docs/decisoes/**`, `docs/IA/**`, `.gdignore` em `docs/`, `tools/`, `wiki-src/` | `CLAUDE.md`, `README.md`, `docs/TECNICO.md`, `docs/ROADMAP.md` | `.github/workflows/web.yml` |

Nenhum arquivo em `scripts/`, `scenes/`, `tests/`, `project.godot` ou `export_presets.cfg` foi alterado.

## Comportamentos novos no jogo

Nenhum. Mecânicas e números idênticos aos da 0.2-alpha.

## Valores alterados

Nenhum valor do jogo.

## Testes realizados e resultados

Ver `docs/versoes/0.2-alpha-infra/RELATORIO.md` (seção Testes) para os resultados registrados.

## Problemas conhecidos

- As prévias e a Wiki só ficam acessíveis depois que o proprietário muda a origem do GitHub Pages para o branch `gh-pages`.
- Os demais problemas do jogo seguem os da 0.2-alpha (ver `docs/IA/ESTADO_ATUAL.md`).

## Para a Wiki

- A Wiki inicial (56 páginas) foi escrita pelo Claude Code **só para iniciar**. A partir de agora, a manutenção editorial é do ChatGPT. Leia `wiki-src/README.md`, que tem a sintaxe e as regras.
- Fatos documentados: versões 0.1 e 0.2 (controles, combate, hordas, XP, orbes, level-up, 6 melhorias com valores e limites, desempenho, testes, limitações). Todos os números foram tirados do código em `scripts/`.
- Sugestões de revisão editorial: revisar textos e títulos; manter a tabela "Últimas atualizações" da página inicial; quando a etapa for integrada, mudar o estado de "Infraestrutura" de {EM_DESENVOLVIMENTO} para {PUBLICADO} em `desenvolvimento/index.md`, `versoes.md`, `roadmap.md` e `funcionalidades.md`.
- Categorias sem conteúdo (Chefes, Itens) mostram só o que está {PLANEJADO}. Não criar artigos de coisas inexistentes.
