# 0001: Godot 4.7.2, GDScript, renderizador Compatibility e exportação Web sem threads

| | |
|---|---|
| **Situação** | Aceita |
| **Data** | 25/11/2026 |

## Contexto

O jogo precisa rodar no navegador do celular, ser construído quase todo por IA e não ter custo. O proprietário não usa um computador local para desenvolver.

## Decisão

- **Godot 4.7.2**, gratuito, com o projeto inteiro em arquivos de texto.
- **GDScript**. C# não exporta para a Web no Godot 4.
- **Renderizador Compatibility** (WebGL 2), o único suportado na exportação Web e o mais leve para celulares.
- **Exportação Web sem threads**, porque o GitHub Pages não envia os cabeçalhos que o `SharedArrayBuffer` exige.
- A versão do Godot fica fixada em `GODOT_VERSION` no workflow.

## Consequências

Não usar recursos que exijam threads ou C#. Trocar a versão do Godot exige atualizar o workflow e rodar todos os testes.
