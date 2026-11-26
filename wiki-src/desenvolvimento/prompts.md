---
titulo: Arquivo histórico de prompts
resumo: Registro cronológico dos prompts e solicitações usados no desenvolvimento de Crônicas de Eudora.
ordem: 25
---
Este arquivo guarda o histórico de instruções dadas às IAs durante o desenvolvimento, etapa por etapa. O objetivo é permitir rastreabilidade: entender o que foi pedido, quais limites foram definidos e como cada entrega evoluiu.

## Como ler este arquivo

- **Transcrição literal recuperada:** o texto original do prompt foi localizado e preservado sem alterações.
- **Resumo recuperado:** o histórico confirma o pedido e seus pontos principais, mas não contém o texto integral.
- **Reconstrução editorial:** síntese organizada a partir das decisões e entregas documentadas. Não deve ser tratada como prompt original.
- **A recuperar:** sabemos que houve uma solicitação, mas ainda não temos conteúdo suficiente para registrá-la com segurança.

Não inventar texto para preencher lacunas. Quando o prompt original estiver disponível em uma conversa, ele deve ser copiado integralmente, incluindo listas, critérios e restrições.

## Índice cronológico

| Etapa | Tema | Registro disponível |
|---|---|---|
| 0.1-alpha | Fundação do projeto | Resumo recuperado |
| 0.2-alpha — Ecos da Evolução | Experiência, orbes, level-up e melhorias | Resumo recuperado |
| Infraestrutura | CI, ferramentas de qualidade e fluxo de PR | Resumo recuperado |
| 0.3-alpha — Grande expansão do combate | Armas, ofertas, inimigos, chefe, esquiva, resultados e Ecos | Resumo recuperado |
| PR #6 | Wiki pública e prévias | A recuperar |
| PR #7 | Manutenção pós-0.3-alpha + Documento Mestre de Sistemas | Resumo recuperado |
| PR #8 | Atualização da Wiki e changelog após PR #7 | Resumo recuperado |
| Etapa 3 / PR #10 | O Despertar de Eudora, evolução do núcleo de gameplay | Resumo recuperado |
| Próximas etapas | Novos pedidos de desenvolvimento | A registrar literalmente |

## 0.1-alpha — Projeto base

**Situação do registro:** resumo recuperado; prompt integral não localizado no contexto disponível.

**Pedido confirmado:** criar a fundação jogável de Crônicas de Eudora, um RPG de ação isométrico de hordas, com foco em execução Web e possibilidade de jogar no celular.

**Escopo identificável na entrega:** personagem controlável, câmera isométrica, joystick flutuante, teclado, arma automática, hordas, HUD e exportação Web.

**Restrições de processo identificadas:** manter o projeto executável no navegador e preservar a possibilidade de testar em dispositivos móveis.

## 0.2-alpha — Ecos da Evolução

**Situação do registro:** resumo recuperado; prompt integral não localizado no contexto disponível.

**Pedido confirmado:** acrescentar o primeiro ciclo de progressão durante a partida.

**Escopo identificável na entrega:** inimigos geram orbes de experiência; coleta de XP; subida de nível com pausa e três opções; seis melhorias com limites; barra de XP e testes automatizados.

## Infraestrutura — qualidade e fluxo de desenvolvimento

**Situação do registro:** resumo recuperado; prompt integral não localizado no contexto disponível.

**Pedido confirmado:** auditar e melhorar a infraestrutura de desenvolvimento sem acrescentar custos ou exigir ferramentas pagas, preservando o fluxo pelo navegador e a proteção da branch principal.

**Escopo identificável:** ferramentas de lint e formatação, testes automatizados, CI, prévias de Pull Request, documentação para continuidade por IA e fluxo de branches/PRs. A auditoria também registrou ferramentas que estavam ausentes ou parcialmente configuradas.

## 0.3-alpha — Grande expansão do combate

**Situação do registro:** resumo recuperado; o histórico disponível confirma os principais requisitos, mas não preserva o prompt integral.

**Pedido confirmado:** evoluir o combate de ponta a ponta, ampliando variedade, escolhas de build, inimigos, encontro final, esquiva e progressão entre partidas.

**Escopo identificável:**
- Duas armas novas com espaços próprios: Aura de brasas e Lâmina orbital.
- Ofertas de armas, evoluções e melhorias no level-up.
- Troca e bloqueio de ofertas, com limites por partida.
- Quatro tipos adicionais de inimigo e entrada gradual por tempo.
- Sentinela do Eco como chefe de dez minutos.
- Esquiva por duplo toque no joystick e tecla Espaço no PC.
- Vitória, derrota, tela de resultados e reinício limpo.
- Ecos e quatro melhorias permanentes.
- Testes automatizados, simulação de equilíbrio e prévia Web.

**Limite importante:** funcionalidades antecipadas de etapas futuras não significam que todo o escopo dessas etapas esteja concluído.

## PR #6 — Wiki pública e prévias

**Situação do registro:** a entrega está documentada; prompt integral a recuperar.

**Objetivo identificável:** disponibilizar Wiki pública, painel de desenvolvimento, prévias por Pull Request e documentação técnica organizada, sem publicar versões ainda em revisão.

## PR #7 — ETAPA INTEGRADA: MANUTENÇÃO PÓS-0.3-ALPHA + DOCUMENTO MESTRE DE SISTEMAS

**Situação do registro:** resumo recuperado a partir do pedido e dos documentos técnicos; prompt integral não localizado.

**Pedido confirmado:** executar em uma única etapa integrada a manutenção pós-0.3-alpha e a criação do Documento Mestre de Sistemas, sem transformar manutenção em nova versão de gameplay.

**Escopo confirmado:**
- Separar build de produção e build QA, garantindo que a ponte de testes nunca seja publicada.
- Corrigir a validação e recuperação do arquivo de progresso.
- Corrigir a retomada do joystick depois do level-up.
- Fazer limpeza de arquivos temporários.
- Criar o Documento Mestre abrangendo o jogo inteiro, não apenas itens: inimigos, armas, evolução, poderes, estágios, coleções, captadores e demais sistemas.
- Separar estados de design, implementação e validação.
- Manter propostas não aprovadas claramente identificadas e sem autorização implícita para implementação.
- Atualizar a documentação técnica e entregar por branch e Pull Request, sem merge automático.

**Resultado documentado:** PR #7 integrado em 26/11/2026. A versão do jogo permaneceu 0.3-alpha.

## PR #8 — Atualização da Wiki e changelog após PR #7

**Situação do registro:** resumo recuperado; prompt integral não localizado.

**Pedido confirmado:** atualizar a Wiki com as mudanças efetivamente integradas no PR #7, corrigir informações desatualizadas e atualizar o changelog, mantendo a distinção entre manutenção técnica e versão de gameplay.

**Escopo identificável:** atualizar painel, funcionalidades, testes, problemas conhecidos, joystick, progressão, histórico de versões e página inicial. A documentação deveria refletir os resultados de testes e manter explícito que testes físicos com pessoas ainda não tinham sido feitos.

## Diretrizes permanentes para os próximos prompts

As regras abaixo devem acompanhar os próximos pedidos de desenvolvimento, salvo decisão expressa em contrário:

1. Responder em português do Brasil.
2. Preservar a branch `main`; desenvolver em branch própria e entregar Pull Request.
3. Não fazer merge sem autorização explícita do proprietário.
4. Não declarar recurso como implementado, testado ou publicado sem evidência.
5. Separar o que foi aprovado do que é proposta.
6. Não transformar manutenção ou documentação em nova versão de gameplay.
7. Priorizar celular, mantendo suporte a PC.
8. Registrar testes, resultados, limitações e arquivos alterados.
9. Atualizar este arquivo com o prompt literal de cada nova etapa, na ordem de envio.
10. Se houver mais de um prompt na mesma etapa, guardar todos, numerados e sem fundi-los.

## Modelo para cada novo registro

### [Número e nome da etapa]

- **Data:**
- **PR/branch/commit:**
- **Situação do texto:** transcrição literal recuperada / resumo recuperado / reconstrução editorial.
- **Prompt 1:**

> Colar aqui o prompt integral, preservando a redação original.

- **Prompt 2:** (repetir quando houver)
- **Resultado:** link para relatório, PR e versão.
- **Observações:** decisões, correções e limites relevantes.


## Etapa 3 — O Despertar de Eudora (0.4-alpha, PR #10)

**Situação do registro:** resumo recuperado a partir da solicitação do proprietário, do prompt de execução preparado nesta conversa e do relatório técnico. O pedido literal do proprietário foi: “vamos lá então seja extremamente criativo nesse prompt. Quero muita evolução.”

**Objetivo confirmado:** transformar a 0.3-alpha em uma experiência mais rica, com evolução substancial do combate, builds, inimigos, chefes, eventos, progressão, controles mobile, identidade audiovisual e desempenho. A orientação exigia auditoria antes de implementar, liberdade criativa com critérios, respeito ao Documento Mestre, testes automatizados, branch própria e Pull Request sem merge automático.

**Resultado:** PR #10 integrado em 26/11/2026 como 0.4-alpha. Foram adicionadas configurações mobile, três evoluções de armas, Pacto do Eco, estados de combate, Tecelão, Semeador, elites, eventos, novas mecânicas da Sentinela, som procedural e feedback audiovisual. As mecânicas novas de gameplay permanecem experimentais no eixo de design; a personalização mobile já era aprovada.

**Registro da entrega:** [PR #10](https://github.com/ederkm40/Cronicas-de-Eudora/pull/10) · [relatório 0.4-alpha](https://github.com/ederkm40/Cronicas-de-Eudora/blob/main/docs/versoes/0.4-alpha/RELATORIO.md).
