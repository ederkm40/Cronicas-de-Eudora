---
titulo: Eventos e feedback de combate
resumo: Eventos temporários, elites e retorno audiovisual introduzidos na versão 0.4-alpha.
ordem: 35
---
A versão 0.4-alpha introduz eventos temporários que alteram o ritmo da partida. As novas mecânicas de gameplay estão integradas, mas permanecem experimentais no eixo de design (PROPOSTO_NAO_APROVADO) até decisão do proprietário.

## Eventos

| Evento | Quando | Efeito |
|---|---|---|
| Elite | Aos 2:00 e depois a cada 1:15 | Um inimigo de elite aparece na borda da tela. |
| Fenda do Eco | Aos 2:30 e depois a cada 2:45 | Uma área roxa surge perto do jogador. Permanecer dentro por 6 s acumulados em até 25 s concede uma escolha extra de level-up e 20% de vida. Enquanto o jogador está dentro, as hordas dobram. |
| Maré da horda | Aos 4:00 e depois a cada 3:00 | Durante 15 s, as hordas avançam 2,5 vezes mais rápido. |
| Calmaria | Depois da Maré | Durante 10 s, a intensidade de geração das hordas cai para 25%. |

Os eventos param quando começa o encontro final com a Sentinela do Eco.

**Limite de balanceamento:** o piloto automático usado nas simulações não entra na Fenda do Eco. Portanto, o valor real da recompensa e o risco de permanecer na área ainda não foram medidos por um jogador.

## Feedback audiovisual

A 0.4-alpha acrescenta 12 efeitos sonoros gerados pelo próprio código, sem arquivos de áudio externos. No navegador, o som só começa depois do primeiro toque, conforme a política de ativação de áudio do navegador.

Outros retornos:

- Estouro colorido no chão a cada abate, com limite de efeitos por quadro.
- Números de dano somente nos golpes contra chefes e elites.
- Tremor de câmera em explosões, dano forte e momentos do chefe.
- Som, tremor e números de dano podem ser desligados no menu de pausa.

**Limite conhecido:** os sons são provisórios e foram verificados tecnicamente, mas não foram ouvidos nem avaliados por uma pessoa. Os efeitos não representam ainda uma identidade audiovisual final.
