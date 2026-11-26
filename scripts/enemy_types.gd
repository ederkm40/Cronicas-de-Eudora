class_name EnemyTypes
extends RefCounted
## Arquétipos de inimigos: atributos de cada tipo e a mistura de tipos ao longo da partida.
## Todos os números de balanceamento dos inimigos ficam aqui, num lugar só.
##
## "hp" é um multiplicador da vida base do EnemyManager (que cresce com o tempo de partida).
## "armor" é a fração do dano que o inimigo ignora (0,4 = recebe 60% do dano).

enum { COMUM, RAPIDO, RESISTENTE, ATIRADOR, EXPLOSIVO, CHEFE, TECELAO, SEMEADOR }
## Modificadores de elite (ver ELITE_NAMES).
enum { SEM_ELITE, VELOZ, BLINDADO, GERADOR }

const COUNT := 8
const STATS := [
	{
		"name": "Errante",
		"hp": 1.0,
		"speed": 2.2,
		"contact_dps": 9.0,
		"armor": 0.0,
		"xp": 1,
		"radius": 0.32,
		"height": 0.55,
		"color": Color(0.85, 0.25, 0.3),
	},
	{
		"name": "Espreitador",
		"hp": 0.45,
		"speed": 4.3,
		"contact_dps": 7.0,
		"armor": 0.0,
		"xp": 1,
		"radius": 0.26,
		"height": 0.42,
		"color": Color(0.8, 0.95, 0.3),
	},
	{
		"name": "Couraçado",
		"hp": 5.0,
		"speed": 1.35,
		"contact_dps": 15.0,
		"armor": 0.35,
		"xp": 4,
		"radius": 0.5,
		"height": 0.55,
		"color": Color(0.5, 0.55, 0.68),
	},
	{
		"name": "Lançador",
		"hp": 1.2,
		"speed": 2.4,
		"contact_dps": 6.0,
		"armor": 0.0,
		"xp": 2,
		"radius": 0.32,
		"height": 0.6,
		"color": Color(0.62, 0.32, 0.95),
	},
	{
		"name": "Volátil",
		"hp": 0.9,
		"speed": 3.0,
		"contact_dps": 6.0,
		"armor": 0.0,
		"xp": 2,
		"radius": 0.42,
		"height": 0.45,
		"color": Color(1.0, 0.52, 0.12),
	},
	{
		"name": "Sentinela do Eco",
		"hp": 1.0,
		"speed": 2.4,
		"contact_dps": 24.0,
		"armor": 0.0,
		"xp": 0,
		"radius": 1.0,
		"height": 1.2,
		"color": Color(0.55, 0.12, 0.4),
	},
	{
		"name": "Tecelão",
		"hp": 2.0,
		"speed": 1.9,
		"contact_dps": 5.0,
		"armor": 0.0,
		"xp": 3,
		"radius": 0.34,
		"height": 0.75,
		"color": Color(0.35, 0.9, 0.85),
	},
	{
		"name": "Semeador",
		"hp": 1.6,
		"speed": 2.1,
		"contact_dps": 6.0,
		"armor": 0.0,
		"xp": 3,
		"radius": 0.4,
		"height": 0.4,
		"color": Color(0.55, 0.62, 0.3),
	},
]

## Elites: versões raras e mais fortes de um tipo comum, com um modificador visível.
const ELITE_NAMES := ["", "veloz", "blindado", "gerador"]
const ELITE_HP := 5.0  ## Vida multiplicada.
const ELITE_SCALE := 1.45  ## Tamanho na tela.
const ELITE_CONTACT := 1.5  ## Dano de contato multiplicado.

## Quando cada tipo começa a aparecer (segundos de partida) e o peso máximo no sorteio.
## O comum tem peso 1. Os outros entram aos poucos: o peso cresce de 0 até o máximo
## ao longo de `ramp` segundos depois da estreia.
const SCHEDULE := [
	{"kind": RAPIDO, "start": 45.0, "ramp": 200.0, "max": 0.45},
	{"kind": RESISTENTE, "start": 100.0, "ramp": 300.0, "max": 0.22},
	{"kind": ATIRADOR, "start": 150.0, "ramp": 300.0, "max": 0.15},
	{"kind": EXPLOSIVO, "start": 210.0, "ramp": 300.0, "max": 0.2},
	{"kind": TECELAO, "start": 270.0, "ramp": 300.0, "max": 0.07},
	{"kind": SEMEADOR, "start": 330.0, "ramp": 300.0, "max": 0.09},
]


static func stat(kind: int, key: String) -> Variant:
	return STATS[kind][key]


static func display_name(kind: int) -> String:
	return STATS[kind].name


static func elite_name(kind: int, modifier: int) -> String:
	return "%s %s" % [STATS[kind].name, ELITE_NAMES[modifier]]


## Peso de cada tipo no sorteio, no instante `t` da partida. O chefe nunca é sorteado.
static func spawn_weights(t: float) -> PackedFloat32Array:
	var weights := PackedFloat32Array()
	weights.resize(COUNT)
	weights[COMUM] = 1.0
	for entry in SCHEDULE:
		var ramp := clampf((t - float(entry.start)) / float(entry.ramp), 0.0, 1.0)
		if t >= float(entry.start):
			ramp = maxf(ramp, 0.08)
		weights[entry.kind] = float(entry.max) * ramp
	return weights


## Escolhe um tipo para o instante `t`. `roll` é um número de 0 a 1 (vem do sorteio).
static func pick(t: float, roll: float) -> int:
	var weights := spawn_weights(t)
	var total := 0.0
	for w in weights:
		total += w
	var target := roll * total
	for kind in COUNT:
		target -= weights[kind]
		if target < 0.0:
			return kind
	return COMUM
