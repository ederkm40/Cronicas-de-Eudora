class_name EventDirector
extends Node3D
## Acontecimentos da partida, para cada partida ter momentos diferentes:
##
## - **Elites**: a partir de 2:00, de tempos em tempos, um inimigo elite (maior, dourado,
##   8x a vida) com um modificador visível: veloz, blindado ou gerador (chama Errantes).
##   Derrotá-lo dá um orbe grande e cura (main.gd).
## - **Fenda do Eco** (risco e recompensa): um círculo aparece perto do jogador. Ficar dentro
##   dele por `rift_channel` segundos (somados) dentro do prazo dá um nível extra de escolha.
##   Enquanto o jogador está dentro, as hordas vêm 2x mais rápido.
## - **Maré e Calmaria** (ritmo): uma maré com hordas 2,5x mais rápidas por 15 s, seguida de
##   10 s de calmaria (hordas a 25%), um respiro para coletar orbes.
##
## Tudo para quando começa o encontro final. O diretor define o ritmo das hordas
## (`EnemyManager.spawn_rate_multiplier`) somando os seus efeitos ao do encontro.

signal announced(text: String)
signal rift_completed(position: Vector3)
signal rift_failed

enum Tide { NORMAL, MARE, CALMARIA }

const RIFT_COLOR := Color(0.65, 0.4, 1.0)

@export_group("Elites")
@export var first_elite := 120.0
@export var elite_interval := 75.0
@export_group("Fenda do Eco")
@export var first_rift := 150.0
@export var rift_interval := 165.0
@export var rift_radius := 2.4
@export var rift_channel := 6.0  ## Segundos dentro da fenda para completar.
@export var rift_window := 25.0  ## Prazo para completar.
@export var rift_spawn_boost := 2.0
@export_group("Maré e Calmaria")
@export var first_tide := 240.0
@export var tide_interval := 180.0
@export var tide_duration := 15.0
@export var tide_rate := 2.5
@export var calm_duration := 10.0
@export var calm_rate := 0.25

var enemies: EnemyManager
var player: Player
var camera_rig: CameraRig
var effects: GroundEffects
var stats: RunStats
var stopped := false  ## Encontro final ou fim de partida: nada novo acontece.
var base_rate := 1.0  ## Ritmo das hordas sem eventos (o encontro final usa 0,3).
var tide := Tide.NORMAL
var rift_active := false
var rift_progress := 0.0  ## Segundos já passados dentro da fenda.
var rift_position := Vector3.ZERO

var _next_elite := 0.0
var _next_rift := 0.0
var _next_tide := 0.0
var _rift_left := 0.0
var _tide_left := 0.0
var _rift_disc: MeshInstance3D
var _rift_fill: MeshInstance3D
var _rift_material: StandardMaterial3D


func _ready() -> void:
	_next_elite = first_elite
	_next_rift = first_rift
	_next_tide = first_tide
	_rift_disc = _make_disc(Color(RIFT_COLOR, 0.22), 0.02)
	_rift_fill = _make_disc(Color(RIFT_COLOR, 0.45), 0.03)
	_rift_material = _rift_disc.material_override
	_rift_disc.visible = false
	_rift_fill.visible = false


func _make_disc(color: Color, height: float) -> MeshInstance3D:
	var disc := CylinderMesh.new()
	disc.top_radius = 1.0
	disc.bottom_radius = 1.0
	disc.height = 0.01
	disc.radial_segments = 40
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	var mesh := MeshInstance3D.new()
	mesh.mesh = disc
	mesh.material_override = material
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh.position.y = height
	mesh.top_level = true
	add_child(mesh)
	return mesh


func _process(delta: float) -> void:
	if enemies == null or player == null or not player.alive:
		return
	var t := enemies.elapsed
	# Sem hordas automáticas (testes controlados), também não há eventos novos.
	if not stopped and enemies.spawning_enabled:
		if t >= _next_elite:
			_next_elite = t + elite_interval
			spawn_elite()
		if not rift_active and t >= _next_rift:
			_next_rift = t + rift_interval
			start_rift()
		if tide == Tide.NORMAL and t >= _next_tide:
			_next_tide = t + tide_interval
			start_tide()
	_update_rift(delta)
	_update_tide(delta)
	var rate := base_rate
	if tide == Tide.MARE:
		rate *= tide_rate
	elif tide == Tide.CALMARIA:
		rate *= calm_rate
	if rift_active and _inside_rift():
		rate *= rift_spawn_boost
	enemies.spawn_rate_multiplier = rate


## Encontro final: cancela a fenda e a maré e não começa nada novo.
func stop() -> void:
	stopped = true
	if rift_active:
		_end_rift(false)
	tide = Tide.NORMAL


# ---------------------------------------------------------------- elites


## Cria um elite de um tipo já presente na partida, na borda da tela, vindo para o jogador.
func spawn_elite() -> int:
	var kind := EnemyTypes.pick(enemies.elapsed, randf())
	var modifier := 1 + randi() % 3
	var half := camera_rig.visible_ground_half_extent()
	var angle := randf() * TAU
	var point := (
		player.global_position
		+ camera_rig.ground_right() * cos(angle) * half.x * 0.85
		+ camera_rig.ground_forward() * sin(angle) * half.y * 0.6
	)
	var hp := enemies.base_hp * float(EnemyTypes.STATS[kind].hp) * enemies.time_hp_multiplier()
	var index := enemies.spawn_at(point, hp, kind, modifier)
	if index != -1:
		if effects:
			effects.burst(point, 0.4, 2.2, 0.6, Color(1.0, 0.85, 0.3, 0.9))
		announced.emit("Elite: %s!" % EnemyTypes.elite_name(kind, modifier))
	return index


# ---------------------------------------------------------------- Fenda do Eco


func start_rift() -> void:
	var angle := randf() * TAU
	var half := camera_rig.visible_ground_half_extent()
	var reach := minf(6.0, half.x - rift_radius)
	rift_position = player.global_position + Vector3(cos(angle), 0.0, sin(angle)) * reach
	rift_position.y = 0.0
	rift_active = true
	rift_progress = 0.0
	_rift_left = rift_window
	_rift_disc.visible = true
	_rift_fill.visible = true
	_rift_disc.global_position = Vector3(rift_position.x, 0.02, rift_position.z)
	_rift_fill.global_position = Vector3(rift_position.x, 0.03, rift_position.z)
	_rift_disc.scale = Vector3(rift_radius, 1.0, rift_radius)
	announced.emit("Uma Fenda do Eco se abriu! Fique dentro dela para ganhar uma escolha.")


func _inside_rift() -> bool:
	var p := player.global_position
	return Vector2(p.x - rift_position.x, p.z - rift_position.z).length() <= rift_radius


func _update_rift(delta: float) -> void:
	if not rift_active:
		return
	_rift_left -= delta
	if _inside_rift():
		rift_progress += delta
	var fill := clampf(rift_progress / rift_channel, 0.0, 1.0)
	var r := maxf(rift_radius * fill, 0.05)
	_rift_fill.scale = Vector3(r, 1.0, r)
	_rift_material.albedo_color.a = 0.16 + 0.1 * sin(enemies.elapsed * 5.0)
	if rift_progress >= rift_channel:
		_end_rift(true)
	elif _rift_left <= 0.0:
		_end_rift(false)


func _end_rift(success: bool) -> void:
	rift_active = false
	_rift_disc.visible = false
	_rift_fill.visible = false
	if stats:
		if success:
			stats.rifts_completed += 1
		else:
			stats.rifts_failed += 1
	if success:
		if effects:
			effects.burst(rift_position, 0.5, rift_radius * 1.8, 0.7, Color(RIFT_COLOR, 0.95))
		rift_completed.emit(rift_position)
	else:
		rift_failed.emit()


func rift_time_left() -> float:
	return _rift_left if rift_active else 0.0


# ---------------------------------------------------------------- Maré e Calmaria


func start_tide() -> void:
	tide = Tide.MARE
	_tide_left = tide_duration
	if stats:
		stats.tides += 1
	if camera_rig:
		camera_rig.shake(0.25, 0.5)
	announced.emit("A maré da horda está subindo!")


func _update_tide(delta: float) -> void:
	if tide == Tide.NORMAL:
		return
	_tide_left -= delta
	if _tide_left > 0.0:
		return
	if tide == Tide.MARE:
		tide = Tide.CALMARIA
		_tide_left = calm_duration
		announced.emit("Calmaria: aproveite para respirar.")
	else:
		tide = Tide.NORMAL
