class_name AutoWeapon
extends Node3D
## Arma automática: atira sozinha no inimigo mais próximo dentro do alcance.
## Os projéteis também usam arrays + MultiMesh, como os inimigos.
## Os valores base ficam nos @export. As melhorias mexem só nos modificadores abaixo,
## e os valores usados na partida (efetivos) são calculados a partir dos dois.

@export var fire_interval := 0.45 ## Segundos entre disparos, sem melhorias.
@export var attack_range := 11.0 ## Metros, sem melhorias.
@export var projectile_speed := 14.0
@export var projectile_damage := 10.0 ## Dano por projétil, sem melhorias.
@export var projectile_lifetime := 1.2 ## Segundos, sem melhorias (cresce junto com o alcance).
@export var hit_radius := 0.55
@export var spread_degrees := 10.0 ## Abertura entre projéteis quando há mais de um por disparo.
@export var max_projectiles := 256

# Modificadores das melhorias (1.0 e 0 = sem melhoria).
var damage_multiplier := 1.0
var fire_rate_multiplier := 1.0
var range_multiplier := 1.0
var extra_projectiles := 0

var player: Player
var enemies: EnemyManager
var shots_fired := 0 ## Total de projéteis disparados na partida (usado pelos testes).

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


func effective_damage() -> float:
	return projectile_damage * damage_multiplier


func effective_fire_interval() -> float:
	return fire_interval / fire_rate_multiplier


func effective_range() -> float:
	return attack_range * range_multiplier


func projectiles_per_shot() -> int:
	return 1 + extra_projectiles


func active_projectiles() -> int:
	return _positions.size()


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
	var target := enemies.nearest(origin, effective_range())
	if target == -1:
		_cooldown = 0.0
		return
	var to_target := enemies.position_of(target) - origin
	to_target.y = 0.0
	var aim := to_target.normalized()
	# Vários projéteis saem em leque, centrados no alvo.
	var shots := projectiles_per_shot()
	var lifetime := projectile_lifetime * range_multiplier
	for k in shots:
		if _positions.size() >= max_projectiles:
			break
		var offset := deg_to_rad(spread_degrees) * (k - (shots - 1) * 0.5)
		_positions.append(Vector3(origin.x, SHOT_HEIGHT, origin.z))
		_velocities.append(aim.rotated(Vector3.UP, offset) * projectile_speed)
		_life.append(lifetime)
		shots_fired += 1
	_cooldown = effective_fire_interval()


func _move_projectiles(delta: float) -> void:
	var i := _positions.size() - 1
	while i >= 0:
		_positions[i] += _velocities[i] * delta
		_life[i] -= delta
		var hit := enemies.hit_at(_positions[i], hit_radius)
		if hit != -1:
			enemies.damage(hit, effective_damage())
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
