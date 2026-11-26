class_name EnemyProjectiles
extends Node3D
## Projéteis disparados pelos inimigos (Lançador e Sentinela) contra o jogador.
## Arrays + um MultiMesh, como os projéteis do jogador. Durante a esquiva, eles atravessam.

const HEIGHT := 0.75

@export var max_projectiles := 240
@export var hit_radius := 0.5  ## Distância até o centro do jogador para acertar.

var player: Player
var count: int:
	get:
		return _positions.size()

var _positions := PackedVector3Array()
var _velocities := PackedVector3Array()
var _life := PackedFloat32Array()
var _damage := PackedFloat32Array()
var _source := PackedByteArray()  ## Tipo de inimigo que disparou (para as estatísticas).
var _multimesh: MultiMesh
var _buffer := PackedFloat32Array()


func _ready() -> void:
	var orb := SphereMesh.new()
	orb.radius = 0.2
	orb.height = 0.4
	orb.radial_segments = 10
	orb.rings = 5
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.95, 0.4, 1.0)
	orb.material = material

	_multimesh = MultiMesh.new()
	_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_multimesh.mesh = orb
	_multimesh.instance_count = max_projectiles
	_multimesh.visible_instance_count = 0
	_buffer.resize(max_projectiles * 12)
	for i in max_projectiles:
		_buffer[i * 12 + 0] = 1.0
		_buffer[i * 12 + 5] = 1.0
		_buffer[i * 12 + 10] = 1.0
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = _multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.custom_aabb = AABB(Vector3(-5000, -10, -5000), Vector3(10000, 20, 10000))
	add_child(instance)


## Dispara um projétil. Retorna false se o limite estiver cheio.
func fire(
	from: Vector3, direction: Vector3, speed: float, damage: float, life: float, source: int
) -> bool:
	if count >= max_projectiles:
		return false
	var flat := Vector3(direction.x, 0.0, direction.z).normalized()
	_positions.append(Vector3(from.x, HEIGHT, from.z))
	_velocities.append(flat * speed)
	_life.append(life)
	_damage.append(damage)
	_source.append(source)
	return true


func position_of(index: int) -> Vector3:
	return _positions[index]


func clear() -> void:
	for array in [_positions, _velocities, _life, _damage, _source]:
		array.resize(0)


func _process(delta: float) -> void:
	if player == null or not player.alive:
		return
	var target := player.global_position
	var r_sq := hit_radius * hit_radius
	var i := count - 1
	while i >= 0:
		_positions[i] += _velocities[i] * delta
		_life[i] -= delta
		var p := _positions[i]
		var d_sq := Vector2(p.x - target.x, p.z - target.z).length_squared()
		if d_sq < r_sq and not player.is_invulnerable():
			player.take_damage(_damage[i], EnemyTypes.display_name(_source[i]))
			_remove(i)
		elif _life[i] <= 0.0:
			_remove(i)
		i -= 1
	_draw_instances()


func _remove(index: int) -> void:
	var last := count - 1
	_positions[index] = _positions[last]
	_velocities[index] = _velocities[last]
	_life[index] = _life[last]
	_damage[index] = _damage[last]
	_source[index] = _source[last]
	for array in [_positions, _velocities, _life, _damage, _source]:
		array.resize(last)


func _draw_instances() -> void:
	for i in count:
		var b := i * 12
		_buffer[b + 3] = _positions[i].x
		_buffer[b + 7] = _positions[i].y
		_buffer[b + 11] = _positions[i].z
	_multimesh.buffer = _buffer
	_multimesh.visible_instance_count = count
