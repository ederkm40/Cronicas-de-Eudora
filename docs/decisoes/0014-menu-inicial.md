# 0014: Menu inicial como cena própria, escolha passada por RunSetup e um só "voltar"

| | |
|---|---|
| **Situação** | Aceita |
| **Data** | 27/11/2026 |

## Contexto

O proprietário aprovou a Parte 1 do menu inicial (etapa 0.5-alpha): tela inicial, Personagens, Missões, Loja e Configurações, "voltar" em todas as telas (inclusive o do celular), o mesmo painel de configurações na pausa e no menu, e uma escolha (personagem e missão) entregue à partida. As partes 2 e 3 vão trazer catálogos de personagens e missões, então a forma de passar a escolha precisa aguentar isso sem mudar de novo.

## Decisão

1. **Cena própria para o menu** (`scenes/menu.tscn`, `MainMenu`), que vira a cena inicial. A partida (`main.tscn`) continua sendo aberta e fechada inteira: ir ao menu é `change_scene_to_file`, e "Jogar de novo" continua sendo `reload_current_scene`. Assim nada da partida sobrevive no menu, como já era entre partidas.
2. **A escolha passa por `RunSetup.current`** (uma variável `static`), lida pela partida com `RunSetup.take()`. Não precisa de autoload nem de mudar o save. Se a partida for aberta direto (testes), `take()` devolve a escolha padrão, e os testes antigos continuam valendo.
3. **Componentes compartilhados** em vez de cópias: `SettingsPanel` (pausa e menu), `ShopPanel` (menu e resultados) e `UiStyle` (visual dos botões). As duas telas de configurações leem e gravam o mesmo `GameSettings`.
4. **Um só sinal de "voltar"** (`BackNavigation`): Esc, o voltar do Android (`NOTIFICATION_WM_GO_BACK_REQUEST`) e o voltar do navegador (entrada extra no histórico + `popstate`). No navegador, sem isso, o voltar do celular saía da página do jogo.

## Alternativas consideradas

- **Menu por cima da partida, na mesma cena:** a partida teria de existir parada atrás do menu (memória, inimigos, sons) e ser reiniciada a cada JOGAR. Descartado.
- **Autoload para a escolha:** funciona, mas acrescenta um nó global para um único valor. A variável `static` faz o mesmo. Pode virar autoload se o estado entre cenas crescer.
- **Salvar a escolha no `progresso.json` já na Parte 1:** mudaria o formato do save (versão e migração) sem necessidade. Fica para a Parte 2, quando houver personagens a liberar.
- **Tema global do Godot (`Theme`):** mudaria também os cartões do level-up, que têm estilo próprio. Os botões recebem o estilo um a um (`UiStyle.button` / `style_button`).

## Consequências

- O jogo abre no menu. Um toque a mais antes de jogar.
- No navegador, o voltar só é interceptado depois do primeiro toque na página (regra do Chrome para entradas de histórico).
- Os testes do Playwright abrem a partida pelo botão JOGAR; a ponte de QA também descreve o menu.
- Novos personagens e missões vão entrar como dados num catálogo e chegar à partida pelo mesmo `RunSetup`.
