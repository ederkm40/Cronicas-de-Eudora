---
titulo: Painel de desenvolvimento
resumo: Etapas integradas, histórico de prompts, versões, roadmap, testes e relatórios do projeto.
---
Esta área acompanha o desenvolvimento. A enciclopédia descreve o que existe no jogo; este painel registra as etapas, decisões, solicitações de desenvolvimento e próximas validações.

## Agora

| | |
|---|---|
| **Versão oficial** | 0.4-alpha — O Despertar de Eudora {PUBLICADO} |
| **Branch principal** | main |
| **Última integração técnica** | PR #10, **ETAPA 3: O DESPERTAR DE EUDORA**, em 26/11/2026 |
| **Última integração documental** | PR #8, atualização editorial pós-PR #7; esta atualização registra a 0.4-alpha |
| **Fase** | 1, protótipo |
| **Próxima prioridade** | Continuar a expansão de sistemas e conteúdo antes da validação externa, adiada pelo proprietário |

## Etapas integradas

Esta é a linha do tempo oficial das entregas que chegaram à branch main. Manutenção e documentação não são contadas como novas versões de gameplay.

| Etapa | Entrega | Integração | Estado |
|---|---|---|---|
| 0.1-alpha | Projeto base: controles, câmera, arma automática e hordas | Commit inicial | {PUBLICADO} |
| 0.2-alpha — Ecos da Evolução | Experiência, orbes, level-up e seis melhorias | PR #1 | {PUBLICADO} |
| Infraestrutura da Wiki | Wiki pública, prévias por PR e ferramentas de QA | PR #6 | {PUBLICADO} |
| 0.3-alpha — Grande expansão do combate | Novas armas, ofertas, inimigos, Sentinela do Eco, esquiva, resultados e Ecos | PR #5 | {PUBLICADO} |
| **ETAPA INTEGRADA: MANUTENÇÃO PÓS-0.3-ALPHA + DOCUMENTO MESTRE DE SISTEMAS** | Separação das builds de produção e QA, robustez do save, retomada do joystick, limpeza técnica e Documento Mestre | **PR #7 · 26/11/2026** | {PUBLICADO} |
| Documentação pós-PR #7 | Atualização editorial da Wiki e do changelog | PR #8 · 26/11/2026 | {PUBLICADO} |
| Arquivo histórico de prompts | Organização cronológica das solicitações de desenvolvimento | PR #9 · 26/11/2026 | {PUBLICADO} |
| **ETAPA 3 — O Despertar de Eudora (0.4-alpha)** | Personalização mobile, impacto audiovisual, evoluções, Pacto do Eco, novos inimigos, elites, eventos e melhorias no chefe | **PR #10 · merge f51db236 · 26/11/2026** | {PUBLICADO} |

## O que chegou com a 0.4-alpha

- Pausa no celular e configurações persistentes: destro/canhoto, joystick fixo ou flutuante, tamanho, altura, som, tremor e números de dano.
- Três evoluções de armas e uma melhoria de risco/recompensa.
- Estados de combate, dois novos tipos de inimigos e três modificadores de elite.
- Eventos de partida: elites periódicos, Fenda do Eco, Maré e Calmaria.
- Novo ataque da Sentinela do Eco e janela de vulnerabilidade após a investida.
- Som procedural, estouros nos abates, números de dano seletivos e tremor de câmera.

As novas mecânicas de gameplay da 0.4 continuam **experimentais no eixo de design**: foram integradas ao jogo, mas ainda não foram aprovadas individualmente pelo proprietário. A personalização mobile já era uma diretriz aprovada.

Relatório técnico: [0.4-alpha — O Despertar de Eudora](https://github.com/ederkm40/Cronicas-de-Eudora/blob/main/docs/versoes/0.4-alpha/RELATORIO.md).  
Registro editorial: [[desenvolvimento/changelog]].

## Validação futura

A validação com 5 a 10 pessoas em celulares físicos continua sendo o critério para sair da fase de protótipo, mas foi **adiada pelo proprietário** para depois de mais evolução do jogo. Os testes automatizados não equivalem a essa validação.

## Histórico de prompts utilizados

O arquivo [[desenvolvimento/prompts|Arquivo histórico de prompts]] reúne os pedidos de desenvolvimento por etapa, incluindo objetivo, escopo, restrições, critérios e situação do texto original.

**Regra daqui em diante:** cada nova etapa deve registrar os prompts completos, na ordem em que foram enviados, sem resumir nem reescrever o texto original. Quando um prompt antigo não puder ser recuperado literalmente, o arquivo deve identificá-lo como resumo recuperado ou reconstrução, nunca como transcrição exata.

## O que significa cada estado

| Estado | Significado |
|---|---|
| {PLANEJADO} | Está no plano, mas ainda não existe no jogo. |
| {EM_DESENVOLVIMENTO} | Está sendo construído numa branch e ainda não foi integrado. |
| {IMPLEMENTADO} | O código existe, mas não passou por toda a validação. |
| {TESTADO} | Passou pelos testes registrados, mas pode depender de teste com pessoas. |
| {PUBLICADO} | Está na versão oficial disponível para jogar. |

## Seções

- [[desenvolvimento/versoes]]: histórico de versões.
- [[desenvolvimento/roadmap]]: próximas etapas e pendências.
- [[desenvolvimento/prompts]]: arquivo histórico de prompts, etapa por etapa.
- [[desenvolvimento/funcionalidades]]: o que existe e o que está planejado.
- [[desenvolvimento/testes]]: como o jogo é testado e resultados registrados.
- [[desenvolvimento/problemas-conhecidos]]: limitações atuais.
- [[desenvolvimento/arquitetura]] e [[desenvolvimento/desempenho]]: visão técnica.
- [[desenvolvimento/previas]]: como testar versões candidatas.
- [[desenvolvimento/relatorios]] · [[desenvolvimento/changelog]] · [[desenvolvimento/eventos-da-partida]] · [[desenvolvimento/decisoes]].
