# 0008: Duas IAs com papéis separados e o GitHub como fonte de verdade

| | |
|---|---|
| **Situação** | Aceita |
| **Data** | 26/11/2026 |

## Contexto

O proprietário usa o Claude Code para desenvolver e o ChatGPT para acompanhar e documentar. O conhecimento não pode depender da memória de nenhuma das duas.

## Decisão

- **Claude Code:** código, testes, builds, documentação técnica essencial, relatórios e `docs/IA/ENTREGA_PARA_CHATGPT.md`.
- **ChatGPT:** Wiki (`wiki-src/*.md`), changelog editorial, revisão de relatórios e organização do histórico.
- Cada um edita seus próprios arquivos (tabela em `AGENTS.md`), o que evita conflitos.
- O ChatGPT não monitora o repositório: o proprietário leva até ele o link do Pull Request.
- Tudo fica no repositório. `AGENTS.md` vale para qualquer IA; `CLAUDE.md` só complementa.

## Consequências

Toda entrega do Claude Code atualiza `ENTREGA_PARA_CHATGPT.md` e o relatório da versão. Commits do ChatGPT na branch do PR atualizam a prévia automaticamente.
