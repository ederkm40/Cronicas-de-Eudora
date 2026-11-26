# 0012: Gameplay da 0.4: estados em arrays, diretor de eventos, configurações próprias e som gerado no código

| | |
|---|---|
| **Situação** | Aceita (técnica). As mecânicas que ela sustenta continuam propostas experimentais até o proprietário aprovar o PR #10 |
| **Data** | 26/11/2026 |

## Contexto

A etapa 3 ("O Despertar de Eudora") pediu evoluções de armas, estados de combate, elites, inimigos novos, mecânicas de chefe, eventos, configurações mobile (destro/canhoto, joystick) e som. Era preciso fazer isso sem custo, sem arquivos ou serviços externos no jogo publicado e mantendo 300 inimigos rodando no navegador sem threads.

## Decisão

1. **Estados de combate em arrays paralelos do `EnemyManager`:** `_burn`, `_burn_dps`, `_slow`, `_knock`, `_shielded`, `_elite`. Eles são trocados com o último na remoção, como as outras colunas. Nenhum nó por inimigo e nenhum dicionário por inimigo. O escudo do Tecelão é recalculado uma vez por quadro, contra a lista de Tecelões (que costuma ter 0 a 3 entradas).
2. **Um ponto de entrada para o dano** (`_hurt`), com uma ordem fixa: armadura → escudo → chefe exposto → estatísticas → morte. Sinais `important_hit` e `elite_killed` para quem precisa reagir (números, som, recompensa).
3. **Evoluções como dados** (`WeaponCatalog.EVOLUTIONS`) e estado no `Arsenal` (`_evolved`). Elas entram no sorteio do `LevelUpOffers` como mais um tipo de oferta, com o mesmo caminho de troca e bloqueio.
4. **Diretor de eventos separado** (`EventDirector`). Ele só controla o *ritmo* das hordas (`spawn_rate_multiplier`) e cria elites e fendas. Não começa eventos quando `spawning_enabled` está desligado (testes controlados) nem depois de `stop()` (encontro final).
5. **Configurações em arquivo próprio** (`user://configuracoes.json`, `GameSettings`), separado do progresso. Se o arquivo de configurações quebrar, o progresso não é afetado, e vice-versa. O arquivo tem versão, é gravado num temporário e depois renomeado, e um arquivo quebrado vira cópia `.corrompido`, como o save.
6. **Som sintetizado no código** (`SoundBank`): `AudioStreamWAV` gerados no `_ready()` a partir de funções simples. São 12 sons e 10 vozes, com intervalo mínimo por som. Não há arquivos de áudio, plugins nem serviços. É possível trocar por arquivos `.wav`/`.ogg` mais tarde sem mudar quem chama `play()`.
7. **"Game feel" num só lugar** (`GameFeel`): conecta sinais a som, tremor, números e estouros. As regras de jogo não dependem dele.

## Alternativas consideradas

- **Estados como nós ou `Dictionary` por inimigo:** custo de memória e de processamento com 300 inimigos. Descartado.
- **Arquivos de som gravados ou baixados:** exigiriam licenças e cuidado com a origem. Um gerador procedural atende o protótipo sem custo e sem risco de direitos autorais. Fica para a fase 2, com arte e som finais.
- **Configurações dentro do `progresso.json`:** misturaria dados de jogo com preferências e aumentaria o risco de perder o progresso numa mudança de formato. Descartado.
- **Eventos dentro do `EnemyManager`:** o arquivo já está perto dos limites do `gdlint` (1.000 linhas, 20 métodos públicos). Descartado.

## Consequências

- `EnemyManager` tem 890 linhas e 20 métodos públicos (o limite). Um próximo sistema de inimigos precisa de uma classe auxiliar.
- O piloto automático derrota o chefe com mais facilidade (janela de vulnerabilidade). O equilíbrio do chefe é o primeiro número a revisar com pessoas.
- Elites, maré e fenda mudam o ritmo da partida: as simulações da 0.3 não são mais comparáveis uma a uma. O relatório da 0.4 traz medições novas.
