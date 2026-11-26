class_name Upgrades
extends RefCounted
## As melhorias (passivas) escolhidas no level-up e seus efeitos.
## As armas novas e suas evoluções ficam no Arsenal; o sorteio das ofertas, em LevelUpOffers.
##
## Sinergias com as armas: Poder arcano vale para todas as armas; Cadência acelera o Raio
## e os pulsos da Aura; Campo de ruptura aumenta o alcance do Raio e metade disso na Aura.
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
const PACT := &"pacto_do_eco"

const DAMAGE_PER_STACK := 0.20
const FIRE_RATE_PER_STACK := 0.15
const VITALITY_HP_PER_STACK := 0.25
const VITALITY_HEAL := 25.0
const SPEED_PER_STACK := 0.15
const RANGE_PER_STACK := 0.20
const AURA_RANGE_SHARE := 0.5  ## A Aura ganha metade do bônus de alcance.
## Pacto do eco (risco e recompensa): mais dano e experiência, em troca de mais dano recebido.
const PACT_DAMAGE_PER_STACK := 0.25
const PACT_XP_PER_STACK := 0.15
const PACT_TAKEN_PER_STACK := 0.20

## Ordem fixa: também é a ordem usada nos testes e na documentação.
const DEFINITIONS := [
	{
		"id": DAMAGE,
		"name": "Poder arcano",
		"max": 10,
		"description": "+20% de dano de todas as armas.",
	},
	{
		"id": FIRE_RATE,
		"name": "Cadência",
		"max": 8,
		"description": "+15% de velocidade do Raio e dos pulsos da Aura.",
	},
	{
		"id": VITALITY,
		"name": "Núcleo vital",
		"max": 8,
		"description": "+25% de vida máxima e recupera 25 de vida.",
	},
	{
		"id": SPEED,
		"name": "Passos ligeiros",
		"max": 5,
		"description": "+15% de velocidade de movimento.",
	},
	{
		"id": PROJECTILE,
		"name": "Projétil adicional",
		"max": 4,
		"description": "+1 projétil por disparo, em leque.",
	},
	{
		"id": RANGE,
		"name": "Campo de ruptura",
		"max": 5,
		"description": "+20% de alcance do Raio (e +10% de área da Aura).",
	},
	{
		"id": PACT,
		"name": "Pacto do eco",
		"max": 3,
		"description": "+25% de dano e +15% de experiência, mas você recebe +20% de dano.",
	},
]

## Armas extras que recebem os bônus (ligadas por main.gd; podem ficar vazias nos testes).
var aura: AuraWeapon
var blades: OrbitBlades
## Bônus permanentes (MetaProgress), multiplicados em cima das melhorias da partida.
var meta_damage_multiplier := 1.0
var meta_hp_multiplier := 1.0
## Experiência recebida (Pacto do eco). Lida por main.gd ao coletar orbes.
var xp_multiplier := 1.0

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
	var text := ""
	match id:
		DAMAGE:
			text = _percent_change("Dano", DAMAGE_PER_STACK, n)
		FIRE_RATE:
			text = _percent_change("Disparos", FIRE_RATE_PER_STACK, n)
		VITALITY:
			text = _percent_change("Vida máxima", VITALITY_HP_PER_STACK, n)
		SPEED:
			text = _percent_change("Velocidade", SPEED_PER_STACK, n)
		PROJECTILE:
			text = "Projéteis por disparo: %d » %d" % [1 + n, 2 + n]
		RANGE:
			text = _percent_change("Alcance", RANGE_PER_STACK, n)
		PACT:
			text = (
				"Dano e XP: +%d%%/+%d%% » +%d%%/+%d%% · dano recebido +%d%%"
				% [
					_pct(PACT_DAMAGE_PER_STACK * n),
					_pct(PACT_XP_PER_STACK * n),
					_pct(PACT_DAMAGE_PER_STACK * (n + 1)),
					_pct(PACT_XP_PER_STACK * (n + 1)),
					_pct(PACT_TAKEN_PER_STACK * (n + 1)),
				]
			)
	return text


## "Rótulo: +X% » +Y%", do nível atual (n) para o próximo.
static func _percent_change(label: String, per_stack: float, n: int) -> String:
	return "%s: +%d%% » +%d%%" % [label, _pct(per_stack * n), _pct(per_stack * (n + 1))]


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
	var pact := stacks(PACT)
	var damage := (
		(1.0 + DAMAGE_PER_STACK * stacks(DAMAGE))
		* (1.0 + PACT_DAMAGE_PER_STACK * pact)
		* meta_damage_multiplier
	)
	xp_multiplier = 1.0 + PACT_XP_PER_STACK * pact
	player.damage_taken_multiplier = 1.0 + PACT_TAKEN_PER_STACK * pact
	var rate := 1.0 + FIRE_RATE_PER_STACK * stacks(FIRE_RATE)
	var reach := RANGE_PER_STACK * stacks(RANGE)
	weapon.damage_multiplier = damage
	weapon.fire_rate_multiplier = rate
	weapon.range_multiplier = 1.0 + reach
	weapon.extra_projectiles = stacks(PROJECTILE)
	if aura:
		aura.damage_multiplier = damage
		aura.rate_multiplier = rate
		aura.area_multiplier = 1.0 + reach * AURA_RANGE_SHARE
	if blades:
		blades.damage_multiplier = damage
	player.speed_multiplier = 1.0 + SPEED_PER_STACK * stacks(SPEED)
	player.set_max_hp_multiplier(
		(1.0 + VITALITY_HP_PER_STACK * stacks(VITALITY)) * meta_hp_multiplier
	)
