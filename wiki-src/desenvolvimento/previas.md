---
titulo: Prévias jogáveis
resumo: Como testar o jogo e a Wiki de uma etapa antes de ela virar oficial.
ordem: 80
---
Cada **Pull Request** (proposta de mudança) ganha uma **prévia**: uma cópia jogável do jogo e da Wiki com as mudanças propostas, publicada à parte, **sem substituir a versão oficial**.

| O quê | Endereço |
|---|---|
| Jogo oficial | https://ederkm40.github.io/Cronicas-de-Eudora/ |
| Wiki oficial | https://ederkm40.github.io/Cronicas-de-Eudora/wiki/ |
| Jogo em prévia | `https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-<número>/` |
| Wiki em prévia | `https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-<número>/wiki/` |
| Lista de prévias abertas | https://ederkm40.github.io/Cronicas-de-Eudora/previews/ |

## Como funciona

1. Um Pull Request é aberto ou recebe um novo envio.
2. O GitHub roda os testes. Se passarem, exporta o jogo, gera a Wiki e publica a prévia.
3. O endereço da prévia aparece num comentário automático no Pull Request, junto com o resultado da verificação.
4. Quando o Pull Request é integrado (merge) ou fechado, a prévia é apagada. Se foi integrado, o jogo e a Wiki oficiais são atualizados.

A Wiki da prévia mostra uma faixa amarela de aviso, com o número do Pull Request e o commit, para não ser confundida com a oficial.

Prévias só são criadas para Pull Requests feitos dentro do próprio repositório. Propostas vindas de cópias externas (forks) são testadas, mas não publicadas, por segurança.
