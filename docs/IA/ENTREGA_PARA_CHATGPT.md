# Entrega para o ChatGPT

*Pacote de fatos técnicos da última entrega do Claude Code. Use para revisar a Wiki (`wiki-src/`) e o `docs/CHANGELOG.md`. Não é um artigo: são dados. O Claude Code **não** alterou o changelog nem a Wiki nesta etapa.*

## Identificação

| | |
|---|---|
| **Etapa** | Manutenção pós-0.3-alpha + Documento Mestre de Sistemas |
| **Versão do jogo** | continua **0.3-alpha** (sem mudança de equilíbrio, conteúdo ou progressão) |
| **Branch** | `feat/manutencao-e-documento-mestre-03` (a partir do `main` `3d9102c`) |
| **Pull Request** | https://github.com/ederkm40/Cronicas-de-Eudora/pull/7 |
| **Prévia** | https://ederkm40.github.io/Cronicas-de-Eudora/previews/pr-7/ (só a build de produção) |
| **Relatório** | `docs/versoes/manutencao-pos-0.3/RELATORIO.md` |

## Resumo técnico da manutenção

- **Builds separadas (decisão 0011):** o jogo publicado e as prévias usam só a build de produção (preset `Web`), que **não contém** a ponte de testes. Abrir com `?teste=1` não liga mais nada. A ponte existe apenas na build `Web QA`, usada pelos testes automáticos no CI e nunca publicada.
- **Save mais robusto:** a leitura do `user://progresso.json` agora valida estrutura e tipos.
  - Estrutura inválida: o jogo guarda uma cópia `.corrompido` e começa um progresso novo.
  - Campo inválido (negativo, tipo errado, nível acima do limite): só aquele campo é corrigido e o resto é mantido.
  - Versão futura do arquivo: continua só leitura.
  - Nenhum save inválido impede o jogo de abrir.
- **Joystick:** depois do level-up, o dedo que ficou na tela volta a controlar sem precisar levantar e tocar de novo. Se o dedo foi solto durante a pausa, o joystick volta neutro. Isso não cria esquiva acidental. Testado no Godot e no Chromium emulado; **não testado em celular físico**.
- **Limpeza:** removido `scripts/main.gd.orig` (sobra de um patch).

## Para a Wiki (revisão editorial)

- `desenvolvimento/problemas-conhecidos.md`, com as linhas que **só mudam depois do merge do PR #7**:
  - "Ponte de QA na exportação Web": resolvido no PR #7.
  - "Validação do arquivo de progressão": resolvido no PR #7.
  - "Joystick depois da pausa": resolvido no PR #7, com a ressalva de não ter sido testado em celular físico.
- `controles/joystick-flutuante.md` e `progressao/level-up.md`: tirar a limitação do joystick depois do merge.
- `progressao/melhorias-permanentes.md`: descrever o comportamento novo do save (estrutura inválida × campo inválido).
- `desenvolvimento/testes.md`: 51 testes do Godot em 5 suítes; Playwright em duas builds (QA e produção).
- Continua valendo: o texto da Atração do eco no jogo diz "raio de coleta"; o efeito é no ímã.

## Documento Mestre de Sistemas

- **Local:** `docs/design/DOCUMENTO_MESTRE_SISTEMAS.md` (versão 0.1, `EM_ELABORAÇÃO`), com 38 áreas.
- **Catálogos:** `docs/design/catalogos/README.md` indexa os 30. Há 9 criados, com conteúdo comprovado pelo código: 01 Personagens, 02 Atributos, 03 Armas, 05 Passivos, 12 Inimigos, 14 Chefes, 18 Captadores, 26 Recursos e economia e 30 Testes e balanceamento. Os outros 21 estão planejados, sem entradas. O modelo de entrada está em `MODELO_ENTRADA.md`.
- **Estados independentes:**
  - design: `PROPOSTO_NAO_APROVADO`, `APROVADO`, `REJEITADO`, `SUBSTITUÍDO`;
  - implementação: `NÃO_IMPLEMENTADO`, `EM_DESENVOLVIMENTO`, `IMPLEMENTADO`, `IMPLEMENTADO_PARCIALMENTE`;
  - validação: `NÃO_TESTADO`, `TESTADO_COM_FALHAS`, `TESTADO`, `VALIDADO`.
  - **Nada está `VALIDADO`**, porque não houve teste com pessoas.
- **Decisões aprovadas registradas:**
  - tudo o que a 0.3-alpha implementou;
  - as diretrizes mobile do proprietário (um dedo, joystick flutuante, ataque automático, esquiva por duplo toque, destro/canhoto, espelhamento, preferência salva, ajuste do joystick, ações contextuais, PC). As de personalização estão aprovadas, mas **não implementadas**.
- **Propostas (`PROPOSTO_NAO_APROVADO`):** todo o resto (classes, novas armas e famílias, habilidades, equipamentos, relíquias, runas, evoluções, elites, estágios, eventos, missões, captadores especiais, baús, coleções, bestiário, economia, fabricação, NPCs, facções, lore, modos, conquistas, acessibilidade, áudio). Nenhuma foi implementada.
- **Fontes de referência** (Diablo IV, Vampire Survivors, Path of Exile 1 e 2): registradas como **não consultadas** nesta versão. O acesso às páginas pedia uma aprovação que não foi respondida na sessão.
- A Wiki **não** deve apresentar as propostas do Documento Mestre como conteúdo do jogo.
