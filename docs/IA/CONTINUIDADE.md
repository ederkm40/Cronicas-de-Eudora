# Continuidade: como outra IA assume o projeto

## Último estado validado

- **`main`:** `e516f2187f4726b6d63ad674955c15397a0f548d`, versão 0.2-alpha, publicada e com o workflow aprovado (execução 45802232546).
- **Em revisão:** etapa de infraestrutura no PR #2 (branch `infra/wiki-previews-memoria`). Veja o relatório em `docs/versoes/0.2-alpha-infra/RELATORIO.md`.

## Decisões importantes (resumo; detalhes em `docs/decisoes/`)

1. Godot 4.7.2, GDScript, Compatibility, Web sem threads (0001).
2. Projeto 100% em texto, partida montada em código (0002).
3. Arrays + MultiMesh para objetos repetidos (0003).
4. Level-up pela pausa nativa `SceneTree.paused` (0004).
5. Melhorias recalculadas a partir da base (0005).
6. Site no branch `gh-pages` com prévias por PR (0006).
7. Wiki com gerador próprio em Python, só biblioteca padrão (0007).
8. Claude Code desenvolve; ChatGPT documenta; GitHub é a fonte de verdade (0008).

## Trabalho concluído

0.1-alpha (base jogável), 0.2-alpha (progressão e melhorias) e a infraestrutura desta etapa (Wiki, prévias e memória), esta última pendente de aprovação.

## Pendências

- **Ação do proprietário, uma vez só:** Settings → Pages → Build and deployment → Source: **Deploy from a branch** → branch **gh-pages**, pasta **/ (root)** → Save. Sem isso, as prévias e a Wiki não aparecem no endereço público. O jogo oficial continua no ar pela publicação anterior.
- Testar o jogo num celular físico e anotar o FPS com a horda cheia.
- Ajustar o equilíbrio (dano base, ritmo das hordas, curva de XP).

## Restrições

- Custo zero (ver `AGENTS.md`).
- Nunca trabalhar no `main` nem fazer merge; o proprietário aprova.
- Não mudar as mecânicas da 0.2 sem uma etapa de gameplay aprovada.
- Na sessão do Claude Code na nuvem: a API do Pages e o GraphQL do GitHub ficam bloqueados, e `*.github.io` não abre. Use a REST API e os logs do workflow.

## Comandos de teste

Ver `AGENTS.md`, seção "Comandos de verificação". Todos precisam terminar com a mensagem de sucesso.

## Próximas ações

1. O proprietário ajusta o Pages, testa a prévia e a Wiki e aprova o PR de infraestrutura.
2. O ChatGPT revisa a Wiki e o changelog na branch do PR (opcional antes do merge).
3. Etapa **0.3-alpha (variedade de combate)**: 2 armas novas (aura de dano e lâmina giratória), com espaços de arma próprios e melhorias que podem trazer uma arma nova. Seguir o fluxo do `AGENTS.md`.
