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
			{"damage": 8.0, "radius": 2.5, "interval": 0.6},
			{"damage": 10.0, "radius": 2.8, "interval": 0.5},
			{"damage": 13.0, "radius": 3.1, "interval": 0.5},
			{"damage": 16.0, "radius": 3.5, "interval": 0.42},
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
			{"damage": 14.0, "count": 2, "radius": 1.9, "speed": 3.2},
			{"damage": 18.0, "count": 2, "radius": 2.2, "speed": 3.4},
			{"damage": 20.0, "count": 3, "radius": 2.2, "speed": 3.8},
			{"damage": 24.0, "count": 4, "radius": 2.5, "speed": 4.0},
		],
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
			parts.append("%s %s » %s" % [LABELS[key], _fmt(key, current[key]), _fmt(key, next[key])])
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
