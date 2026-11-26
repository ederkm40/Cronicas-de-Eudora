class_name WeaponCatalog
extends RefCounted
## Definição das armas: nome, descrição, tipo e os atributos de cada nível.
## É só dado. O estado (quais armas o jogador tem e em que nível) fica no Arsenal,
## e a execução de cada arma fica no nó dela (AutoWeapon, AuraWeapon, OrbitBlades).
##
## Para criar uma arma nova: acrescente a definição aqui, crie o nó que executa o ataque
## (usando EnemyManager para achar e ferir inimigos) e ligue o nó em main.gd (_sync_weapons).

const BOLT := &"raio_arcano"
const AURA := &"aura_de_brasas"
const BLADE := &"lamina_orbital"

## Cada nível lista os atributos completos (não a diferença), para ficar fácil de ler e ajustar.
const DEFINITIONS := [
	{
		"id": BOLT,
		"name": "Raio arcano",
		"kind": "projetil",
		"description": "Dispara sozinho no inimigo mais próximo.",
		"max_level": 1,
		"levels": [],
	},
	{
		"id": AURA,
		"name": "Aura de brasas",
		"kind": "aura",
		"description": "Um círculo de brasas queima todos os inimigos dentro dele a cada pulso.",
		"max_level": 5,
		"levels":
		[
			{"damage": 6.0, "radius": 2.2, "interval": 0.6},
			{"damage": 7.0, "radius": 2.4, "interval": 0.6},
			{"damage": 9.0, "radius": 2.6, "interval": 0.55},
			{"damage": 11.0, "radius": 2.9, "interval": 0.5},
			{"damage": 14.0, "radius": 3.2, "interval": 0.45},
		],
	},
	{
		"id": BLADE,
		"name": "Lâmina orbital",
		"kind": "orbital",
		"description": "Lâminas giram ao seu redor e cortam quem atravessam.",
		"max_level": 5,
		"levels":
		[
			{"damage": 14.0, "count": 1, "radius": 1.9, "speed": 3.2},
			{"damage": 15.0, "count": 2, "radius": 1.9, "speed": 3.2},
			{"damage": 20.0, "count": 2, "radius": 2.2, "speed": 3.6},
			{"damage": 22.0, "count": 3, "radius": 2.2, "speed": 3.8},
			{"damage": 26.0, "count": 4, "radius": 2.5, "speed": 4.0},
		],
	},
]

## Evoluções: cada arma pode evoluir uma vez, quando está no nível pedido e o jogador tem as
## melhorias passivas exigidas. A evolução muda o comportamento da arma (não só os números).
const EVO_BOLT := &"raio_em_cadeia"
const EVO_AURA := &"coroa_de_cinzas"
const EVO_BLADE := &"vendaval_de_laminas"
const EVOLUTIONS := [
	{
		"id": EVO_BOLT,
		"weapon": BOLT,
		"name": "Raio em cadeia",
		"description": "Cada acerto salta para 2 inimigos perto (60% do dano); 3 se o alvo arde.",
		"weapon_level": 1,
		"requires": {&"projetil_adicional": 2, &"poder_arcano": 3},
	},
	{
		"id": EVO_AURA,
		"weapon": AURA,
		"name": "Coroa de cinzas",
		"description": "Os pulsos deixam os inimigos em chamas por 3 s e a área cresce 15%.",
		"weapon_level": 5,
		"requires": {&"cadencia": 2},
	},
	{
		"id": EVO_BLADE,
		"weapon": BLADE,
		"name": "Vendaval de lâminas",
		"description":
		"+2 lâminas; a órbita abre e fecha; cada corte empurra e deixa o inimigo lento.",
		"weapon_level": 5,
		"requires": {&"passos_ligeiros": 2},
	},
]

## Rótulos dos atributos nos cartões de evolução.
const LABELS := {
	"damage": "Dano",
	"radius": "Alcance",
	"interval": "Pulso",
	"count": "Lâminas",
	"speed": "Giro",
}


static func definition(id: StringName) -> Dictionary:
	for d in DEFINITIONS:
		if d.id == id:
			return d
	return {}


static func evolution(id: StringName) -> Dictionary:
	for e in EVOLUTIONS:
		if e.id == id:
			return e
	return {}


static func evolution_of_weapon(weapon_id: StringName) -> Dictionary:
	for e in EVOLUTIONS:
		if e.weapon == weapon_id:
			return e
	return {}


static func is_weapon(id: StringName) -> bool:
	return not definition(id).is_empty()


static func all_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for d in DEFINITIONS:
		ids.append(d.id)
	return ids


static func max_level(id: StringName) -> int:
	return int(definition(id).get("max_level", 0))


## Atributos da arma no nível `level` (1 = recém-adquirida). Vazio se não houver.
static func stats(id: StringName, level: int) -> Dictionary:
	var levels: Array = definition(id).get("levels", [])
	if level < 1 or level > levels.size():
		return {}
	return levels[level - 1]


## Texto do cartão: o que muda do nível `from_level` para o seguinte.
## Nível 0 = a arma ainda não foi adquirida.
static func describe_change(id: StringName, from_level: int) -> String:
	var next := stats(id, from_level + 1)
	if next.is_empty():
		return ""
	if from_level == 0:
		return _summary(next)
	var current := stats(id, from_level)
	var parts: Array[String] = []
	for key in next:
		if next[key] != current[key]:
			var change := [LABELS[key], _fmt(key, current[key]), _fmt(key, next[key])]
			parts.append("%s %s » %s" % change)
	return " · ".join(parts)


static func _summary(values: Dictionary) -> String:
	var parts: Array[String] = []
	for key in values:
		parts.append("%s %s" % [LABELS[key], _fmt(key, values[key])])
	return " · ".join(parts)


static func _fmt(key: String, value: Variant) -> String:
	match key:
		"radius":
			return ("%.1f m" % value).replace(".", ",")
		"interval":
			return ("%.2f s" % value).replace(".", ",")
		"speed":
			return ("%.1f" % value).replace(".", ",")
		"count":
			return str(value)
	return str(roundi(float(value)))
