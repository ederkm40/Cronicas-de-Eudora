class_name OrbitBlades
extends Node3D
## Lâmina orbital: lâminas que giram em volta do jogador e cortam os inimigos que tocam.
## Cada inimigo só pode ser cortado de novo depois de `HIT_COOLDOWN` segundos, mesmo que
## várias lâminas passem por ele no mesmo instante (a recarga fica no EnemyManager).
## Mais lâminas = mais cortes por volta, com o mesmo custo de colisão por quadro.

const MAX_BLADES := 6
const HIT_REACH := 0.5  ## Meia lâmina: distância do centro da lâmina que ainda corta.
const HIT_COOLDOWN := 0.35
const HEIGHT := 0.6
const TRAIL_OFFSET := 0.28  ## Ângulo (rad) do rastro atrás de cada lâmina.
const BLADE_COLOR := Color(0.78, 0.95, 1.0, 1.0)
const TRAIL_COLOR := Color(0.55, 0.85, 1.0, 0.35)

var player: Player
var enemies: EnemyManager
var effects: GroundEffects
var level := 0
var damage_multiplier := 1.0
var hits := 0  ## Cortes na partida (usado pelos testes).

var _angle := 0.0
var _multimesh: MultiMesh
var _orbit: MeshInstance3D


func _ready() -> void:
	var blade := PrismMesh.new()
	blade.size = Vector3(0.22, 0.95, 0.08)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	blade.material = material
	_multimesh = MultiMesh.new()
	_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	_multimesh.use_colors = true
	_multimesh.mesh = blade
	_multimesh.instance_count = MAX_BLADES * 2
	_multimesh.visible_instance_count = 0
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = _multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.custom_aabb = AABB(Vector3(-5000, -10, -5000), Vector3(10000, 20, 10000))
	add_child(instance)

	# Linha fina mostrando a órbita.
	var ring := TorusMesh.new()
	ring.inner_radius = 0.97
	ring.outer_radius = 1.0
	ring.rings = 48
	ring.ring_segments = 3
	var ring_material := StandardMaterial3D.new()
	ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.albedo_color = Color(0.6, 0.9, 1.0, 0.16)
	ring.material = ring_material
	_orbit = MeshInstance3D.new()
	_orbit.mesh = ring
	_orbit.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_orbit.top_level = true
	add_child(_orbit)
	visible = level > 0


func set_level(value: int) -> void:
	level = clampi(value, 0, WeaponCatalog.max_level(WeaponCatalog.BLADE))
	visible = level > 0


func _base(key: String) -> float:
	return float(WeaponCatalog.stats(WeaponCatalog.BLADE, level).get(key, 0.0))


func blade_count() -> int:
	return mini(int(_base("count")), MAX_BLADES)


func effective_damage() -> float:
	return _base("damage") * damage_multiplier


func orbit_radius() -> float:
	return _base("radius")


func orbit_speed() -> float:
	return _base("speed")


## Posição de cada lâmina agora (no chão, na altura do jogador).
func blade_positions() -> PackedVector3Array:
	var positions := PackedVector3Array()
	if player == null:
		return positions
	var center := player.global_position
	var n := blade_count()
	for k in n:
		var a := _angle + TAU * float(k) / float(n)
		positions.append(center + Vector3(cos(a), 0.0, sin(a)) * orbit_radius())
	return positions


func _process(delta: float) -> void:
	if level == 0 or player == null or not player.alive:
		return
	_angle = fmod(_angle + orbit_speed() * delta, TAU)
	var blades := blade_positions()
	_cut(blades)
	_draw_blades()


func _cut(blades: PackedVector3Array) -> void:
	var amount := effective_damage()
	var center := player.global_position
	# Candidatos: só quem está perto do anel (uma passada pela lista por quadro).
	for index in enemies.indices_in_radius(center, orbit_radius() + HIT_REACH):
		if not enemies.blade_ready(index):
			continue
		var p := enemies.position_of(index)
		var reach := HIT_REACH + enemies.body_radius(index)
		for b in blades:
			if Vector2(p.x - b.x, p.z - b.z).length_squared() < reach * reach:
				enemies.set_blade_cooldown(index, HIT_COOLDOWN)
				hits += 1
				if effects:
					effects.burst(p, 0.15, 0.6, 0.15, Color(0.7, 0.95, 1.0, 0.8))
				enemies.damage(index, amount, WeaponCatalog.BLADE)
				break


func _draw_blades() -> void:
	var center := player.global_position
	var n := blade_count()
	var r := orbit_radius()
	for k in n:
		var a := _angle + TAU * float(k) / float(n)
		_set_blade(k * 2, center, a, r, BLADE_COLOR)
		_set_blade(k * 2 + 1, center, a - TRAIL_OFFSET, r, TRAIL_COLOR)
	_multimesh.visible_instance_count = n * 2
	_orbit.global_position = Vector3(center.x, 0.05, center.z)
	_orbit.scale = Vector3(r, 0.3, r)


func _set_blade(slot: int, center: Vector3, angle: float, r: float, color: Color) -> void:
	var where := center + Vector3(cos(angle), 0.0, sin(angle)) * r
	where.y = HEIGHT
	# A lâmina deita no plano do chão e aponta para fora, girando no sentido da órbita.
	var basis := Basis(Vector3.UP, -angle) * Basis(Vector3.RIGHT, -PI * 0.5)
	_multimesh.set_instance_transform(slot, Transform3D(basis, where))
	_multimesh.set_instance_color(slot, color)
