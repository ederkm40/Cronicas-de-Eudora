extends Node3D
## Monta a partida em código: ambiente, chão, jogador, câmera, inimigos, armas, orbes,
## efeitos e interface. Tudo é criado aqui para o projeto ser 100% texto e fácil de editar.
##
## Ciclo da partida:
## inimigo morre -> deixa orbe -> jogador coleta -> Progression soma XP -> ao subir de nível,
## a partida pausa e o LevelUpPanel mostra até 3 ofertas (arma nova, evolução de arma ou
## melhoria) -> a escolhida é aplicada -> a partida continua.
## Aos 10 minutos começa o encontro final: o Sentinela do Eco aparece e só derrotá-lo vence
## a partida. Morrer termina a partida em derrota. Nos dois casos a tela de resultados
## mostra as estatísticas reais, soma os Ecos e salva a progressão permanente.

const GROUND_SIZE := 120.0
const GRID_CELL := 2.0

@export var encounter_time := 600.0  ## Segundos de partida até o chefe aparecer.
@export var encounter_spawn_rate := 0.5  ## Ritmo das hordas durante o encontro final.
@export var encounter_warning := 10.0  ## Segundos de aviso antes do encontro.

var player: Player
var camera_rig: CameraRig
var enemies: EnemyManager
var weapon: AutoWeapon
var aura: AuraWeapon
var blades: OrbitBlades
var hud: Hud
var joystick: FloatingJoystick
var orbs: XpOrbManager
var progression: Progression
var upgrades: Upgrades
var arsenal: Arsenal
var offers: LevelUpOffers
var level_up_panel: LevelUpPanel
var results: ResultsScreen
var effects: GroundEffects
var enemy_projectiles: EnemyProjectiles
var boss: BossController
var stats: RunStats
var meta: MetaProgress
var xp_per_enemy := 1  ## Multiplicador da XP de cada inimigo (cada tipo tem a sua).
var ecos_earned := 0

var _ground: MeshInstance3D
var _elapsed := 0.0
var _kills := 0
var _over := false
var _won := false
var _encounter_started := false
var _warned := false


func _ready() -> void:
	meta = MetaProgress.load_from()
	stats = RunStats.new()
	_build_environment()
	_build_ground()

	effects = GroundEffects.new()
	add_child(effects)

	player = Player.new()
	player.effects = effects
	add_child(player)

	camera_rig = CameraRig.new()
	add_child(camera_rig)
	camera_rig.target = player
	camera_rig.snap_to_target()
	player.camera_rig = camera_rig

	enemy_projectiles = EnemyProjectiles.new()
	enemy_projectiles.player = player

	enemies = EnemyManager.new()
	enemies.player = player
	enemies.camera_rig = camera_rig
	enemies.projectiles = enemy_projectiles
	enemies.effects = effects
	enemies.stats = stats
	add_child(enemies)
	enemies.enemy_killed.connect(_on_enemy_killed)
	enemies.boss_died.connect(_on_boss_died)
	add_child(enemy_projectiles)

	boss = BossController.new()
	boss.enemies = enemies
	boss.player = player
	boss.effects = effects
	boss.projectiles = enemy_projectiles
	add_child(boss)
	boss.phase_changed.connect(_on_boss_phase)

	weapon = AutoWeapon.new()
	weapon.player = player
	weapon.enemies = enemies
	add_child(weapon)
	aura = AuraWeapon.new()
	aura.player = player
	aura.enemies = enemies
	add_child(aura)
	blades = OrbitBlades.new()
	blades.player = player
	blades.enemies = enemies
	blades.effects = effects
	add_child(blades)

	orbs = XpOrbManager.new()
	orbs.player = player
	orbs.magnet_radius *= meta.magnet_multiplier()
	add_child(orbs)

	progression = Progression.new()
	upgrades = Upgrades.new()
	upgrades.aura = aura
	upgrades.blades = blades
	upgrades.meta_damage_multiplier = meta.damage_multiplier()
	upgrades.meta_hp_multiplier = meta.hp_multiplier()
	arsenal = Arsenal.new()
	offers = LevelUpOffers.new(upgrades, arsenal, player)
	offers.rerolls_left += meta.extra_rerolls()
	orbs.collected.connect(progression.add_xp)
	orbs.collected.connect(func(amount: int) -> void: stats.orbs_xp += amount)

	var ui := CanvasLayer.new()
	add_child(ui)
	joystick = FloatingJoystick.new()
	ui.add_child(joystick)
	hud = Hud.new()
	ui.add_child(hud)
	level_up_panel = LevelUpPanel.new()
	ui.add_child(level_up_panel)
	level_up_panel.chosen.connect(_on_upgrade_chosen)
	level_up_panel.reroll_requested.connect(_on_reroll)
	level_up_panel.banish_requested.connect(_on_banish)
	results = ResultsScreen.new()
	ui.add_child(results)
	results.restart_requested.connect(_on_restart)

	player.joystick = joystick
	joystick.dodge_requested.connect(player.dodge_from_screen)
	player.died.connect(_on_player_died)
	player.damaged.connect(stats.record_damage_taken)
	player.dodged.connect(func(_direction: Vector3) -> void: stats.dodges += 1)
	_sync_weapons()
	player.hp = player.max_hp  # começa com a vida cheia, já com o bônus permanente
	_update_hud()
	if OS.has_feature("web"):
		add_child(WebBridge.new())


func _process(delta: float) -> void:
	if not _over:
		_elapsed += delta
		_update_encounter()
		# Abre a escolha no começo do quadro, antes de inimigos e projéteis se moverem.
		if progression.pending_level_ups > 0 and player.alive and not level_up_panel.is_open():
			_open_level_up()
	var p := player.global_position
	_ground.global_position = Vector3(snappedf(p.x, GRID_CELL), 0.0, snappedf(p.z, GRID_CELL))
	_update_hud()


func is_over() -> bool:
	return _over


func is_victory() -> bool:
	return _won


func elapsed() -> float:
	return _elapsed


func kills() -> int:
	return _kills


func encounter_started() -> bool:
	return _encounter_started


func _update_hud() -> void:
	hud.update_stats(
		_elapsed,
		_kills,
		player.hp,
		player.max_hp,
		enemies.count,
		progression.level,
		progression.xp,
		progression.xp_to_next()
	)
	hud.set_dodge(player.dodge_charge())
	var index := enemies.boss_index()
	if index != -1:
		var title := EnemyTypes.display_name(EnemyTypes.CHEFE)
		if boss.phase == 2:
			title += " · fúria"
		hud.set_boss(true, enemies.hp_of(index) / enemies.max_hp_of(index), title)
	elif hud.boss_bar_visible():
		hud.set_boss(false)


# ---------------------------------------------------------------- encontro final


func _update_encounter() -> void:
	if _encounter_started:
		return
	if not _warned and _elapsed >= encounter_time - encounter_warning:
		_warned = true
		hud.show_banner("O encontro final começa em %d segundos!" % int(encounter_warning), 4.0)
	if _elapsed >= encounter_time:
		start_encounter()


## Começa o encontro final: o chefe surge na borda da tela, acima do jogador.
func start_encounter() -> void:
	if _encounter_started or _over:
		return
	_encounter_started = true
	var half := camera_rig.visible_ground_half_extent()
	var point := player.global_position + camera_rig.ground_forward() * maxf(half.y - 2.0, 4.0)
	boss.spawn(point)
	enemies.spawn_rate_multiplier = encounter_spawn_rate
	stats.boss_spawned_at = _elapsed
	hud.show_banner("O Sentinela do Eco despertou!\nDerrote-o para vencer.", 4.0)


func _on_boss_phase(_phase: int) -> void:
	hud.show_banner("O Sentinela se enfurece!", 2.5)


func _on_boss_died(where: Vector3) -> void:
	stats.bosses_defeated += 1
	stats.boss_defeated_at = _elapsed
	effects.burst(where, 0.5, 6.0, 1.0, Color(1.0, 0.85, 0.4, 0.95))
	_finish(true)


# ---------------------------------------------------------------- abates e level-up


func _on_enemy_killed(where: Vector3, kind: int, xp: int) -> void:
	_kills += 1
	if xp > 0:
		orbs.spawn(where, xp * xp_per_enemy)


## Pausa toda a simulação (inimigos, projéteis, orbes, hordas, tempo) e mostra as escolhas.
func _open_level_up() -> void:
	var choices := offers.roll_for_level_up()
	if choices.is_empty():
		# Tudo no limite: o nível conta, mas não há o que escolher. Recupera vida.
		progression.consume_pending_level_up()
		player.heal(Upgrades.VITALITY_HEAL)
		return
	get_tree().paused = true
	joystick.set_enabled(false)
	level_up_panel.open(progression.level - progression.pending_level_ups + 1, choices, offers)
	_update_hud()


func _on_upgrade_chosen(id: StringName) -> void:
	apply_offer(id)
	progression.consume_pending_level_up()
	if progression.pending_level_ups > 0 and player.alive:
		_open_level_up()
		return
	get_tree().paused = false
	joystick.set_enabled(true)
	_update_hud()


func _on_reroll() -> void:
	level_up_panel.show_choices(offers.reroll(level_up_panel.choice_ids()))


func _on_banish(index: int) -> void:
	var ids := level_up_panel.choice_ids()
	if index < 0 or index >= ids.size():
		return
	var replacement := offers.banish(ids[index], ids)
	if replacement == &"" and not offers.is_banished(ids[index]):
		return  # bloqueio recusado
	if replacement != &"":
		ids[index] = replacement
	else:
		ids.remove_at(index)
	level_up_panel.show_choices(ids)


## Aplica uma oferta (arma nova, evolução ou melhoria) e atualiza as armas na hora.
func apply_offer(id: StringName) -> bool:
	var applied := offers.apply(id, player, weapon)
	_sync_weapons()
	return applied


## Liga cada arma ao nível que ela tem no Arsenal e recalcula os bônus.
func _sync_weapons() -> void:
	aura.set_level(arsenal.level(WeaponCatalog.AURA))
	blades.set_level(arsenal.level(WeaponCatalog.BLADE))
	upgrades.refresh(player, weapon)
	var names: Array[String] = []
	for id in arsenal.owned_ids():
		var label: String = WeaponCatalog.definition(id).name
		if WeaponCatalog.max_level(id) > 1:
			label += " %d" % arsenal.level(id)
		names.append(label)
	hud.set_weapons(" · ".join(names))


# ---------------------------------------------------------------- fim de partida


func _on_player_died() -> void:
	_finish(false)


func _finish(won: bool) -> void:
	if _over:
		return
	_over = true
	_won = won
	player.controls_enabled = false
	joystick.set_enabled(false)
	level_up_panel.close()
	hud.set_boss(false)
	boss.stop()
	if won:
		get_tree().paused = true  # congela a horda atrás da tela de vitória
	ecos_earned = meta.record_run(_elapsed, _kills, stats.bosses_defeated, won)
	meta.save()
	results.show_results(result_data(), meta)


## Resumo da partida, só com números contados de verdade.
func result_data() -> Dictionary:
	var weapons: Array[Dictionary] = []
	for id in arsenal.owned_ids():
		weapons.append(
			{
				"id": id,
				"name": WeaponCatalog.definition(id).name,
				"level": arsenal.level(id),
				"damage": stats.damage_of(id),
				"kills": stats.kills_of(id),
			}
		)
	var upgrade_lines: Array[String] = []
	for id in Upgrades.all_ids():
		if upgrades.stacks(id) > 0:
			var definition := Upgrades.definition(id)
			upgrade_lines.append(
				"%s %d/%d" % [definition.name, upgrades.stacks(id), int(definition.max)]
			)
	return {
		"won": _won,
		"time": _elapsed,
		"level": progression.level,
		"kills": _kills,
		"damage_dealt": stats.total_damage(),
		"damage_taken": stats.damage_taken,
		"dodges": stats.dodges,
		"bosses": stats.bosses_defeated,
		"boss_seconds": stats.boss_fight_seconds(),
		"weapons": weapons,
		"upgrades": upgrade_lines,
		"ecos_earned": ecos_earned,
	}


func _on_restart() -> void:
	get_tree().paused = false
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
