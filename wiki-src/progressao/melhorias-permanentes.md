---
titulo: Melhorias permanentes
resumo: Quatro melhorias compradas com Ecos e mantidas entre as partidas.
estado: PUBLICADO
versao: 0.3-alpha
ordem: 50
---
A tela de resultados permite gastar [[progressao/ecos|Ecos]] em quatro melhorias permanentes. Os bônus se aplicam às partidas seguintes e são salvos no navegador.

| Melhoria | Efeito por nível | Limite | Custos por nível |
|---|---|---:|---|
| Vigor ancestral | +8% de vida máxima | 5 | 15, 30, 50, 75, 110 |
| Fúria latente | +5% de dano de todas as armas | 5 | 20, 40, 65, 95, 130 |
| Atração do eco | +20% no raio do ímã dos orbes (3 m na base) | 3 | 12, 25, 45 |
| Renovação | +1 troca de ofertas no level-up | 2 | 40, 90 |

Na tela do jogo, a descrição da Atração do eco diz "raio de coleta"; o efeito real é aumentar a distância em que os orbes começam a voar até o personagem (o ímã), não a distância final de coleta (0,6 m).

Os limites são independentes: cada melhoria pode chegar ao próprio nível máximo.

## Salvamento

O progresso fica em `user://progresso.json`, com formato versionado. No navegador, `user://` usa o armazenamento local do site. O save tem migração entre versões e valida a estrutura e os tipos antes de usar os dados.

- **Estrutura inválida** (JSON inválido, raiz que não é objeto ou campos estruturais obrigatórios com tipo errado): o arquivo original é preservado numa cópia `.corrompido` e o jogo inicia um progresso novo.
- **Campo individual inválido** (tipo errado, valor negativo, fracionado ou nível acima do limite): o campo é corrigido, preservando os demais dados válidos; também é mantida cópia de recuperação.
- **Versão futura:** o arquivo é tratado como somente leitura e nunca é sobrescrito por uma versão antiga do jogo.
- **Campos desconhecidos:** são preservados.

Essas regras foram implementadas na manutenção pós-0.3-alpha e cobertas pela suíte de testes de save.

O formato atual é a versão 1.
