# Continuidade: como outra IA assume o projeto

## Último estado validado

- **`main`:** `70cf85fc5e459a042f415e4b5e5493a2233465e9` (0.2-alpha + infraestrutura de Wiki, prévias, memória e ferramentas de QA). Jogo e Wiki oficiais publicados a partir dele.
- **Em revisão:** PR #5 (branch `feat/grande-expansao-combate-03`): versão 0.3-alpha. Relatório em `docs/versoes/0.3-alpha/RELATORIO.md`. Não fazer merge: o proprietário aprova.
- **Proteção da `main`:** checks `Testar e exportar` e `Publicar`. Mantenha esses nomes de job.

## Decisões importantes (detalhes em `docs/decisoes/`)

1–9: Godot 4.7.2/Compatibility/Web sem threads; projeto em texto; arrays + MultiMesh; pausa nativa; melhorias recalculadas; `gh-pages` com prévias; Wiki própria; Claude desenvolve e ChatGPT documenta; QA só no CI.
10. Arquitetura do combate 0.3: armas em camadas (catálogo, arsenal, nó); inimigos e chefe no mesmo `EnemyManager`; chefe com máquina de estados; esquiva por gesto; estatísticas só do que é contado; save JSON versionado; ponte de testes `?teste=1`; testes em suítes.

## Trabalho concluído

- 0.1-alpha, 0.2-alpha, infraestrutura (PR #2) e ferramentas de QA (PR #4): integrados.
- 0.3-alpha (PR #5): entregue para revisão, com partes antecipadas da 0.4, 0.5 e 0.6 (ver `docs/ROADMAP.md`).

## Pendências

- Aprovação do PR #5.
- Teste com pessoas no celular (equilíbrio, chefe, duplo toque) e FPS com a horda cheia.
- Destro/canhoto e ajuste do joystick (direção aprovada, não implementada).
- Wiki e changelog (ChatGPT): dados em `ENTREGA_PARA_CHATGPT.md`. A entrada da 0.3 no changelog foi escrita pelo Claude Code a pedido do proprietário e aguarda revisão.
- Branches antigas que o proprietário pode apagar: `etapa-0.2-alpha-ecos-da-evolucao`, `infra/wiki-previews-memoria`, `teste/remocao-de-previa`, `infra/ferramentas-qa-web`.

## Restrições

- Custo zero; dependências de desenvolvimento só no CI e fixadas; nada externo no jogo publicado.
- Nunca trabalhar no `main` nem fazer merge.
- Na sessão do Claude Code na nuvem: API do Pages, GraphQL, PyPI e npm podem estar bloqueados; `*.github.io` não abre; `push --force` e `git reset --hard` podem ser bloqueados. Use REST, Actions e logs.

## Comandos de teste

Ver `AGENTS.md`. No CI o log mostra `Success: no problems found`, `TESTES: OK`, `SMOKE TEST: OK`, `SIMULAÇÃO LONGA: OK`, `OK` (Python) e `18 passed` (Playwright). Equilíbrio: `tests/balance_simulation.gd` (fora do CI).

## Próximas ações

1. O proprietário testa a prévia do PR #5 (celular em pé e deitado, computador) e aprova.
2. Proposta (a aprovar): rodada de testes com pessoas e ajustes; destro/canhoto e ajuste do joystick.
