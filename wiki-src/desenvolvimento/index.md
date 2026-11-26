---
titulo: Painel de desenvolvimento
resumo: Etapas integradas, histórico de prompts, versões, roadmap, testes e relatórios do projeto.
---
Esta área acompanha o desenvolvimento. A enciclopédia descreve o que existe no jogo; este painel registra as etapas, decisões, solicitações de desenvolvimento e próximas validações.

## Agora

| | |
|---|---|
| **Versão oficial** | 0.3-alpha — Grande expansão do combate {PUBLICADO} |
| **Branch principal** | `main` |
| **Última integração documental** | PR #8, atualização da Wiki e changelog após a manutenção, em 26/11/2026 |
| **Última etapa técnica integrada** | PR #7, **ETAPA INTEGRADA: MANUTENÇÃO PÓS-0.3-ALPHA + DOCUMENTO MESTRE DE SISTEMAS**, em 26/11/2026 |
| **Fase** | 1, protótipo |
| **Próxima prioridade** | Testes com pessoas em celulares físicos e ajustes a partir dos relatos |

## Etapas integradas

Esta é a linha do tempo oficial das entregas que chegaram à branch `main`. Manutenção e documentação não são contadas como novas versões de gameplay.

| Etapa | Entrega | Integração | Estado |
|---|---|---|---|
| 0.1-alpha | Projeto base: controles, câmera, arma automática e hordas | Commit inicial | {PUBLICADO} |
| 0.2-alpha — Ecos da Evolução | Experiência, orbes, level-up e seis melhorias | PR #1 | {PUBLICADO} |
| Infraestrutura da Wiki | Wiki pública, prévias por PR e ferramentas de QA | PR #6 | {PUBLICADO} |
| 0.3-alpha — Grande expansão do combate | Novas armas, ofertas, inimigos, Sentinela do Eco, esquiva, resultados e Ecos | PR #5 | {PUBLICADO} |
| **ETAPA INTEGRADA: MANUTENÇÃO PÓS-0.3-ALPHA + DOCUMENTO MESTRE DE SISTEMAS** | Separação das builds de produção e QA, robustez do save, retomada do joystick, limpeza técnica e Documento Mestre | **PR #7 · 26/11/2026** | {IMPLEMENTADO} |
| Documentação pós-PR #7 | Atualização do changelog, Wiki, testes e problemas conhecidos para refletir a manutenção integrada | PR #8 · 26/11/2026 | {PUBLICADO} |
| Arquivo histórico de prompts | Organização etapa por etapa dos prompts e solicitações de desenvolvimento | Em preparação nesta atualização | {EM_DESENVOLVIMENTO} |

### Detalhes da etapa de manutenção e Documento Mestre

A etapa técnica do PR #7 não criou uma nova versão jogável. A versão oficial permanece **0.3-alpha**.

- Produção e QA passaram a usar builds separadas. A build publicada não contém a ponte de testes.
- O save passou a validar estrutura e tipos, preservar cópias de arquivos corrompidos e corrigir campos inválidos individualmente.
- O joystick retoma corretamente após o level-up, sem exigir novo toque e sem gerar esquiva acidental.
- Foi removido um arquivo temporário versionado.
- Foi criado o [Documento Mestre de Sistemas](../../docs/design/DOCUMENTO_MESTRE_SISTEMAS.md), com 38 áreas e 30 catálogos, separando design, implementação e validação. Propostas não aprovadas não autorizam implementação.

Relatório técnico: [Manutenção pós-0.3-alpha](../../docs/versoes/manutencao-pos-0.3/RELATORIO.md).  
Registro editorial: [Changelog](../../docs/CHANGELOG.md).

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
- [[desenvolvimento/relatorios]] · [[desenvolvimento/changelog]] · [[desenvolvimento/decisoes]].
