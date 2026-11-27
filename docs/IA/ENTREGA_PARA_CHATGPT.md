# Entrega para o ChatGPT

*Pacote de fatos técnicos da última entrega do Claude Code. Use para revisar a Wiki (`wiki-src/`) e o `docs/CHANGELOG.md`. Não é um artigo: são dados. O Claude Code **não** alterou o changelog nem a Wiki nesta etapa. O pacote da 0.4-alpha continua no histórico do git e em `docs/versoes/0.4-alpha/RELATORIO.md`.*

## Identificação

| | |
|---|---|
| **Etapa** | Manutenção pós-0.4-alpha |
| **Versão do jogo** | continua **0.4-alpha** (sem mudança de equilíbrio, conteúdo ou progressão) |
| **Branch** | `claude/bold-clarke-aixtws` (a partir do `main` `7a7daf2`) |
| **Pull Request** | ver o PR desta branch |
| **Relatório** | `docs/versoes/manutencao-pos-0.4/RELATORIO.md` |

## Fatos para a Wiki (só depois do merge)

### Problemas conhecidos (`desenvolvimento/problemas-conhecidos.md`)

- **Sai da lista:** "Atração do eco: o texto ainda diz 'raio de coleta'". O texto da loja agora é **"+20% no raio do ímã dos orbes por nível."** O efeito e os preços não mudaram.
- **Atualizar:** "Organização do EnemyManager". O desenho dos inimigos foi para uma classe própria (`EnemyRenderer`). O `EnemyManager` passou de 890 para 772 linhas e de 20 para 18 métodos públicos (o limite do `gdlint` é 20). Decisão 0013.
- **Continuam:** todos os outros itens da 0.4 (celular físico, chefe possivelmente fácil, fenda não medida, som não ouvido, botão de pausa em telas com entalhe, desempenho no celular, primeiro quadro de áudio, orbes distantes, arte e áudio finais).

### Progressão (`progressao/melhorias-permanentes.md`)

- O parágrafo que diz "Na tela do jogo, a descrição da Atração do eco diz 'raio de coleta'…" pode sair. O texto do jogo agora fala do ímã. A explicação do efeito (ímã de 3 m na base; coleta final em 0,6 m, que não muda) continua correta.

### Testes (`desenvolvimento/testes.md`)

- **Godot:** 73 testes em 6 suítes (antes, 71). Novos: desenho dos inimigos por tipo e geometria da tela (`inimigos_e_chefe.gd`, agora com 8); texto e efeito da Atração do eco (`save_e_joystick.gd`, agora com 11).
- Resultado local: 73 testes, 4.624 verificações, 0 falhas; smoke e simulação longa OK.
- Desempenho: a mesma partida simulada de 300 s no `main` e na branch, com o mesmo resultado e o mesmo tempo por quadro dentro do ruído (tabela no relatório).

### Arquitetura (se a Wiki tiver página técnica)

- Novo arquivo `scripts/enemy_renderer.gd` (`EnemyRenderer`, filho do `EnemyManager`): um MultiMesh por tipo de inimigo e a forma provisória de cada tipo.
- `CameraRig.is_on_screen(ponto, centro, metade, margem)` (antes no `EnemyManager`).
- Decisão nova: `docs/decisoes/0013-enemy-manager-classes-auxiliares.md`. O Claude Code acrescentou a linha dela em `docs/decisoes/README.md`, sem mudar o resto.

## Para o changelog (sugestão)

- **Corrigido:** texto da melhoria permanente Atração do eco (agora fala do ímã dos orbes).
- **Técnico:** desenho dos inimigos separado no `EnemyRenderer` (decisão 0013), sem mudança de jogo nem de desempenho; documentação técnica e Documento Mestre atualizados para a 0.4 integrada.

## Documento Mestre

- Versão 0.1.2: os elementos da 0.4 passaram de `EM_DESENVOLVIMENTO (PR #10)` para `IMPLEMENTADO (PR #10)`. O design continua `PROPOSTO_NAO_APROVADO (experimental)` até o proprietário decidir.
- Corrigidas duas linhas desatualizadas da tabela de estruturas futuras: configurações persistentes e estados de combate estão `IMPLEMENTADO` desde a 0.4.
