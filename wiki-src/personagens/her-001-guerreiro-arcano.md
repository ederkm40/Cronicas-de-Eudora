---
titulo: HER-001 — O Guerreiro Arcano
resumo: Proposta conceitual do primeiro novo herói de Crônicas de Eudora, com domínio potencial sobre dez afinidades elementais.
---

**Estado:** `PROPOSTO_NAO_APROVADO`.

> **Natureza deste registro:** proposta de personagem e direção artística. Não representa personagem implementado, selecionável, testado ou publicado. A arte desenvolvida na conversa é referência conceitual; ainda não existe um pacote de sprites validado no repositório.

## Conceito central

O HER-001 é concebido como um **guerreiro arcano**, não como um mago tradicional. É um combatente jovem, mas experiente, que integrou a magia à própria técnica de batalha. Sua presença deve comunicar preparo físico, disciplina e domínio arcano, sem depender de cajado, chapéu ou túnicas longas.

- **Identificador de produção:** HER-001.
- **Nome próprio:** em aberto.
- **Universo:** Crônicas de Eudora.
- **Função proposta:** mago/conjurador de combate.
- **Faixa etária visual proposta:** aproximadamente 25 a 30 anos.
- **Personalidade proposta:** observador, inteligente, disciplinado, determinado e experiente.
- **Estado:** conceito visual aprovado pelo proprietário como direção promissora; ficha e detalhes de lore continuam propostas até aprovação explícita.

## Direção visual

A direção escolhida na exploração artística deve ser preservada como referência principal:

- Armadura leve de combate, com proteção reforçada no torso e peças assimétricas nos ombros.
- Paleta de azul profundo, aço escuro e detalhes dourados.
- Braceletes ou manoplas arcanas com runas luminosas.
- Cinto com pequenos artefatos e componentes funcionais.
- Calças e botas adequadas a deslocamentos rápidos.
- Tecido curto e assimétrico para movimento e leitura de silhueta, sem capa longa.
- Aparência atlética e ágil, sem volume excessivo de armadura.
- Rosto jovem e expressão concentrada; postura de alguém habituado a situações de combate.

A magia é canalizada principalmente pelas mãos, braços e manoplas. Armas arcanas temporárias podem surgir como manifestações de habilidades, mas o personagem não depende de um cajado.

**Regra de consistência:** rosto, proporções, armadura, paleta e silhueta devem permanecer reconhecíveis entre as afinidades. Os efeitos elementais mudam; a identidade do herói não.

## As dez afinidades

O conceito prevê potencial de interação com dez forças. Isso não significa domínio completo desde o início da jornada.

| Afinidade | Direção visual preliminar |
|---|---|
| Fogo | brasas, chamas concentradas e rastros incandescentes |
| Água | correntes fluidas, gotas suspensas e ondas de energia |
| Gelo | cristais, geada e fragmentos congelantes |
| Terra | rocha, poeira, placas minerais e impacto |
| Vento | correntes, espirais e cortes de ar |
| Relâmpago | arcos elétricos e descargas rápidas |
| Luz | brilho concentrado, runas claras e pulsos radiantes |
| Sombra | energia escura, véus e distorções discretas |
| Veneno | vapores, partículas tóxicas e resíduos alquímicos |
| Sangue | filamentos carmesins e energia vital condensada |

As cores, formas, efeitos, regras e interações de cada afinidade ainda precisam de especificação e aprovação. Combinações entre elementos são possibilidades de design, não mecânicas confirmadas.

## Combate e habilidades: propostas iniciais

As seguintes ideias são pontos de partida para a futura ficha de habilidades. Não devem ser tratadas como decisões finais:

1. **Projétil Arcano:** ataque básico à distância, com aparência adaptada à afinidade ativa.
2. **Convergência Elemental:** habilidade especial que combina ou alterna forças selecionadas.
3. **Manifestação das Dez Forças:** habilidade de grande impacto que expressa o potencial máximo do personagem.

A progressão deve revelar o domínio elemental gradualmente. O personagem não começa necessariamente com as dez afinidades desbloqueadas ou plenamente dominadas.

## Movimento e animação

A produção deve respeitar a tecnologia e a apresentação existentes em Crônicas de Eudora: **jogo 2D, câmera top-down inclinada/isométrica e sprites 2D**. Não projetar este herói como modelo 3D.

Conjunto de animações a especificar:

- Parado e movimentação nas oito direções.
- Caminhada e corrida, se forem estados distintos no jogo.
- Esquiva integrada ao controle direcional existente.
- Ataque básico e conjuração.
- Preparação, execução e recuperação de habilidades.
- Dano, interrupção e derrota.
- Variações de conjuração para as dez afinidades, mantendo a mesma base corporal.

A implementação deve respeitar os controles atuais: operação mobile prioritariamente com um dedo e joystick flutuante, ataques automáticos e esquiva por duplo toque direcional; teclado no PC. Nenhum botão novo deve ser presumido sem análise de UX e aprovação.

## Requisitos para a futura produção de arte

1. Fixar uma referência visual principal e uma ficha de proporções.
2. Criar vistas consistentes do personagem para conferência de volumes e detalhes.
3. Definir resolução, escala, pivô, margens e convenção de nomes dos sprites conforme o pipeline real do projeto.
4. Produzir primeiro um conjunto pequeno de animações e validar sua leitura no cenário isométrico.
5. Só então expandir para as oito direções e variações elementais.
6. Testar legibilidade em tamanho real de jogo, especialmente em telas de celular e durante hordas com efeitos simultâneos.

A arte conceitual gerada na conversa não deve ser recortada automaticamente e declarada como spritesheet de produção. Consistência de quadros, transparência, alinhamento e legibilidade precisam ser verificados.

## Estados independentes

| Eixo | Estado |
|---|---|
| Design | PROPOSTO_NAO_APROVADO para ficha completa, lore, habilidades, afinidades e animações |
| Direção artística | Referência conceitual bem recebida pelo proprietário; detalhes finais ainda sujeitos a revisão |
| Implementação | NÃO_IMPLEMENTADO |
| Validação | NÃO_TESTADO |
| Publicação | NÃO_PUBLICADO |

A aprovação da direção visual não autoriza automaticamente implementação, alteração do Documento Mestre técnico ou mudança na versão oficial.

## Próximas decisões de design

- Nome próprio e biografia definitiva.
- Origem, vínculos e papel do herói na narrativa de Eudora.
- Como as dez afinidades são aprendidas, equipadas e combinadas.
- Arma, foco arcano ou manifestações físicas utilizadas no combate.
- Habilidades finais, passivas, progressão e limitações.
- Escopo de sprites e animações compatível com o pipeline existente.

## Relação com o projeto

- [[personagens|Catálogo de personagens]]
- [[desenvolvimento|Painel de desenvolvimento]]
- [[desenvolvimento/roadmap|Roadmap]]

