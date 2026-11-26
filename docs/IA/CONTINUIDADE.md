# Continuidade: como outra IA assume o projeto

## Último estado validado

- **`main`:** `7aba866` (0.3-alpha, manutenção pós-0.3 e Documento Mestre do PR #7, documentação dos PRs #8 e #9). Jogo e Wiki oficiais publicados a partir dele.
- **Em revisão:** PR #10 (branch `feat/despertar-de-eudora-04`): 0.4-alpha "O Despertar de Eudora". Traz configurações mobile e pausa, som procedural, evoluções, estados, Tecelão, Semeador, elites, chefe atordoado e Prisão de ecos, e eventos. Relatório em `docs/versoes/0.4-alpha/RELATORIO.md`. Não fazer merge: o proprietário aprova. As mecânicas são **propostas experimentais**: depois do merge, atualize os estados no Documento Mestre (`EM_DESENVOLVIMENTO (PR #10)` → `IMPLEMENTADO`; design só vira `APROVADO` com a palavra do proprietário).
- **Proteção da `main`:** checks `Testar e exportar` e `Publicar`. Mantenha esses nomes de job.

## Onde procurar antes de criar algo

1. **Código** (`scripts/`): a fonte de verdade sobre o que existe.
2. **`docs/TECNICO.md`**: como o que existe funciona, com os números.
3. **`docs/ROADMAP.md`**: o que está aprovado para entregar.
4. **`docs/design/DOCUMENTO_MESTRE_SISTEMAS.md`** e **`docs/design/catalogos/`**: design de todos os sistemas, com estados independentes de design (`PROPOSTO_NAO_APROVADO`, `APROVADO`, `REJEITADO`, `SUBSTITUÍDO`), implementação e validação. **Não autoriza implementar.** Consulte antes de propor um sistema, para não duplicar. Ao implementar algo, atualize os estados e os números a partir do código.
5. **`docs/decisoes/`**: decisões técnicas (0001–0012).

## Decisões importantes (detalhes em `docs/decisoes/`)

1–9: Godot 4.7.2/Compatibility/Web sem threads; projeto em texto; arrays + MultiMesh; pausa nativa; melhorias recalculadas; `gh-pages` com prévias; Wiki própria; Claude desenvolve e ChatGPT documenta; QA só no CI.
10. Arquitetura do combate 0.3 (item 9, a ponte por `?teste=1`, substituído pela 0011).
11. Build de produção (preset `Web`) sem a ponte de testes; build `Web QA` só no CI para o Playwright.
12. Núcleo de gameplay 0.4: estados em arrays do `EnemyManager`, um ponto de entrada para o dano (`_hurt`), evoluções como dados, `EventDirector` separado, configurações em arquivo próprio, som gerado no código.

## Pendências

- Aprovação do PR #10 e decisão sobre cada mecânica experimental.
- Teste com pessoas em celulares físicos (equilíbrio, chefe — o piloto venceu 3/3 na 0.4 —, fenda, botão de pausa, joystick fixo, som) e FPS com a horda cheia.
- `EnemyManager` está no limite de 20 métodos públicos: o próximo sistema de inimigos precisa de uma classe auxiliar.
- Pesquisa nas fontes de referência do Documento Mestre (seção 38): ainda não consultadas.
- Wiki e changelog (ChatGPT): dados em `ENTREGA_PARA_CHATGPT.md`.

## Restrições

- Custo zero; dependências de desenvolvimento só no CI e fixadas; nada externo no jogo publicado.
- Nunca trabalhar no `main` nem fazer merge.
- Não alterar equilíbrio, conteúdo ou progressão sem uma etapa de gameplay aprovada. (A etapa 3 foi uma etapa de gameplay pedida pelo proprietário.)
- Testes usam arquivos próprios: `MetaProgress.path` e `GameSettings.path`.
- Na sessão do Claude Code na nuvem: API do Pages, GraphQL, PyPI e npm podem estar bloqueados; `*.github.io` não abre; `push --force` e `git reset --hard` podem ser bloqueados. Use REST, Actions e logs.

## Comandos de teste

Ver `AGENTS.md`. No CI, o Playwright roda duas vezes: na build Web QA e na build de produção. Para rodar localmente, exporte as duas (`construir_parte.sh` e `construir_qa.sh`) e use `E2E_MODO=qa` ou `E2E_MODO=producao`.
