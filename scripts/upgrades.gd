class_name Upgrades
extends RefCounted
## As melhorias escolhidas no level-up e seus efeitos.
##
## Cada melhoria tem um número de níveis (pilhas) e um limite. Os efeitos são sempre
## recalculados a partir dos valores base da arma e do jogador, então somar a mesma
## melhoria várias vezes dá sempre o mesmo resultado, sem erro acumulado.

const DAMAGE := &"poder_arcano"
const FIRE_RATE := &"cadencia"
const VITALITY := &"nucleo_vital"
const SPEED := &"passos_ligeiros"
const PROJECTILE := &"projetil_adicional"
const RANGE := &"campo_de_ruptura"

const DAMAGE_PER_STACK := 0.20
const FIRE_RATE_PER_STACK := 0.15
const VITALITY_HP_PER_STACK := 0.25
const VITALITY_HEAL := 25.0
const SPEED_PER_STACK := 0.15
const RANGE_PER_STACK := 0.20

## Ordem fixa: também é a ordem usada nos testes e na documentação.
const DEFINITIONS := [
	{
		"id": DAMAGE, "name": "Poder arcano", "max": 10,
		"description": "+20% de dano dos projéteis.",
	},
	{
		"id": FIRE_RATE, "name": "Cadência", "max": 8,
		"description": "+15% de velocidade de disparo.",
	},
	{
		"id": VITALITY, "name": "Núcleo vital", "max": 8,
		"description": "+25% de vida máxima e recupera 25 de vida.",
	},
	{
		"id": SPEED, "name": "Passos ligeiros", "max": 5,
		"description": "+15% de velocidade de movimento.",
	},
	{
		"id": PROJECTILE, "name": "Projétil adicional", "max": 4,
		"description": "+1 projétil por disparo, em leque.",
	},
	{
		"id": RANGE, "name": "Campo de ruptura", "max": 5,
		"description": "+20% de alcance da arma.",
	},
]

var _stacks := {}


func _init() -> void:
	for definition in DEFINITIONS:
		_stacks[definition.id] = 0


static func definition(id: StringName) -> Dictionary:
	for d in DEFINITIONS:
		if d.id == id:
			return d
	return {}


static func all_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for d in DEFINITIONS:
		ids.append(d.id)
	return ids


func stacks(id: StringName) -> int:
	return _stacks.get(id, 0)


func is_maxed(id: StringName) -> bool:
	return stacks(id) >= int(definition(id).max)


func available_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for d in DEFINITIONS:
		if not is_maxed(d.id):
			ids.append(d.id)
	return ids


## Sorteia até `amount` melhorias diferentes entre as que ainda não chegaram ao limite.
## Só devolve menos de 3 quando restam menos de 3 melhorias disponíveis.
func roll_choices(amount: int = 3, rng: RandomNumberGenerator = null) -> Array[StringName]:
	var pool := available_ids()
	var picked: Array[StringName] = []
	while picked.size() < amount and not pool.is_empty():
		var index := rng.randi_range(0, pool.size() - 1) if rng else randi_range(0, pool.size() - 1)
		picked.append(pool[index])
		pool.remove_at(index)
	return picked


## Texto curto para o cartão: o que muda do nível atual para o próximo.
func describe_next(id: StringName) -> String:
	var n := stacks(id)
	match id:
		DAMAGE:
			return "Dano: +%d%% » +%d%%" % [_pct(DAMAGE_PER_STACK * n), _pct(DAMAGE_PER_STACK * (n + 1))]
		FIRE_RATE:
			return "Disparos: +%d%% » +%d%%" % [_pct(FIRE_RATE_PER_STACK * n), _pct(FIRE_RATE_PER_STACK * (n + 1))]
		VITALITY:
			return "Vida máxima: +%d%% » +%d%%" % [_pct(VITALITY_HP_PER_STACK * n), _pct(VITALITY_HP_PER_STACK * (n + 1))]
		SPEED:
			return "Velocidade: +%d%% » +%d%%" % [_pct(SPEED_PER_STACK * n), _pct(SPEED_PER_STACK * (n + 1))]
		PROJECTILE:
			return "Projéteis por disparo: %d » %d" % [1 + n, 2 + n]
		RANGE:
			return "Alcance: +%d%% » +%d%%" % [_pct(RANGE_PER_STACK * n), _pct(RANGE_PER_STACK * (n + 1))]
	return ""


static func _pct(value: float) -> int:
	return int(round(value * 100.0))


## Soma um nível da melhoria e aplica o efeito na hora. Retorna false se já estava no limite.
func apply(id: StringName, player: Player, weapon: AutoWeapon) -> bool:
	if not _stacks.has(id) or is_maxed(id):
		return false
	_stacks[id] += 1
	refresh(player, weapon)
	if id == VITALITY:
		player.heal(VITALITY_HEAL)
	return true


## Recalcula todos os modificadores a partir dos níveis atuais.
func refresh(player: Player, weapon: AutoWeapon) -> void:
	weapon.damage_multiplier = 1.0 + DAMAGE_PER_STACK * stacks(DAMAGE)
	weapon.fire_rate_multiplier = 1.0 + FIRE_RATE_PER_STACK * stacks(FIRE_RATE)
	weapon.range_multiplier = 1.0 + RANGE_PER_STACK * stacks(RANGE)
	weapon.extra_projectiles = stacks(PROJECTILE)
	player.speed_multiplier = 1.0 + SPEED_PER_STACK * stacks(SPEED)
	player.set_max_hp_multiplier(1.0 + VITALITY_HP_PER_STACK * stacks(VITALITY))
