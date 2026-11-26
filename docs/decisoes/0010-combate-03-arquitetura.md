# 0010: Arquitetura do combate 0.3 (armas, inimigos, chefe, esquiva, resultados e progresso)

| | |
|---|---|
| **Situação** | Aceita |
| **Data** | 26/11/2026 |

## Contexto

A versão 0.3-alpha acrescenta duas armas, ofertas de armas no level-up com troca e bloqueio, quatro tipos de inimigo, um chefe aos 10 minutos, esquiva, vitória com tela de resultados e a primeira progressão entre partidas. Tudo precisa caber na arquitetura de arrays + MultiMesh (decisão 0003), rodar na Web sem threads e continuar testável no Godot sem tela.

## Decisão

1. **Armas em três camadas, sem hierarquia de classes:** `WeaponCatalog` (definição, só dados, atributos completos por nível), `Arsenal` (estado: quais armas e em que nível, um espaço por arma) e um nó por arma para execução e visual (`AutoWeapon`, `AuraWeapon`, `OrbitBlades`). Colisão e dano ficam no `EnemyManager` (`hit_at`, `indices_in_radius`, `damage(índice, dano, arma)`). Uma arma nova = uma definição + um nó + uma linha em `Main._sync_weapons()`. Não criamos uma classe base de arma: as três armas atacam de jeitos diferentes demais para dividir código útil, e uma abstração agora só adicionaria indireção.
2. **Ofertas do level-up num objeto próprio (`LevelUpOffers`):** valida, sorteia com pesos, troca e bloqueia. As melhorias passivas continuam em `Upgrades` (recalculadas, decisão 0005). Ids de armas e de melhorias são diferentes, então a tela continua recebendo uma lista de `StringName`.
3. **Todos os inimigos, inclusive o chefe, no mesmo `EnemyManager`,** com um array de tipo e um `MultiMesh` por tipo. O comportamento por tipo fica num `match` em `_move()`. Memória por inimigo (recarga da lâmina, pavio, aviso no chão) fica em arrays paralelos que se movem juntos na remoção; nenhum sistema guarda índices entre quadros. O índice do chefe é mantido na remoção.
4. **O chefe é um corpo no `EnemyManager` + uma máquina de estados (`BossController`).** Assim as três armas acertam o chefe sem código especial, e a lógica dos ataques fica separada. O Raio mira o chefe quando ele está ao alcance.
5. **Avisos e impactos no chão num gerenciador só (`GroundEffects`),** com arrays e 3 `MultiMesh` (disco, anel e faixa), limite de 160 e id para cancelar o aviso quando o inimigo morre.
6. **Esquiva por gesto no próprio joystick:** duplo toque curto e próximo; a direção sai do arrasto do segundo toque ou do movimento atual. Tempos medidos pelo relógio do jogo. No computador, Espaço.
7. **Estatísticas só do que é contado (`RunStats`):** o dano registrado é a vida realmente tirada. A tela de resultados não mostra nada que não esteja em `RunStats`, no `Arsenal` ou em `Upgrades`.
8. **Progressão permanente em JSON versionado (`MetaProgress`, `user://progresso.json`):** escrita atômica (temporário + renomear), migração por versão, proteção contra arquivo de versão futura e contra arquivo corrompido. Conteúdo enxuto: um recurso (Ecos) e quatro melhorias numéricas, sem desbloqueios.
9. **Ponte de testes para o navegador (`WebBridge`) só com `?teste=1`:** expõe o estado e a posição dos botões, e aceita comandos só para preparar situações. Os testes de navegador tocam nos botões e fazem os gestos de verdade.
10. **Testes do Godot em suítes** (`tests/suites/`), cada uma abaixo dos limites do `gdlint` (20 métodos públicos, 1.000 linhas), em vez de desligar regras.

## Alternativas consideradas

- **Um nó por inimigo ou por projétil inimigo:** descartado pela decisão 0003 (300 inimigos no celular).
- **Classe base `Weapon` com herança:** adiada até existir uma quarta arma que repita um padrão.
- **Chefe como nó separado, fora do `EnemyManager`:** exigiria que cada arma tratasse o chefe à parte.
- **Botão de esquiva:** recusado pela direção do projeto (controle com um dedo).
- **ConfigFile ou recurso do Godot para o save:** JSON é legível, fácil de migrar e de inspecionar pelo proprietário.

## Consequências

- O `EnemyManager` concentra muitos comportamentos. Se crescer muito (mais tipos ou chefes), os comportamentos podem ir para funções estáticas por tipo, mantendo os arrays.
- A ponte de testes fica no jogo publicado, mas inativa sem `?teste=1`. Ela permite preparar situações (como dar XP) para quem abrir a página com esse parâmetro; não há placar nem dado online que isso afete.
- O formato do save passa a ser um contrato: mudanças futuras precisam de migração e teste.
