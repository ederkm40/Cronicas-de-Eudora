# Instruções para IA neste repositório

Jogo de hordas isométrico para celular (retrato), Godot 4.7, GDScript, renderizador Compatibility. O dono do projeto não programa: escreva em português do Brasil, tanto nos comentários quanto nas mensagens de commit, e explique as mudanças em linguagem simples.

## Regras do projeto

- Tudo em texto. Prefira criar nós em código (como em `scripts/main.gd`) a escrever cenas `.tscn` complexas à mão.
- GDScript com tipos estáticos e `class_name` por sistema. Valores de ajuste como `@export` no topo do script.
- Desempenho de celular em primeiro lugar: muitos objetos iguais (inimigos, projéteis, orbes) usam arrays + `MultiMesh`, nunca um nó por objeto. Sem sombras em tempo real; use `BlobShadow`.
- O jogo roda no navegador (exportação Web sem threads). Não use recursos que exijam threads nem C#.
- Commite os arquivos `.uid` e `.import` gerados pelo Godot. Não commite `.godot/` nem `build/`.

## Antes de cada commit

```bash
godot --headless --path . --import
godot --headless --path . --fixed-fps 60 --script res://tests/smoke_test.gd   # precisa terminar com "SMOKE TEST: OK"
```

Ao criar um sistema novo, acrescente uma verificação dele em `tests/smoke_test.gd`. O mesmo teste roda no GitHub Actions antes de publicar.

## Publicação

Cada push no `main` roda `.github/workflows/web.yml`: importa, testa, exporta e publica em https://ederkm40.github.io/Cronicas-de-Eudora/
