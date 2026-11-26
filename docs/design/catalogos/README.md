# Catálogos Mestres

Índice dos 30 catálogos do [Documento Mestre de Sistemas](../DOCUMENTO_MESTRE_SISTEMAS.md). Cada entrada segue o [modelo padronizado](MODELO_ENTRADA.md).

**Estado do catálogo** (do arquivo, não do conteúdo):
- **Criado (com conteúdo real):** tem entradas comprovadas pelo código da 0.3-alpha.
- **Planejado:** a categoria existe no Documento Mestre, mas ainda não há conteúdo aprovado nem implementado. **Não tem arquivo** até haver a primeira entrada real.

| # | Catálogo | Escopo | Dependências | Estado | Localização |
|---|---|---|---|---|---|
| 1 | Personagens e classes | personagens jogáveis, classes, especializações | atributos, armas, habilidades | **Criado** (1 personagem) | [01-personagens.md](01-personagens.md) |
| 2 | Atributos | atributos do jogador e dos inimigos, fórmulas, ordem de aplicação | — | **Criado** | [02-atributos.md](02-atributos.md) |
| 3 | Armas | armas, níveis, sinergias | atributos, combate, inimigos, ofertas | **Criado** (3 armas) | [03-armas.md](03-armas.md) |
| 4 | Habilidades e poderes | ativas, passivas, supremas, modificadores | atributos, estados, controles | Planejado | `04-habilidades.md` |
| 5 | Passivos | melhorias da partida | atributos, armas | **Criado** (6 melhorias) | [05-passivos.md](05-passivos.md) |
| 6 | Equipamentos | espaços, afixos, raridades | atributos, inventário, economia | Planejado | `06-equipamentos.md` |
| 7 | Amuletos e anéis | acessórios e seus efeitos | equipamentos | Planejado | `07-amuletos-e-aneis.md` |
| 8 | Relíquias | itens que mudam regras | efeitos globais, modificadores | Planejado | `08-reliquias.md` |
| 9 | Runas e catalisadores | inserção, conjuntos, evolução de armas | armas, habilidades, elementos | Planejado | `09-runas-e-catalisadores.md` |
| 10 | Evoluções | transformações de armas e habilidades | armas, passivos, catalisadores | Planejado | `10-evolucoes.md` |
| 11 | Sinergias | combinações entre sistemas | armas, passivos, elementos | Planejado (as sinergias atuais estão nos catálogos 3 e 5) | `11-sinergias.md` |
| 12 | Inimigos | tipos, comportamentos, atributos, entrada | combate, progressão | **Criado** (5 tipos) | [12-inimigos.md](12-inimigos.md) |
| 13 | Elites | modificadores de inimigos | inimigos, estados | Planejado | `13-elites.md` |
| 14 | Chefes | chefes e minibosses | inimigos, ataques, recompensas | **Criado** (1 chefe) | [14-chefes.md](14-chefes.md) |
| 15 | Estágios e regiões | mapas, biomas, modificadores | inimigos, eventos, progressão | Planejado (o chão de grade está no catálogo 30 e no Documento Mestre, seção 15) | `15-estagios-e-regioes.md` |
| 16 | Eventos | eventos dinâmicos da partida | estágios, inimigos, recompensas | Planejado | `16-eventos.md` |
| 17 | Missões | missões e objetivos | eventos, progresso, recompensas | Planejado | `17-missoes.md` |
| 18 | Captadores | coletáveis da partida | drops, coleta | **Criado** (orbe de XP) | [18-captadores.md](18-captadores.md) |
| 19 | Baús e recompensas | baús, tabelas de drop | captadores, economia | Planejado | `19-baus-e-recompensas.md` |
| 20 | Coleções | registro do que o jogador encontrou | persistência, IDs | Planejado | `20-colecoes.md` |
| 21 | Bestiário | fichas de inimigos descobertos | inimigos, persistência | Planejado | `21-bestiario.md` |
| 22 | Codex e lore | história, regiões, criaturas | narrativa | Planejado | `22-codex-e-lore.md` |
| 23 | NPCs | personagens não jogáveis | narrativa, economia, missões | Planejado | `23-npcs.md` |
| 24 | Facções | grupos, reputação | NPCs, missões | Planejado | `24-faccoes.md` |
| 25 | Conquistas | objetivos de longo prazo | persistência | Planejado | `25-conquistas.md` |
| 26 | Recursos e economia | recursos, origem e destino | progressão permanente | **Criado** (Ecos) | [26-recursos-e-economia.md](26-recursos-e-economia.md) |
| 27 | Receitas e fabricação | receitas, componentes | recursos, inventário | Planejado | `27-receitas-e-fabricacao.md` |
| 28 | Modificadores de dificuldade | dificuldades e modificadores | inimigos, estágios | Planejado | `28-modificadores-de-dificuldade.md` |
| 29 | Efeitos visuais e sonoros | identidade sensorial | armas, inimigos, interface | Planejado (os efeitos provisórios estão descritos nos catálogos 3, 12 e 14) | `29-efeitos-visuais-e-sonoros.md` |
| 30 | Testes e balanceamento | testes, simulações, números medidos | todos | **Criado** | [30-testes-e-balanceamento.md](30-testes-e-balanceamento.md) |

Regra: não criar entradas fictícias para preencher um catálogo planejado. A primeira entrada de um catálogo planejado nasce como `PROPOSTO_NAO_APROVADO` e só depois de uma regra de categoria aprovada.
