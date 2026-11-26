# Catálogo 26: Recursos e economia

### Ecos

| Campo | Valor |
|---|---|
| **ID permanente** | `ecos` (campo do save `user://progresso.json`) |
| **Categoria** | recurso permanente |
| **Origem** | fim de cada partida: 1 a cada 20 s, 1 a cada 15 abates, 40 por chefe derrotado (`MetaProgress.reward_for`) |
| **Finalidade** | comprar as 4 melhorias permanentes na tela de resultados |
| **Raridade** | — |
| **Limites** | sem teto de Ecos; as melhorias têm nível máximo |
| **Destino** | gasto na loja; sobra acumula |
| **Limitações** | quando todas as melhorias chegam ao máximo, os Ecos ficam sem uso (risco de inflação, seção 21 do Documento Mestre) |
| **Dependências** | resultados, `MetaProgress`, persistência |
| **Estado de design** | `APROVADO` (0.3-alpha) |
| **Estado de implementação** | `IMPLEMENTADO` (`scripts/meta_progress.gd`) |
| **Estado de validação** | `TESTADO` (`esquiva_e_encerramento.gd`, `save_e_joystick.gd`) |

### Melhorias permanentes (destino dos Ecos)

| ID permanente | Nome | Efeito por nível | Níveis | Custos | D · I · V |
|---|---|---|---|---|---|
| `vigor_ancestral` | Vigor ancestral | +8% de vida máxima | 5 | 15, 30, 50, 75, 110 | `APROVADO` · `IMPLEMENTADO` · `TESTADO` |
| `furia_latente` | Fúria latente | +5% de dano de todas as armas | 5 | 20, 40, 65, 95, 130 | `APROVADO` · `IMPLEMENTADO` · `TESTADO` |
| `atracao_do_eco` | Atração do eco | +20% de raio do ímã de orbes (o texto no jogo diz "raio de coleta") | 3 | 12, 25, 45 | `APROVADO` · `IMPLEMENTADO` · `TESTADO` |
| `renovacao` | Renovação | +1 troca de opções no level-up | 2 | 40, 90 | `APROVADO` · `IMPLEMENTADO` · `TESTADO` |
