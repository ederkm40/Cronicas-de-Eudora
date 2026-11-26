class_name Progression
extends RefCounted
## Experiência e nível do jogador durante a partida.
## Não sabe nada de interface: só conta XP, sobe de nível e avisa quem estiver ouvindo.

signal leveled_up(new_level: int)

const BASE_REQUIREMENT := 4.0
const GROWTH_EXPONENT := 1.35

var level := 1
var xp := 0 ## Experiência acumulada dentro do nível atual.
var total_xp := 0
var pending_level_ups := 0 ## Níveis ganhos que ainda não tiveram melhoria escolhida.


## Experiência necessária para sair do nível `for_level` e ir para o próximo.
## Cresce aos poucos: nível 1 = 4, nível 2 = 10, nível 3 = 18, nível 5 = 35, nível 10 = 90.
static func requirement(for_level: int) -> int:
	return int(round(BASE_REQUIREMENT * pow(float(for_level), GROWTH_EXPONENT)))


func xp_to_next() -> int:
	return requirement(level)


func progress_ratio() -> float:
	return float(xp) / float(xp_to_next())


## Soma experiência. Pode subir vários níveis de uma vez se a quantidade for grande.
func add_xp(amount: int) -> void:
	if amount <= 0:
		return
	xp += amount
	total_xp += amount
	while xp >= xp_to_next():
		xp -= xp_to_next()
		level += 1
		pending_level_ups += 1
		leveled_up.emit(level)


func consume_pending_level_up() -> void:
	pending_level_ups = maxi(pending_level_ups - 1, 0)
