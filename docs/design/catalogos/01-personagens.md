# Catálogo 01: Personagens e classes

Entradas comprovadas no código da 0.3-alpha. Modelo: [MODELO_ENTRADA.md](MODELO_ENTRADA.md).

### Personagem jogável (sem nome)

| Campo | Valor |
|---|---|
| **ID permanente** | — (não existe ID no código: há um único personagem) |
| **Categoria** | personagem jogável |
| **Descrição** | personagem sem nome nem classe, controlado em todas as partidas |
| **Função** | movimento, esquiva e porte das armas automáticas |
| **Valores** | vida 100; velocidade 5 m/s; arma inicial Raio arcano; esquiva 4 m em 0,18 s, invulnerável 0,32 s, recarga 1,4 s; piscada de dano 0,12 s (`scripts/player.gd`) |
| **Efeitos** | vira na direção do movimento; ao chegar a 0 de vida, a partida termina em derrota |
| **Requisitos** | — |
| **Sinergias** | Núcleo vital, Passos ligeiros, Vigor ancestral |
| **Limitações** | sem classe, habilidades ativas ou atributos próprios além de vida e velocidade |
| **Raridade** | — |
| **Referência visual** | cápsula azul com um bloco à frente (provisório) |
| **Dependências** | controles, atributos, armas |
| **Estado de design** | `APROVADO` (protótipo, 0.1-alpha) |
| **Estado de implementação** | `IMPLEMENTADO` (`scripts/player.gd`) |
| **Estado de validação** | `TESTADO` (`tests/suites/progressao.gd`, `esquiva_e_encerramento.gd`; sem teste com pessoas) |
| **Histórico** | 0.1: criado · 0.3: esquiva |

Planejado: **uma classe completa** (roadmap, fase 2) — `APROVADO` · `NÃO_IMPLEMENTADO` · sem entrada até a classe ser definida.
