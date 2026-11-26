class_name CombatFeedback
extends Node3D
## Números de dano que sobem e somem. Só aparecem nos golpes que importam (chefe e elites),
## para não cobrir a tela numa horda. Um conjunto fixo de Label3D é reaproveitado: quando
## todos estão em uso, o mais antigo é trocado. Desligável nas configurações.

const POOL := 24
const LIFETIME := 0.7
const RISE := 1.4  ## Metros que o número sobe.

var enabled := true  ## Configuração "Números de dano".
var shown := 0  ## Números mostrados na partida (usado pelos testes).

var _labels: Array[Label3D] = []
var _age := PackedFloat32Array()
var _origin := PackedVector3Array()
var _next := 0


func _ready() -> void:
	for i in POOL:
		var label := Label3D.new()
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		label.fixed_size = true
		label.pixel_size = 0.0018
		label.font_size = 40
		label.outline_size = 10
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.visible = false
		label.top_level = true
		add_child(label)
		_labels.append(label)
	_age.resize(POOL)
	_origin.resize(POOL)
	_age.fill(LIFETIME)


## Mostra `amount` em `where`. `strong` deixa o número maior (golpe no ponto fraco).
func number(where: Vector3, amount: float, color: Color, strong: bool = false) -> void:
	if not enabled or amount < 1.0:
		return
	var label := _labels[_next]
	_age[_next] = 0.0
	_origin[_next] = where + Vector3(randf_range(-0.3, 0.3), 1.6, randf_range(-0.3, 0.3))
	label.text = str(roundi(amount))
	label.modulate = color
	label.font_size = 54 if strong else 40
	label.global_position = _origin[_next]
	label.visible = true
	_next = (_next + 1) % POOL
	shown += 1


func active_count() -> int:
	var total := 0
	for label in _labels:
		if label.visible:
			total += 1
	return total


func _process(delta: float) -> void:
	for i in POOL:
		if _age[i] >= LIFETIME:
			continue
		_age[i] += delta
		var t := _age[i] / LIFETIME
		var label := _labels[i]
		if t >= 1.0:
			label.visible = false
			continue
		label.global_position = _origin[i] + Vector3(0.0, RISE * ease(t, 0.4), 0.0)
		label.modulate.a = 1.0 - t * t
