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

### Infraestrutura: Wiki, prévias e memória
- Wiki pública em `/wiki/`, gerada a partir de `wiki-src/`, com 12 categorias e painel de desenvolvimento.
- Prévia jogável e Wiki candidata para cada Pull Request, em `/previews/pr-N/`.
- Memória permanente: `AGENTS.md`, `docs/IA/`, relatórios por versão, decisões técnicas e changelog.
- Divisão de papéis: Claude Code desenvolve, ChatGPT documenta.

### Infraestrutura: ferramentas de QA (PR #4)
- GDScript Toolkit no CI e testes de navegador (Playwright) em 3 perfis.

### 0.3-alpha: grande expansão do combate (integrada pelo PR #5)
Entregue o escopo da 0.3 e antecipadas partes da 0.4, 0.5 e 0.6 (detalhes em `docs/versoes/0.3-alpha/RELATORIO.md`):
- **0.3 (completo):** Aura de brasas e Lâmina orbital em espaços próprios, com 5 níveis; level-up oferece armas novas, evoluções e melhorias; troca de opções e bloqueio.
- **0.4 (antecipado):** os 4 tipos de inimigo (Espreitador, Couraçado, Lançador, Volátil) com comportamentos próprios e entrada gradual; chefe aos 10 minutos (Sentinela do Eco) com 3 ataques avisados e 2 fases.
- **0.5 (antecipado em parte):** esquiva com recarga por **duplo toque no joystick** (sem botão) e Espaço no computador. Pendente: opções de destro/canhoto e ajuste do joystick.
- **0.6 (antecipado em parte):** a vitória passou a ser **derrotar o chefe** do encontro dos 10 minutos (não mais sobreviver até os 10 minutos); tela de resultados com estatísticas reais; reinício limpo. Pendente: equilíbrio a partir de testes com pessoas.
- **Fase 2 (antecipado em parte):** primeira camada de progressão entre partidas (Ecos e 4 melhorias permanentes, salvas no navegador).

## Próximas etapas (fase 1, protótipo)

| Etapa | Objetivo | Situação |
| --- | --- | --- |
| 0.4-alpha | Variedade de inimigos e mini-chefe | **implementado na 0.3** (testado nos testes automáticos e em simulação; falta teste com pessoas) |
| 0.5-alpha | Habilidade ativa | esquiva **implementada na 0.3**; destro/canhoto e ajuste do joystick **em revisão no PR #10** |
| 0.6-alpha | Fim de partida | vitória e resumo **implementados na 0.3**; **pendente:** equilíbrio com testes de pessoas |
| Etapa 3 "O Despertar de Eudora" (0.4-alpha) | Evolução do núcleo de jogo: evoluções, elites, eventos, chefe, configurações mobile, som | **em revisão no PR #10** (testes automáticos e simulação; sem teste com pessoas). As mecânicas novas são propostas experimentais até o proprietário aprovar |
| Próxima proposta (a aprovar) | Teste com pessoas e ajustes | 5 a 10 pessoas no celular; ajustar equilíbrio, legibilidade e controles a partir do que elas relatarem |

Critério de saída da fase 1: 5 a 10 pessoas jogam no celular e pedem para jogar de novo.

## Depois do protótipo (fase 2, vertical slice)

- Loot que muda regras (itens com efeitos especiais), cidade simples e progressão permanente entre partidas (a primeira camada, só com Ecos e 4 melhorias numéricas, já entrou na 0.3).
- 1 classe completa, 1 fase com arte e som finais, 1 chefe.
- Exportação Android (APK) além da web.

## Pendências registradas

- Testar em celular físico e anotar o FPS com a horda cheia.
- Ajustar o equilíbrio com pessoas (a 0.3 ajustou com simulações: ver o relatório).
- Decidir o que fazer com orbes muito distantes (sumir, fundir ou puxar de longe).
