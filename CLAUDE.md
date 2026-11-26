# Instruções para IA neste repositório

Jogo de hordas isométrico para celular (retrato), Godot 4.7, GDScript, renderizador Compatibility. O dono do projeto não programa: escreva em português do Brasil, tanto nos comentários quanto nas mensagens de commit, e explique as mudanças em linguagem simples.

Antes de mexer, leia `docs/TECNICO.md` (como o jogo funciona) e `docs/ROADMAP.md` (o que vem a seguir).

## Regras do projeto

- Tudo em texto. Prefira criar nós em código (como em `scripts/main.gd`) a escrever cenas `.tscn` complexas à mão.
- GDScript com tipos estáticos e `class_name` por sistema. Valores de ajuste como `@export` no topo do script.
- Desempenho de celular em primeiro lugar: muitos objetos iguais (inimigos, projéteis, orbes) usam arrays + `MultiMesh`, nunca um nó por objeto. Sem sombras em tempo real; use `BlobShadow`.
- O jogo roda no navegador (exportação Web sem threads). Não use recursos que exijam threads nem C#.
- Commite os arquivos `.uid` e `.import` gerados pelo Godot. Não commite `.godot/` nem `build/`.
- **Pausa:** o level-up usa `get_tree().paused`. Sistemas novos de jogo devem ser pausáveis (o padrão). Só interfaces que precisam funcionar na pausa usam `PROCESS_MODE_ALWAYS`.
- **Melhorias:** efeitos são recalculados a partir dos valores base em `Upgrades.refresh()`. Uma melhoria nova entra em `Upgrades.DEFINITIONS`, `describe_next()` e `refresh()`, e ganha um teste de efeito em `tests/run_tests.gd`.
- Não declare um teste como aprovado sem rodá-lo. Não diga que algo foi testado em celular físico se não foi.

## Fluxo de trabalho

- Cada etapa numa branch própria (`etapa-<versão>-<nome>`), nunca direto no `main`.
- Abra um Pull Request com o resumo, os testes executados e as limitações conhecidas. Espere o workflow passar.
- O `main` publica no GitHub Pages. Em Pull Request, o workflow só testa e exporta, sem publicar.

## Antes de cada commit

```bash
godot --headless --path . --import
godot --headless --path . --fixed-fps 60 --script res://tests/run_tests.gd        # "TESTES: OK"
godot --headless --path . --fixed-fps 60 --script res://tests/smoke_test.gd       # "SMOKE TEST: OK"
godot --headless --path . --fixed-fps 60 --script res://tests/long_simulation.gd -- --segundos=300   # "SIMULAÇÃO LONGA: OK"
```

Ao criar um sistema novo, acrescente testes dele em `tests/run_tests.gd`, e confira no smoke test que ele funciona numa partida de verdade. Nos testes, use os ganchos existentes (`spawning_enabled`, `spawn_at`, `invulnerable`, `scripted_input`) em vez de esperar o acaso.

## Publicação

O workflow `.github/workflows/web.yml` segue esta ordem: importar → testes → exportar → verificar arquivos → publicar (só no `main`). Endereço: https://ederkm40.github.io/Cronicas-de-Eudora/
