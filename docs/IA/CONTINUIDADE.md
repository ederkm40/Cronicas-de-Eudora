# Continuidade: como outra IA assume o projeto

## Último estado validado

- **`main`:** `1b6c65c14c8a647c12568f780c6dc25f053d1d0d`, com a versão 0.2-alpha e a infraestrutura de Wiki, prévias e memória (PR #2, integrado por squash). Jogo e Wiki oficiais publicados a partir desse commit.
- **Em revisão:** PR #4 (branch `infra/ferramentas-qa-web`): GDScript Toolkit, testes de navegador com Playwright e formulários do GitHub. Todos os checks passaram. Relatório em `docs/versoes/infra-ferramentas-qa/RELATORIO.md`.
- **Proteção da `main`:** exige os checks `Testar e exportar` e `Publicar`. Mantenha esses nomes de job.

## Decisões importantes (resumo; detalhes em `docs/decisoes/`)

1. Godot 4.7.2, GDScript, Compatibility, Web sem threads (0001).
2. Projeto 100% em texto, partida montada em código (0002).
3. Arrays + MultiMesh para objetos repetidos (0003).
4. Level-up pela pausa nativa `SceneTree.paused` (0004).
5. Melhorias recalculadas a partir da base (0005).
6. Site no branch `gh-pages` com prévias por PR (0006).
7. Wiki com gerador próprio em Python, só biblioteca padrão (0007).
8. Claude Code desenvolve; ChatGPT documenta; GitHub é a fonte de verdade (0008).
9. Ferramentas de QA só no CI: gdtoolkit 4.5.0 e Playwright 1.65.1 com Chromium e Mesa via Xvfb (0009).

## Trabalho concluído

- 0.1-alpha: base jogável.
- 0.2-alpha: progressão e melhorias.
- Infraestrutura de Wiki, prévias e memória (PR #2).
- Ferramentas de QA (PR #4, aguardando aprovação).

## Pendências

- Aprovação do PR #4 pelo proprietário.
- Testar num celular físico e anotar o FPS com a horda cheia.
- Ajustar o equilíbrio (dano base, ritmo das hordas, curva de XP).
- Wiki (responsabilidade do ChatGPT): marcar a infraestrutura do PR #2 como publicada e registrar as ferramentas de QA (dados em `ENTREGA_PARA_CHATGPT.md`).
- Branches antigas que podem ser apagadas pelo proprietário: `etapa-0.2-alpha-ecos-da-evolucao`, `infra/wiki-previews-memoria`, `teste/remocao-de-previa`.

## Restrições

- Custo zero. Dependências de desenvolvimento só no CI e com versão fixada; nenhuma dependência externa no jogo publicado (ver `AGENTS.md`).
- Nunca trabalhar no `main` nem fazer merge; o proprietário aprova.
- Não mudar as mecânicas da 0.2 sem uma etapa de gameplay aprovada.
- Na sessão do Claude Code na nuvem: a API do Pages, o GraphQL do GitHub, o PyPI e o npm podem estar bloqueados; `*.github.io` não abre; `push --force` é bloqueado. Use a REST API, o GitHub Actions e os logs do workflow.

## Comandos de teste

Ver `AGENTS.md`, seção "Comandos de verificação". No CI, todos rodam no job "Testar e exportar". O log mostra `Success: no problems found` (gdlint), `TESTES: OK`, `SMOKE TEST: OK`, `SIMULAÇÃO LONGA: OK`, `OK` (Python) e `5 passed` (Playwright).

## Próximas ações

1. O proprietário testa a prévia do PR #4 e aprova.
2. Etapa **0.3-alpha (variedade de combate)**: 2 armas novas (aura de dano e lâmina giratória). Todo `.gd` novo ou alterado precisa passar no `gdlint` e no `gdformat`. Seguir o fluxo do `AGENTS.md`.
