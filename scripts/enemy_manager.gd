class_name EnemyManager
extends Node3D
## Controla todos os inimigos de uma vez, sem um nó por inimigo.
## Os dados ficam em arrays e o desenho sai de um único MultiMesh (uma chamada de desenho).
## Assim dá para ter centenas de inimigos na tela no celular.

signal enemy_killed(position: Vector3)

@export var max_enemies := 300
@export var base_speed := 2.2
@export var base_hp := 20.0
@export var hp_growth_per_minute := 0.6 ## +60% de vida por minuto de partida.
@export var contact_radius := 0.8
@export var contact_dps := 9.0 ## Dano por segundo de cada inimigo encostado.
@export var max_contact_hitters := 5 ## No máximo 5 inimigos causam dano ao mesmo tempo.
@export var separation_radius := 0.75
@export var separation_strength := 4.0
@export var spawn_interval_start := 1.0
@export var spawn_interval_min := 0.12
@export var spawn_margin := 2.5 ## Distância extra fora da tela onde os inimigos nascem.

var player: Player
var camera_rig: CameraRig
var elapsed := 0.0
var count: int:
	get:
		return _positions.size()

var _positions := PackedVector3Array()
var _hp := PackedFloat32Array()
var _speed := PackedFloat32Array()
var _push := PackedVector3Array() ## Empurrão de separação calculado no último quadro.
var _spawn_timer := 0.0
var _frame := 0
var _multimesh: MultiMesh
var _buffer := PackedFloat32Array() ## 12 floats por inimigo (matriz 3x4), enviados de uma vez.
var _sorted := PackedInt64Array() ## (célula << 16) | índice, ordenado: inimigos agrupados por célula.
var _cell_start := {} ## célula -> posição em _sorted onde ela começa.
const CELL := 1.0
const BODY_HEIGHT := 0.55
const INDEX_BITS := 16
const INDEX_MASK := (1 << INDEX_BITS) - 1
const CELL_OFFSET := 1 << 20 ## Deixa as coordenadas de célula sempre positivas.


func _ready() -> void:
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.32
	capsule.height = 1.1
	capsule.radial_segments = 12
	capsule.rings = 3
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.85, 0.25, 0.3)
	capsule.material = material

	_multimesh = MultiMesh.new()
	_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_multimesh.mesh = capsule
	_multimesh.instance_count = max_enemies
	_multimesh.visible_instance_count = 0
	_buffer.resize(max_enemies * 12)
	for i in max_enemies:
		_buffer[i * 12 + 0] = 1.0
		_buffer[i * 12 + 5] = 1.0
		_buffer[i * 12 + 10] = 1.0

	var instance := MultiMeshInstance3D.new()
	instance.multimesh = _multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.custom_aabb = AABB(Vector3(-5000, -10, -5000), Vector3(10000, 20, 10000))
	add_child(instance)


func _process(delta: float) -> void:
	if player == null or not player.alive:
		return
	elapsed += delta
	_spawn(delta)
	_move(delta)
	_draw_instances()


func _spawn(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer > 0.0:
		return
	_spawn_timer = maxf(spawn_interval_min, spawn_interval_start - elapsed * 0.012)
	var batch := 1 + int(elapsed / 25.0)
	for i in batch:
		if count >= max_enemies:
			return
		_positions.append(_random_spawn_point())
		_hp.append(base_hp * (1.0 + hp_growth_per_minute * elapsed / 60.0))
		_speed.append(base_speed * randf_range(0.85, 1.15))
		_push.append(Vector3.ZERO)


## Um ponto numa elipse logo fora da área visível, ao redor do jogador.
func _random_spawn_point() -> Vector3:
	var half := camera_rig.visible_ground_half_extent()
	var angle := randf() * TAU
	var point := player.global_position \
		+ camera_rig.ground_right() * cos(angle) * (half.x + spawn_margin) \
		+ camera_rig.ground_forward() * sin(angle) * (half.y + spawn_margin)
	point.y = 0.0
	return point


func _move(delta: float) -> void:
	_frame += 1
	_build_grid()
	var target := player.global_position
	var half := camera_rig.visible_ground_half_extent()
	var too_far := (half.y + spawn_margin) * 2.0
	var sep_sq := separation_radius * separation_radius
	var hitters := 0

	for i in count:
		var pos := _positions[i]
		var to_player := Vector3(target.x - pos.x, 0.0, target.z - pos.z)
		var dist := to_player.length()

		if dist > too_far:
			_positions[i] = _random_spawn_point()
			continue
		if dist < contact_radius:
			hitters += 1

		# A separação é recalculada para metade dos inimigos a cada quadro (alternando).
		# A outra metade reaproveita o empurrão anterior: quase não se nota e corta o custo.
		if (i + _frame) % 2 == 0:
			_push[i] = _separation(i, pos, sep_sq)

		var velocity := _push[i] * separation_strength
		if dist > 0.05:
			velocity += to_player / dist * _speed[i]
		_positions[i] = pos + velocity * delta

	if hitters > 0:
		player.take_damage(mini(hitters, max_contact_hitters) * contact_dps * delta)


func _separation(i: int, pos: Vector3, sep_sq: float) -> Vector3:
	var push := Vector3.ZERO
	var cx := floori(pos.x / CELL)
	var cz := floori(pos.z / CELL)
	for x in range(cx - 1, cx + 2):
		for z in range(cz - 1, cz + 2):
			var cell := _cell_key(x, z)
			var k: int = _cell_start.get(cell, -1)
			if k == -1:
				continue
			while k < _sorted.size() and (_sorted[k] >> INDEX_BITS) == cell:
				var j := _sorted[k] & INDEX_MASK
				k += 1
				if j == i:
					continue
				var other := _positions[j]
				var away := Vector3(pos.x - other.x, 0.0, pos.z - other.z)
				var d_sq := away.length_squared()
				if d_sq < sep_sq and d_sq > 0.0001:
					var d := sqrt(d_sq)
					push += away / d * (separation_radius - d)
	return push


## Agrupa os inimigos por célula com uma ordenação nativa (rápida), sem criar arrays por célula.
func _build_grid() -> void:
	_sorted.resize(count)
	for i in count:
		var pos := _positions[i]
		_sorted[i] = (_cell_key(floori(pos.x / CELL), floori(pos.z / CELL)) << INDEX_BITS) | i
	_sorted.sort()
	_cell_start.clear()
	var previous := -1
	for k in _sorted.size():
		var cell := _sorted[k] >> INDEX_BITS
		if cell != previous:
			_cell_start[cell] = k
			previous = cell


static func _cell_key(x: int, z: int) -> int:
	return ((x + CELL_OFFSET) << 21) | (z + CELL_OFFSET)


func _draw_instances() -> void:
	for i in count:
		var pos := _positions[i]
		var b := i * 12
		_buffer[b + 3] = pos.x
		_buffer[b + 7] = pos.y + BODY_HEIGHT
		_buffer[b + 11] = pos.z
	_multimesh.buffer = _buffer
	_multimesh.visible_instance_count = count


## Índice do inimigo mais próximo dentro do alcance, ou -1.
func nearest(from: Vector3, max_range: float) -> int:
	var best := -1
	var best_sq := max_range * max_range
	for i in count:
		var d_sq := Vector2(_positions[i].x - from.x, _positions[i].z - from.z).length_squared()
		if d_sq < best_sq:
			best_sq = d_sq
			best = i
	return best


## Primeiro inimigo tocando um ponto (para projéteis), ou -1.
func hit_at(point: Vector3, radius: float) -> int:
	var r_sq := radius * radius
	for i in count:
		if Vector2(_positions[i].x - point.x, _positions[i].z - point.z).length_squared() < r_sq:
			return i
	return -1


func position_of(index: int) -> Vector3:
	return _positions[index]


## Aplica dano. Retorna true se o inimigo morreu.
func damage(index: int, amount: float) -> bool:
	_hp[index] -= amount
	if _hp[index] > 0.0:
		return false
	var where := _positions[index]
	var last := count - 1
	_positions[index] = _positions[last]
	_hp[index] = _hp[last]
	_speed[index] = _speed[last]
	_push[index] = _push[last]
	_positions.resize(last)
	_hp.resize(last)
	_speed.resize(last)
	_push.resize(last)
	enemy_killed.emit(where)
	return true
