# Relatório 0.1-alpha: Projeto base

| | |
|---|---|
| **Data** | 26/11/2026 |
| **Commit** | `0dd647fea0f8de1da5307316c98c22cceaee446d` |
| **Pull Request** | nenhum (enviado direto ao `main`, antes da regra de PRs) |
| **Workflow** | execução 45782271052, sucesso (testar e publicar) |
| **Prévia** | não existia; publicado direto em https://ederkm40.github.io/Cronicas-de-Eudora/ |

*Relatório escrito retroativamente na etapa de infraestrutura, a partir do histórico do repositório e da conversa de desenvolvimento.*

## Objetivo

Criar o projeto base jogável no navegador do celular, para testar se mover e sobreviver com joystick flutuante funciona.

## Funcionalidades implementadas

- Projeto Godot 4.7.2 inteiramente em texto. A partida é montada em código (`scripts/main.gd`).
- Tela em retrato 720 × 1280 com `canvas_items` e `expand`. Renderizador Compatibility.
- Câmera isométrica ortográfica fixa: giro de 45°, inclinação de 40°, 14 m de largura visível.
- Joystick flutuante (raio 90, zona morta 12%, centro que acompanha o dedo, velocidade fixa), mais WASD e setas.
- Personagem com 100 de vida e 5 m/s, sombra de disco (`BlobShadow`).
- Arma automática no inimigo mais próximo: 10 de dano, 0,45 s, 11 m de alcance, projétil a 14 m/s por 1,2 s.
- Hordas: intervalo de 1 s caindo 0,012 s por segundo até 0,12 s; +1 inimigo por onda a cada 25 s; até 300; vida 20 +60% por minuto; 2,2 m/s ±15%; 9 de dano por segundo por contato (até 5 inimigos).
- HUD com tempo, abates, vida, FPS e inimigos; tela "Você caiu!" com "Jogar de novo".
- Chão com grade de 2 m desenhada por shader, que acompanha o jogador.
- Workflow do GitHub Actions: baixa o Godot, importa, roda o smoke test, exporta para Web e publica no GitHub Pages.

## Desempenho

- Inimigos e projéteis em `Packed*Array` + 1 `MultiMesh` por tipo.
- Separação entre inimigos com grade espacial montada por ordenação nativa, recalculada para metade dos inimigos por quadro.
- Medição local (servidor, sem renderização): cerca de 2,4 ms por quadro só para a lógica de 300 inimigos, depois da otimização. A versão inicial gastava de 5 a 10 ms.

## Testes executados

| Teste | Resultado |
|---|---|
| `tests/smoke_test.gd` (45 s simulados, toque e arraste no joystick, abates) | aprovado, localmente e no GitHub Actions |
| Exportação Web | aprovada (index.html, .js, .pck, .wasm) |
| Teste visual num Chrome com celular simulado (390 × 844, toque) | joystick, câmera, inimigos e projéteis visíveis |

## Problemas e limitações

- Não foi testado em celular físico.
- No ambiente de testes com SwiftShader (renderização por software do Chrome), as atualizações de MultiMesh não aparecem. Com o renderizador Mesa/GL apareceram corretamente. É um problema do ambiente de teste, não do jogo.
- Na tela deitada (paisagem), a interface fica pequena.
- Gráficos provisórios e jogo sem som.
