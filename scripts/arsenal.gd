class_name Arsenal
extends RefCounted
## Estado das armas do jogador na partida: quais tem e em que nível.
## Cada arma ocupa um espaço próprio. Adquirir uma arma nunca substitui outra
## nem mexe no nível das outras.

const DEFAULT_SLOTS := 4

var max_slots := DEFAULT_SLOTS

var _levels := {}  ## id da arma -> nível (só armas adquiridas)
var _order: Array[StringName] = []  ## Ordem de aquisição (para a interface).
var _evolved := {}  ## id da arma -> true, se já evoluiu.


func _init(starting_weapon: StringName = WeaponCatalog.BOLT) -> void:
	if starting_weapon != &"":
		acquire(starting_weapon)


func owns(id: StringName) -> bool:
	return _levels.has(id)


func level(id: StringName) -> int:
	return _levels.get(id, 0)


func owned_ids() -> Array[StringName]:
	return _order.duplicate()


func free_slots() -> int:
	return max_slots - _order.size()


func can_acquire(id: StringName) -> bool:
	return WeaponCatalog.is_weapon(id) and not owns(id) and free_slots() > 0


func can_level_up(id: StringName) -> bool:
	return owns(id) and level(id) < WeaponCatalog.max_level(id)


## Uma oferta válida no level-up: adquirir (se há espaço) ou evoluir (se não está no máximo).
func can_offer(id: StringName) -> bool:
	return can_acquire(id) or can_level_up(id)


func acquire(id: StringName) -> bool:
	if not can_acquire(id):
		return false
	_levels[id] = 1
	_order.append(id)
	return true


func level_up(id: StringName) -> bool:
	if not can_level_up(id):
		return false
	_levels[id] += 1
	return true


## Evolução: a arma está no nível pedido e as melhorias exigidas foram escolhidas.
func can_evolve(evolution_id: StringName, upgrades: Upgrades) -> bool:
	var e := WeaponCatalog.evolution(evolution_id)
	if e.is_empty() or is_evolved(e.weapon) or level(e.weapon) < int(e.weapon_level):
		return false
	for upgrade_id: StringName in e.requires:
		if upgrades.stacks(upgrade_id) < int(e.requires[upgrade_id]):
			return false
	return true


func evolve(evolution_id: StringName, upgrades: Upgrades) -> bool:
	if not can_evolve(evolution_id, upgrades):
		return false
	_evolved[WeaponCatalog.evolution(evolution_id).weapon] = true
	return true


func is_evolved(weapon_id: StringName) -> bool:
	return _evolved.has(weapon_id)


## Adquire ou evolui, conforme o caso.
func advance(id: StringName) -> bool:
	return level_up(id) if owns(id) else acquire(id)
