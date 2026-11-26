# Roadmap

O plano segue as fases do documento de criação: conceito → protótipo → vertical slice → produção → testes → lançamento. Estamos na **fase 1, protótipo**. A pergunta desta fase é uma só: sobreviver e ficar mais forte, com joystick no celular, é divertido?

## Feito

### 0.1-alpha: projeto base
- Projeto Godot 4.7 em texto puro, com publicação automática no GitHub Pages.
- Câmera isométrica em retrato, joystick flutuante, WASD e setas.
- Arma automática e hordas crescentes de até 300 inimigos com MultiMesh.
- HUD, derrota e reinício. Smoke test no workflow.

### 0.2-alpha: Ecos da Evolução
- Orbes de experiência com coleta por proximidade (ímã) e barra de XP no HUD.
- Curva de experiência crescente e vários níveis na mesma partida.
- Level-up com pausa total e 3 melhorias distintas, em cartões grandes para o polegar.
- 6 melhorias com acúmulo e limites.
- 16 testes específicos, smoke test de ponta a ponta e simulação prolongada.
- Workflow valida Pull Requests sem publicar.

## Próximas etapas (fase 1, protótipo)

| Etapa | Objetivo | Principais entregas |
| --- | --- | --- |
| 0.3-alpha | Variedade de combate | 2 armas novas (aura de dano, lâmina giratória) que ocupam espaços próprios; melhorias que podem trazer arma nova |
| 0.4-alpha | Variedade de inimigos | 4 tipos além do comum (rápido, tanque, atirador, explosivo) e mini-chefe aos 10 minutos |
| 0.5-alpha | Habilidade ativa | Botão de esquiva com recarga, sem atrapalhar o joystick |
| 0.6-alpha | Fim de partida | Vitória aos 10 minutos, resumo da partida e equilíbrio a partir de testes com pessoas |

Critério de saída da fase 1: 5 a 10 pessoas jogam no celular e pedem para jogar de novo.

## Depois do protótipo (fase 2, vertical slice)

- Loot que muda regras (itens com efeitos especiais), cidade simples e progressão permanente entre partidas.
- 1 classe completa, 1 fase com arte e som finais, 1 chefe.
- Exportação Android (APK) além da web.

## Pendências registradas

- Testar em celular físico e anotar o FPS com a horda cheia.
- Ajustar o equilíbrio: dano base, ritmo das hordas e curva de XP.
- Decidir o que fazer com orbes muito distantes (sumir, fundir ou puxar de longe).
