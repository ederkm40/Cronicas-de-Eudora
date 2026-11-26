# Continuidade: como outra IA assume o projeto

## Último estado validado

- **`main`:** `3d9102c` (0.3-alpha do PR #5, integrada em `51e7e5d`, mais a Wiki da 0.3 do PR #6). Jogo e Wiki oficiais publicados a partir dele.
- **Em revisão:** PR #7 (branch `feat/manutencao-e-documento-mestre-03`): manutenção pós-0.3 (builds de produção e QA, save validado, retomada do joystick, limpeza) e o Documento Mestre de Sistemas. Relatório em `docs/versoes/manutencao-pos-0.3/RELATORIO.md`. Não fazer merge: o proprietário aprova.
- **Proteção da `main`:** checks `Testar e exportar` e `Publicar`. Mantenha esses nomes de job.

## Onde procurar antes de criar algo

1. **Código** (`scripts/`): a fonte de verdade sobre o que existe.
2. **`docs/TECNICO.md`**: como o que existe funciona, com os números.
3. **`docs/ROADMAP.md`**: o que está aprovado para entregar.
4. **`docs/design/DOCUMENTO_MESTRE_SISTEMAS.md`** e **`docs/design/catalogos/`**: design de todos os sistemas, com estados independentes de design (`PROPOSTO_NAO_APROVADO`, `APROVADO`, `REJEITADO`, `SUBSTITUÍDO`), implementação e validação. **Não autoriza implementar.** Consulte antes de propor um sistema, para não duplicar. Ao implementar algo, atualize os estados e os números a partir do código.
5. **`docs/decisoes/`**: decisões técnicas (0001–0011).

## Decisões importantes (detalhes em `docs/decisoes/`)

1–9: Godot 4.7.2/Compatibility/Web sem threads; projeto em texto; arrays + MultiMesh; pausa nativa; melhorias recalculadas; `gh-pages` com prévias; Wiki própria; Claude desenvolve e ChatGPT documenta; QA só no CI.
10. Arquitetura do combate 0.3 (item 9, a ponte por `?teste=1`, substituído pela 0011).
11. Build de produção (preset `Web`) sem a ponte de testes; build `Web QA` só no CI para o Playwright.

## Pendências

- Aprovação do PR #7.
- Teste com pessoas em celulares físicos (equilíbrio, chefe, duplo toque, retomada do joystick) e FPS com a horda cheia.
- Destro/canhoto e ajuste do joystick (aprovado como direção, não implementado).
- Pesquisa nas fontes de referência do Documento Mestre (seção 38): ainda não consultadas.
- Wiki e changelog (ChatGPT): dados em `ENTREGA_PARA_CHATGPT.md`.

## Restrições

- Custo zero; dependências de desenvolvimento só no CI e fixadas; nada externo no jogo publicado.
- Nunca trabalhar no `main` nem fazer merge.
- Não alterar equilíbrio, conteúdo ou progressão sem uma etapa de gameplay aprovada.
- Na sessão do Claude Code na nuvem: API do Pages, GraphQL, PyPI e npm podem estar bloqueados; `*.github.io` não abre; `push --force` e `git reset --hard` podem ser bloqueados. Use REST, Actions e logs.

## Comandos de teste

Ver `AGENTS.md`. No CI, o Playwright roda duas vezes: na build Web QA e na build de produção. Para rodar localmente, exporte as duas (`construir_parte.sh` e `construir_qa.sh`) e use `E2E_MODO=qa` ou `E2E_MODO=producao`.
