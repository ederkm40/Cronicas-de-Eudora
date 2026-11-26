class_name AutoWeapon
extends Node3D
## Arma automática: atira sozinha no inimigo mais próximo dentro do alcance.
## Os projéteis também usam arrays + MultiMesh, como os inimigos.

@export var fire_interval := 0.45
@export var attack_range := 11.0
@export var projectile_speed := 14.0
@export var projectile_damage := 10.0
@export var projectile_lifetime := 1.2
@export var hit_radius := 0.55
@export var max_projectiles := 128

var player: Player
var enemies: EnemyManager

var _positions := PackedVector3Array()
var _velocities := PackedVector3Array()
var _life := PackedFloat32Array()
var _cooldown := 0.0
var _multimesh: MultiMesh
const SHOT_HEIGHT := 0.7


func _ready() -> void:
	var sphere := SphereMesh.new()
	sphere.radius = 0.16
	sphere.height = 0.32
	sphere.radial_segments = 8
	sphere.rings = 4
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.85, 0.3)
	sphere.material = material

	_multimesh = MultiMesh.new()
	_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_multimesh.mesh = sphere
	_multimesh.instance_count = max_projectiles
	_multimesh.visible_instance_count = 0

	var instance := MultiMeshInstance3D.new()
	instance.multimesh = _multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.custom_aabb = AABB(Vector3(-5000, -10, -5000), Vector3(10000, 20, 10000))
	add_child(instance)


func _process(delta: float) -> void:
	if player == null or not player.alive:
		return
	_try_fire(delta)
	_move_projectiles(delta)
	_draw_instances()


func _try_fire(delta: float) -> void:
	_cooldown -= delta
	if _cooldown > 0.0 or _positions.size() >= max_projectiles:
		return
	var origin := player.global_position
	var target := enemies.nearest(origin, attack_range)
	if target == -1:
		_cooldown = 0.0
		return
	var to_target := enemies.position_of(target) - origin
	to_target.y = 0.0
	_positions.append(Vector3(origin.x, SHOT_HEIGHT, origin.z))
	_velocities.append(to_target.normalized() * projectile_speed)
	_life.append(projectile_lifetime)
	_cooldown = fire_interval


func _move_projectiles(delta: float) -> void:
	var i := _positions.size() - 1
	while i >= 0:
		_positions[i] += _velocities[i] * delta
		_life[i] -= delta
		var hit := enemies.hit_at(_positions[i], hit_radius)
		if hit != -1:
			enemies.damage(hit, projectile_damage)
			_remove(i)
		elif _life[i] <= 0.0:
			_remove(i)
		i -= 1


func _remove(index: int) -> void:
	var last := _positions.size() - 1
	_positions[index] = _positions[last]
	_velocities[index] = _velocities[last]
	_life[index] = _life[last]
	_positions.resize(last)
	_velocities.resize(last)
	_life.resize(last)


func _draw_instances() -> void:
	_multimesh.visible_instance_count = _positions.size()
	for i in _positions.size():
		_multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, _positions[i]))
