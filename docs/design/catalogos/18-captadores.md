# Catálogo 18: Captadores

### Orbe de experiência

| Campo | Valor |
|---|---|
| **ID permanente** | — (sistema único `XpOrbManager`) |
| **Categoria** | coletável da partida · experiência |
| **Descrição** | cristal azul-claro deixado onde o inimigo morreu |
| **Função** | levar o jogador a circular pelo campo; fonte de XP |
| **Valores** | XP do tipo de inimigo (1, 1, 4, 2, 2); ímã a 3 m (começa a 4 m/s, acelera 30 m/s²); coleta a 0,6 m; limite de 400 no chão (`scripts/xp_orbs.gd`) |
| **Efeitos** | coletado, soma XP na barra; acima do limite, o valor novo vai para o orbe mais antigo (sem perda) |
| **Limitações** | não some com o tempo; orbes distantes ficam no chão (decisão pendente desde a 0.1) |
| **Sinergias** | Atração do eco (+20% de ímã por nível) |
| **Referência visual** | losango azul-claro flutuando |
| **Dependências** | `EnemyManager` (sinal de abate), `Progression` |
| **Estado de design** | `APROVADO` (0.2-alpha) |
| **Estado de implementação** | `IMPLEMENTADO` |
| **Estado de validação** | `TESTADO` (`progressao.gd`: orbe ao derrotar, coleta por proximidade) |

Outros captadores (ouro, cura, baús, captadores especiais): `PROPOSTO_NAO_APROVADO` · `NÃO_IMPLEMENTADO` — seção 17 do Documento Mestre.
