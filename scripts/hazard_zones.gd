class_name HazardZones
extends Node
## Poças de cinzas deixadas pelo Semeador: áreas no chão que ferem o jogador enquanto ele
## estiver dentro. Cada poça aparece fraca (aviso, sem dano) por `arm_time` e depois fere.
## Controlam o espaço: o jogador precisa escolher por onde fugir. Arrays, sem nós por poça.

const COLOR := Color(0.55, 0.75, 0.25, 0.5)

@export var max_zones := 20
@export var radius := 1.6
@export var duration := 5.0
@export var arm_time := 0.6  ## Segundos de aviso antes de começar a ferir.
@export var damage_per_second := 12.0

var player: Player
var effects: GroundEffects
var count: int:
	get:
		return _pos.size()

var _pos := PackedVector3Array()
var _age := PackedFloat32Array()


func add(point: Vector3) -> void:
	if count >= max_zones:
		_remove(0)
	_pos.append(Vector3(point.x, 0.0, point.z))
	_age.append(0.0)
	if effects:
		effects.warn_disc(point, radius, duration, COLOR)


## Se o ponto está dentro de alguma poça já ativa.
func is_dangerous(point: Vector3) -> bool:
	for i in count:
		if _age[i] >= arm_time:
			var p := _pos[i]
			if Vector2(p.x - point.x, p.z - point.z).length() <= radius:
				return true
	return false


func _process(delta: float) -> void:
	var i := count - 1
	while i >= 0:
		_age[i] += delta
		if _age[i] >= duration:
			_remove(i)
		i -= 1
	if player and player.alive and is_dangerous(player.global_position):
		player.take_damage(damage_per_second * delta, EnemyTypes.display_name(EnemyTypes.SEMEADOR))


func _remove(index: int) -> void:
	var last := count - 1
	_pos[index] = _pos[last]
	_age[index] = _age[last]
	_pos.resize(last)
	_age.resize(last)
