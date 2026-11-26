class_name XpOrbManager
extends Node3D
## Orbes de experiência deixados pelos inimigos derrotados.
## Mesmo esquema dos inimigos: dados em arrays e um único MultiMesh para desenhar todos.
##
## Coleta por proximidade em duas etapas:
## 1. Dentro de `magnet_radius`, o orbe é puxado na direção do jogador, cada vez mais rápido.
## 2. Dentro de `collect_radius`, o orbe é coletado e a experiência é entregue.

signal collected(amount: int)

@export var max_orbs := 400
@export var magnet_radius := 3.0 ## Metros. A partir daqui o orbe voa até o jogador.
@export var collect_radius := 0.6 ## Metros. A partir daqui o orbe é coletado.
@export var magnet_speed_start := 4.0
@export var magnet_acceleration := 30.0
@export var orb_height := 0.35
@export var bob_amplitude := 0.08

var player: Player
var count: int:
	get:
		return _positions.size()
var total_collected := 0 ## Experiência coletada na partida (usado pelos testes).

var _positions := PackedVector3Array()
var _values := PackedInt32Array()
var _speeds := PackedFloat32Array() ## 0 = parado; > 0 = sendo puxado pelo jogador.
var _time := 0.0
var _multimesh: MultiMesh
var _buffer := PackedFloat32Array()


func _ready() -> void:
	# Losango: uma esfera com poucos lados vira um cristal de 8 faces.
	var gem := SphereMesh.new()
	gem.radius = 0.17
	gem.height = 0.42
	gem.radial_segments = 4
	gem.rings = 1
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.35, 0.95, 1.0)
	gem.material = material

	_multimesh = MultiMesh.new()
	_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_multimesh.mesh = gem
	_multimesh.instance_count = max_orbs
	_multimesh.visible_instance_count = 0
	_buffer.resize(max_orbs * 12)
	for i in max_orbs:
		_buffer[i * 12 + 0] = 1.0
		_buffer[i * 12 + 5] = 1.0
		_buffer[i * 12 + 10] = 1.0

	var instance := MultiMeshInstance3D.new()
	instance.multimesh = _multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.custom_aabb = AABB(Vector3(-5000, -10, -5000), Vector3(10000, 20, 10000))
	add_child(instance)


## Cria um orbe. Se já houver orbes demais, o valor é somado ao orbe mais antigo
## em vez de criar outro: a experiência nunca se perde e a memória fica limitada.
func spawn(point: Vector3, value: int = 1) -> void:
	if count >= max_orbs:
		_values[0] += value
		return
	_positions.append(Vector3(point.x, 0.0, point.z))
	_values.append(value)
	_speeds.append(0.0)


func value_of(index: int) -> int:
	return _values[index]


func position_of(index: int) -> Vector3:
	return _positions[index]


func pending_value() -> int:
	var total := 0
	for v in _values:
		total += v
	return total


func _process(delta: float) -> void:
	if player == null or not player.alive:
		return
	_time += delta
	_attract_and_collect(delta)
	_draw_instances()


func _attract_and_collect(delta: float) -> void:
	var target := player.global_position
	var magnet_sq := magnet_radius * magnet_radius
	var collect_sq := collect_radius * collect_radius
	var gained := 0
	var i := count - 1
	while i >= 0:
		var pos := _positions[i]
		var to_player := Vector3(target.x - pos.x, 0.0, target.z - pos.z)
		var d_sq := to_player.length_squared()
		if d_sq <= collect_sq:
			gained += _values[i]
			_remove(i)
		else:
			if _speeds[i] <= 0.0 and d_sq <= magnet_sq:
				_speeds[i] = magnet_speed_start
			if _speeds[i] > 0.0:
				_speeds[i] += magnet_acceleration * delta
				var dist := sqrt(d_sq)
				var step := minf(_speeds[i] * delta, dist)
				_positions[i] = pos + to_player / dist * step
		i -= 1
	if gained > 0:
		total_collected += gained
		collected.emit(gained)


func _remove(index: int) -> void:
	var last := count - 1
	_positions[index] = _positions[last]
	_values[index] = _values[last]
	_speeds[index] = _speeds[last]
	_positions.resize(last)
	_values.resize(last)
	_speeds.resize(last)


func _draw_instances() -> void:
	for i in count:
		var pos := _positions[i]
		var b := i * 12
		_buffer[b + 3] = pos.x
		_buffer[b + 7] = orb_height + sin(_time * 4.0 + float(i)) * bob_amplitude
		_buffer[b + 11] = pos.z
	_multimesh.buffer = _buffer
	_multimesh.visible_instance_count = count
