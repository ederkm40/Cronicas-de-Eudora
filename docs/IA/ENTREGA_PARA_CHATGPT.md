# Entrega para o ChatGPT

*Pacote de fatos técnicos da última entrega do Claude Code. Use para revisar a Wiki (`wiki-src/`) e o `docs/CHANGELOG.md`. Não é um artigo: são dados. O Claude Code **não** alterou o changelog nem a Wiki nesta etapa. Os pacotes anteriores (0.4-alpha e manutenção pós-0.4) continuam no histórico do git e nos relatórios em `docs/versoes/`.*

## Identificação

| | |
|---|---|
| **Etapa** | 0.5-alpha, Parte 1 de 4: menu inicial |
| **Versão do jogo** | continua **0.4-alpha** até o merge. A 0.5-alpha será fechada nas próximas partes |
| **Branch** | `claude/bold-clarke-aixtws` (a partir do `main` `baea23d`) |
| **Pull Request** | https://github.com/ederkm40/Cronicas-de-Eudora/pull/14 |
| **Prévia** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-14/ |
| **Relatório** | `docs/versoes/0.5-alpha-parte-1/RELATORIO.md` (com capturas de tela) |

**Importante:** nada foi testado em celular físico. O PR #13 (Wiki da manutenção pós-0.4) continua valendo; esta entrega não o altera.

## Fatos para a Wiki (só depois do merge)

### Menu inicial (página nova sugerida, por exemplo `interface/menu-inicial` ou dentro de `controles/`)

- O jogo agora **abre num menu**, e não mais direto na partida.
- **Tela inicial:** título "Crônicas de Eudora", contador de Ecos, botão **JOGAR** (grande, dourado, brilhando devagar) e, embaixo, quatro botões: **Personagens**, **Missões**, **Loja** e **Configurações**. Uma linha mostra a escolha atual: "Personagem padrão · Partida padrão".
- **Personagens:** mostra só o personagem atual ("Personagem padrão"): vida 100, velocidade 5,0 m/s, arma inicial Raio arcano, esquiva por duplo toque no joystick. Aviso: "Mais opções chegam nas próximas etapas do menu." Use `{PLANEJADO}` para novos personagens.
- **Missões:** mostra só a missão atual ("Partida padrão"): sobreviver às hordas; aos 10:00 surge a Sentinela do Eco; vitória ao derrotá-la. O mesmo aviso. Use `{PLANEJADO}` para novas missões.
- **Loja:** as mesmas 4 melhorias permanentes (preços e efeitos sem mudança). Continua também nos resultados.
- **Configurações:** as mesmas 7 opções da pausa (mão, joystick, tamanho, altura, som, tremor, números). Mudar no menu vale na pausa, e vice-versa.
- "Personagem padrão" e "Partida padrão" são **nomes provisórios**, sem história.

### Controles (`controles/`)

- **Voltar:** toda tela do menu tem um botão "‹ Voltar". O **voltar do celular** (navegador ou Android) e o **Esc** fazem o mesmo.
- **Antes, o voltar do navegador do celular saía da página do jogo.** Agora:
  - no menu, volta à tela inicial;
  - na partida, abre a pausa (ou continua, se a pausa estiver aberta);
  - no level-up e nos resultados, não faz nada.
- Limitação: no navegador, o voltar só é tratado depois do primeiro toque na página.
- **Botão de pausa:** o "II" no alto da tela ficou bem visível (fundo roxo, borda clara, maior). Antes era cinza sobre o chão cinza e difícil de achar.

### Pausa e resultados

- Pausa: novo botão **Encerrar partida**. Ele pede um segundo toque ("Toque de novo para encerrar"). Encerrar termina a partida como derrota (os Ecos da partida contam) e mostra os resultados com o título "Partida encerrada".
- Resultados: **Jogar de novo**, **Voltar ao menu** e **Loja**.

### Testes (`desenvolvimento/testes.md`)

- **Godot:** 86 testes em 7 suítes (antes, 73). Suíte nova `menu.gd`, com 13 testes.
- **Smoke test:** agora começa pelo menu e toca em JOGAR.
- **Playwright:** arquivo novo `menu.spec.js`, com 3 testes nos 3 perfis:
  - navegação por toque e voltar do navegador sem sair da página;
  - configuração e compra no menu valendo na partida, encerrar e voltar ao menu;
  - voltar do navegador pausando a partida.
- Todos os testes antigos de jogabilidade agora abrem a partida tocando em JOGAR.

### Problemas conhecidos (`desenvolvimento/problemas-conhecidos.md`)

- **Novo:** o voltar do navegador só é tratado depois do primeiro toque na página.
- **Novo:** Personagens e Missões ainda não têm escolha (Partes 2 e 3).
- **Sai da lista**, se estiver lá: "botão de pausa difícil de ver".

## Para o changelog (sugestão)

- **Adicionado:**
  - menu inicial com JOGAR, Personagens, Missões, Loja e Configurações;
  - Voltar em todas as telas;
  - Encerrar partida na pausa;
  - Voltar ao menu nos resultados.
- **Alterado:**
  - o jogo abre no menu;
  - o voltar do celular não sai mais do jogo;
  - o botão de pausa ficou visível;
  - os botões das telas ganharam fundo e borda.
- **Técnico:**
  - decisão 0014;
  - `RunSetup` leva a escolha à partida;
  - painéis de configurações e loja compartilhados.

## Documento Mestre

- Versão 0.1.3, seção 27.1:
  - menu principal, loja e configurações no menu: `APROVADO` · `IMPLEMENTADO (PR #14)` · `TESTADO`;
  - seleção de personagem e missão: `IMPLEMENTADO_PARCIALMENTE` (só a opção atual);
  - perfil: `APROVADO` (plano), `NÃO_IMPLEMENTADO`.
