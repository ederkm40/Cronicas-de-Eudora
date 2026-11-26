# CLAUDE.md — instruções específicas do Claude Code

**Leia primeiro o `AGENTS.md`.** Ele traz as regras gerais, a divisão de responsabilidades com o ChatGPT, as regras técnicas, as de honestidade e as de custo zero. Este arquivo só acrescenta o que é específico do Claude Code.

## Seu papel

Você desenvolve o jogo. Concentre o contexto em código, testes e builds. **Não escreva artigos enciclopédicos nem reconstrua a Wiki** a cada atualização: isso é tarefa do ChatGPT. Entregue os fatos técnicos em `docs/IA/ENTREGA_PARA_CHATGPT.md`.

## Ao começar uma sessão

1. Leia `docs/IA/ESTADO_ATUAL.md` e `docs/IA/CONTINUIDADE.md`.
2. Confira o `main` real (`git log origin/main`) e os Pull Requests abertos. A documentação pode estar atrasada em relação ao código.
3. Crie a branch da etapa a partir do `main` atualizado. Nunca trabalhe direto no `main` e nunca faça merge.

## Regras de código

- Prefira criar nós em código (como em `scripts/main.gd`) a escrever cenas `.tscn` complexas à mão.
- GDScript com tipos estáticos e `class_name` por sistema. Valores de ajuste como `@export` no topo do script.
- Uma melhoria nova entra em `Upgrades.DEFINITIONS`, `describe_next()` e `refresh()`, e ganha um teste de efeito em `tests/run_tests.gd`.
- Um sistema novo ganha testes em `tests/run_tests.gd` e uma verificação numa partida real em `tests/smoke_test.gd`. Use os ganchos `spawning_enabled`, `spawn_at`, `invulnerable` e `scripted_input` em vez de esperar o acaso.

## Antes de cada commit

Rode os comandos de verificação do `AGENTS.md` e confira as mensagens de sucesso. Para mudanças visuais, exporte para Web e confira no navegador, com tela de celular simulada, em pé e deitada.

## Ao entregar uma etapa

Atualize, em poucos commits, com mensagens em português:

1. `docs/TECNICO.md`, se a arquitetura ou os números mudaram.
2. `docs/versoes/<versão>/RELATORIO.md`: objetivo, mudanças, valores, arquivos, testes e resultados reais, problemas, commit, PR e link da prévia.
3. `docs/IA/ESTADO_ATUAL.md` e `docs/IA/CONTINUIDADE.md`.
4. `docs/IA/ENTREGA_PARA_CHATGPT.md`: o pacote de fatos para a Wiki.
5. `docs/decisoes/`, se tomou uma decisão técnica importante (nunca apague as antigas).

Abra o Pull Request com o resumo, os testes executados, as limitações e instruções de teste. Espere o workflow passar e confira, no comentário automático, se a prévia foi **verificada no ar**. Entregue ao proprietário o link da prévia.

## Ambiente do Claude Code

- Na sessão na nuvem, a API de configuração do GitHub Pages fica bloqueada pelo proxy. Não dá para ler nem mudar a origem do Pages daqui: peça ao proprietário. O `GITHUB_TOKEN` do workflow consegue ler essa configuração (o passo "Verificar se abriu de verdade" mostra o resultado no log).
- Pull Requests são abertos pela API REST (`gh api repos/<dono>/<repo>/pulls`). O `gh pr create` usa GraphQL, que fica bloqueado.
- Daqui não dá para abrir `*.github.io`. Para confirmar uma publicação, leia o log e o comentário do workflow.
