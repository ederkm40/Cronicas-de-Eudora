extends Node3D
## Monta a partida em código: ambiente, chão, jogador, câmera, inimigos, arma e interface.
## Tudo é criado aqui para o projeto ser 100% texto e fácil de editar por IA.

const GROUND_SIZE := 120.0
const GRID_CELL := 2.0

var player: Player
var camera_rig: CameraRig
var enemies: EnemyManager
var weapon: AutoWeapon
var hud: Hud
var joystick: FloatingJoystick

var _ground: MeshInstance3D
var _elapsed := 0.0
var _kills := 0
var _over := false


func _ready() -> void:
	_build_environment()
	_build_ground()

	player = Player.new()
	add_child(player)

	camera_rig = CameraRig.new()
	add_child(camera_rig)
	camera_rig.target = player
	camera_rig.snap_to_target()
	player.camera_rig = camera_rig

	enemies = EnemyManager.new()
	enemies.player = player
	enemies.camera_rig = camera_rig
	add_child(enemies)
	enemies.enemy_killed.connect(_on_enemy_killed)

	weapon = AutoWeapon.new()
	weapon.player = player
	weapon.enemies = enemies
	add_child(weapon)

	var ui := CanvasLayer.new()
	add_child(ui)
	joystick = FloatingJoystick.new()
	ui.add_child(joystick)
	hud = Hud.new()
	ui.add_child(hud)
	hud.restart_requested.connect(_on_restart)
	player.joystick = joystick
	player.died.connect(_on_player_died)


func _process(delta: float) -> void:
	if not _over:
		_elapsed += delta
	var p := player.global_position
	_ground.global_position = Vector3(snappedf(p.x, GRID_CELL), 0.0, snappedf(p.z, GRID_CELL))
	hud.update_stats(_elapsed, _kills, player.hp, player.max_hp, enemies.count)


func _on_enemy_killed(_where: Vector3) -> void:
	_kills += 1


func _on_player_died() -> void:
	_over = true
	joystick.set_enabled(false)
	hud.show_game_over(_elapsed, _kills)


func _on_restart() -> void:
	get_tree().reload_current_scene()


func _build_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.07, 0.06, 0.09)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.5, 0.65)
	env.ambient_light_energy = 0.6
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55.0, 30.0, 0.0)
	sun.light_energy = 1.1
	sun.light_color = Color(1.0, 0.93, 0.85)
	sun.shadow_enabled = false
	add_child(sun)


## Chão com grade desenhada por shader. Ele acompanha o jogador em passos do tamanho
## da grade, então parece infinito sem precisar de um chão gigante.
func _build_ground() -> void:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
uniform vec4 base_color : source_color = vec4(0.14, 0.13, 0.17, 1.0);
uniform vec4 line_color : source_color = vec4(0.24, 0.22, 0.29, 1.0);
uniform float cell = 2.0;
varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 coord = world_pos.xz / cell;
	vec2 grid = abs(fract(coord - 0.5) - 0.5) / fwidth(coord);
	float line = 1.0 - min(min(grid.x, grid.y), 1.0);
	ALBEDO = mix(base_color.rgb, line_color.rgb, line);
	ROUGHNESS = 1.0;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("cell", GRID_CELL)

	var plane := PlaneMesh.new()
	plane.size = Vector2(GROUND_SIZE, GROUND_SIZE)
	_ground = MeshInstance3D.new()
	_ground.mesh = plane
	_ground.material_override = material
	_ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_ground)
