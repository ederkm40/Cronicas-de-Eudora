# Modelo de entrada dos catálogos

Toda entrada de catálogo segue este modelo. Campos que não se aplicam à categoria ficam com "—". **Nenhum valor é inventado:** para conteúdo implementado, os números vêm do código (cite o arquivo); para conteúdo proposto, escreva "a definir" até haver decisão.

## Estados (obrigatórios)

| Eixo | Valores |
|---|---|
| Design | `PROPOSTO_NAO_APROVADO` · `APROVADO` · `REJEITADO` · `SUBSTITUÍDO` |
| Implementação | `NÃO_IMPLEMENTADO` · `EM_DESENVOLVIMENTO` · `IMPLEMENTADO` · `IMPLEMENTADO_PARCIALMENTE` |
| Validação | `NÃO_TESTADO` · `TESTADO_COM_FALHAS` · `TESTADO` · `VALIDADO` |

Regras: `APROVADO` precisa de fonte (decisão, roadmap, instrução do proprietário ou PR integrado). `TESTADO` precisa citar o teste. `VALIDADO` exige teste com pessoas. Ver a seção 1.1 do [Documento Mestre](../DOCUMENTO_MESTRE_SISTEMAS.md).

## Modelo

```markdown
### <Nome original>

| Campo | Valor |
|---|---|
| **ID permanente** | `identificador_em_minusculas` (não muda depois de publicado) |
| **Categoria** | catálogo e subcategoria |
| **Descrição** | uma ou duas frases para o jogador |
| **Função** | papel no jogo (o que muda na forma de jogar) |
| **Valores** | números do código, com o arquivo de origem; ou "a definir" |
| **Efeitos** | o que acontece, em regras verificáveis |
| **Requisitos** | o que precisa existir ou acontecer para aparecer |
| **Sinergias** | com quais entradas interage, e como |
| **Limitações** | limites, contrajogo, custos |
| **Raridade** | se houver sistema de raridade; senão "—" |
| **Referência visual** | forma, cor, efeito (provisório ou final) |
| **Dependências** | sistemas de que depende (seção 34 do Documento Mestre) |
| **Estado de design** | … (fonte: …) |
| **Estado de implementação** | … (arquivo: …) |
| **Estado de validação** | … (teste: …) |
| **Histórico** | data e o que mudou |
```

## Campos extras por catálogo

- **Armas:** elemento, tipo de dano, dano base, frequência, alcance, projéteis, área, duração, recarga, nível, limite, evoluções, efeitos visuais, efeitos sonoros.
- **Inimigos e chefes:** vida, velocidade, dano de contato, ataques (com aviso e golpe), resistências, vulnerabilidades, XP e recompensas, momento de entrada, fases (chefes).
- **Passivos e melhorias permanentes:** efeito por nível, limite, custos (permanentes), fórmula e ordem de aplicação.
- **Recursos:** origem, finalidade, raridade, limites, destino.
- **Testes:** o que cobre, comando, critério de aprovação, última execução real registrada.
