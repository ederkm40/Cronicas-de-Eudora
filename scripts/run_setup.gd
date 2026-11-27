class_name RunSetup
extends RefCounted
## O pacote que o menu entrega à partida: qual personagem e qual missão foram escolhidos.
## O menu preenche `RunSetup.current` antes de trocar de cena, e a partida lê com `take()`.
## Na Parte 1 do menu só existem o personagem e a missão atuais, então a partida continua
## igual. Os catálogos de personagens e missões chegam nas próximas partes.

const DEFAULT_CHARACTER := &"padrao"
const DEFAULT_MISSION := &"padrao"

## Escolha feita no menu para a próxima partida (null = partida aberta sem passar pelo menu,
## como nos testes).
static var current: RunSetup

var character_id: StringName = DEFAULT_CHARACTER
var mission_id: StringName = DEFAULT_MISSION


## A escolha atual, ou a padrão. Não apaga `current`: "Jogar de novo" repete a mesma escolha.
static func take() -> RunSetup:
	return current if current != null else RunSetup.new()


func to_dict() -> Dictionary:
	return {"personagem": String(character_id), "missao": String(mission_id)}
