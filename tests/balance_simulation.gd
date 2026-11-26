extends SceneTree
## Simulações de balanceamento (telemetria do combate). Não fazem parte do CI por padrão:
## servem para medir e comparar. Os números impressos vêm da partida simulada, sem estimativa.
##
## Uso:
##   godot --headless --path . --fixed-fps 60 --script res://tests/balance_simulation.gd -- \
##     --modo=partida --semente=1
## Modos:
##   --modo=dps      compara as armas contra a mesma horda (jogador invulnerável, 60 s por carga)
##   --modo=partida  partida completa com um piloto que foge, coleta orbes, esquiva e escolhe
##                   ofertas; termina na vitória, na derrota ou em --segundos (padrão 900)
##   --modo=chefe    começa no encontro final com uma build típica de 10 minutos e mede
##                   o tempo para derrotar o chefe e o dano recebido
## Outras opções: --semente=N, --escolha=prioridade|aleatoria, --sem-esquiva
## Sai com código 1 só se algo quebrar (partida presa, erro de lógica), não por balanceamento.

const DPS_SECONDS := 60.0
const DPS_LOADOUTS := [
	["Raio (nível 1)", {}],
	["Raio + Aura 1", {&"aura_de_brasas": 1}],
	["Raio + Aura 3", {&"aura_de_brasas": 3}],
	["Raio + Aura 5", {&"aura_de_brasas": 5}],
	["Raio + Lâmina 1", {&"lamina_orbital": 1}],
	["Raio + Lâmina 3", {&"lamina_orbital": 3}],
	["Raio + Lâmina 5", {&"lamina_orbital": 5}],
	["Raio + Aura 5 + Lâmina 5", {&"aura_de_brasas": 5, &"lamina_orbital": 5}],
]
## Build típica de 10 minutos para o modo chefe (níveis medidos no modo partida).
const BOSS_BUILD := {
	&"aura_de_brasas": 4,
	&"lamina_orbital": 4,
	&"poder_arcano": 4,
	&"cadencia": 3,
	&"nucleo_vital": 2,
	&"projetil_adicional": 2,
	&"campo_de_ruptura": 1,
	&"passos_ligeiros": 1,
}
const PRIORITY := [
	&"aura_de_brasas",
	&"lamina_orbital",
	&"poder_arcano",
	&"cadencia",
	&"projetil_adicional",
	&"nucleo_vital",
	&"passos_ligeiros",
	&"campo_de_ruptura",
]

var game: Node
var _mode := "partida"
var _seed := 1
var _choice := "prioridade"
var _use_dodge := true
var _limit := 900.0
var _rng := RandomNumberGenerator.new()
var _loadout := 0
var _time := 0.0
var _hp_history := PackedFloat32Array()
var _stuck := 0
var _failures: Array[String] = []
var _results: Array[String] = []
var _started := false


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		var value := arg.get_slice("=", 1)
		if arg.begins_with("--modo="):
			_mode = value
		elif arg.begins_with("--semente="):
			_seed = int(value)
		elif arg.begins_with("--escolha="):
			_choice = value
		elif arg.begins_with("--segundos="):
			_limit = float(value)
		elif arg == "--sem-esquiva":
			_use_dodge = false
	MetaProgress.path = "user://teste_balanceamento.json"
	if FileAccess.file_exists(MetaProgress.path):
		DirAccess.remove_absolute(MetaProgress.path)
	seed(_seed)
	_rng.seed = _seed
	print("Balanceamento: modo %s, semente %d, escolha %s" % [_mode, _seed, _choice])
	_start()


func _start() -> void:
	game = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	root.add_child(game)
	current_scene = game
	_time = 0.0
	_started = false


func _process(delta: float) -> bool:
	if game == null or not is_instance_valid(game) or game.player == null:
		return false
	if not _started:
		_started = true
		_setup()
	match _mode:
		"dps":
			return _step_dps(delta)
		"chefe", "partida":
			return _step_match(delta)
	return true


func _setup() -> void:
	match _mode:
		"dps":
			game.player.invulnerable = true
			game.enemies.elapsed = 240.0  # horda mista, todos os tipos já aparecem
			game.encounter_time = 1.0e9
			# Sem coleta de XP: a carga de armas fica a mesma durante a medição.
			game.orbs.magnet_radius = 0.0
			game.orbs.collect_radius = 0.0
			var entry: Array = DPS_LOADOUTS[_loadout]
			for id: StringName in entry[1]:
				for i in int(entry[1][id]):
					game.apply_offer(id)
		"chefe":
			for id: StringName in BOSS_BUILD:
				for i in int(BOSS_BUILD[id]):
					game.apply_offer(id)
			game.player.hp = game.player.max_hp
			game._elapsed = 600.0
			game.enemies.elapsed = 600.0


# ---------------------------------------------------------------- modo dps


func _step_dps(delta: float) -> bool:
	_auto_pick()
	if paused:
		return false
	_time += delta
	game.player.scripted_input = Vector2.from_angle(_time * 0.5)
	if _time < DPS_SECONDS:
		return false
	var stats: RunStats = game.stats
	var parts: Array[String] = []
	for id in game.arsenal.owned_ids():
		parts.append(
			(
				"%s %.0f/s (%d abates)"
				% [id, stats.damage_of(id) / DPS_SECONDS, stats.kills_of(id)]
			)
		)
	var line := "%-26s total %5.0f/s · %s" % [
		DPS_LOADOUTS[_loadout][0], stats.total_damage() / DPS_SECONDS, " · ".join(parts)
	]
	print(line)
	_results.append(line)
	_loadout += 1
	if _loadout >= DPS_LOADOUTS.size():
		return _finish()
	game.queue_free()
	_start()
	return false


# ---------------------------------------------------------------- partida e chefe


func _step_match(delta: float) -> bool:
	_auto_pick()
	if game.is_over():
		return _report_match()
	if paused:
		_stuck += 1
		if _stuck > 600:
			_failures.append("partida presa na pausa")
			return _finish()
		return false
	_stuck = 0
	if _mode == "chefe" and not game.encounter_started():
		game.start_encounter()
	_time += delta
	_pilot(delta)
	if game.elapsed() >= _limit:
		return _report_match()
	return false


## Piloto: foge dos inimigos próximos, sai das áreas de aviso, vai atrás dos orbes e esquiva
## quando leva muito dano de uma vez ou quando um aviso está para acertar.
func _pilot(delta: float) -> void:
	var player: Player = game.player
	var enemies: EnemyManager = game.enemies
	var p := player.global_position
	var away := Vector3.ZERO
	var crowd := 0
	for i in enemies.count:
		var e := enemies.position_of(i)
		var d := Vector3(p.x - e.x, 0.0, p.z - e.z)
		var dist := d.length()
		if enemies.kind_of(i) == EnemyTypes.CHEFE:
			# Chega perto (3 m) quando o chefe persegue ou se recupera, para a aura e as lâminas
			# acertarem; nos avisos de ataque, afasta-se para 6 a 9 m.
			var calm: bool = game.boss.state in [
				BossController.State.PERSEGUIR, BossController.State.RECUPERAR
			]
			var near := 3.0 if calm else 6.0
			if dist < near:
				away += d.normalized() * 1.5
			elif dist > near + 3.0:
				away -= d.normalized() * 0.6
		elif dist < 1.5:
			crowd += 1
			away += d / maxf(dist * dist, 0.05)
		elif dist < 6.0 and dist > 0.01:
			away += d / (dist * dist)
	var danger := _danger_escape(p)
	var orb := Vector3.ZERO
	var best := 100.0
	for i in game.orbs.count:
		var o: Vector3 = game.orbs.position_of(i)
		var dist := Vector2(o.x - p.x, o.z - p.z).length()
		if dist < best and dist < 9.0:
			best = dist
			orb = Vector3(o.x - p.x, 0.0, o.z - p.z).normalized()
	var drift := Vector3(cos(_time * 0.35), 0.0, sin(_time * 0.35))
	var direction := away * 4.0 + danger * 6.0 + orb * 0.8 + drift * 0.35
	direction.y = 0.0
	var right: Vector3 = game.camera_rig.ground_right()
	var forward: Vector3 = game.camera_rig.ground_forward()
	var screen := Vector2(direction.dot(right), -direction.dot(forward))
	player.scripted_input = screen.normalized() if screen.length() > 0.05 else Vector2.ZERO
	# Esquiva.
	_hp_history.append(player.hp)
	if _hp_history.size() > 30:
		_hp_history.remove_at(0)
	if not _use_dodge or not player.dodge_ready():
		return
	var burst := _hp_history[0] - player.hp
	if burst > 12.0 or crowd >= 3 or danger.length() > 0.5 or _charge_incoming(p):
		var target := direction if direction.length() > 0.1 else drift
		player.request_dodge(target)


## Direção para sair de um aviso no chão (disco ou faixa) em que o jogador está.
func _danger_escape(p: Vector3) -> Vector3:
	var fx: GroundEffects = game.effects
	var out := Vector3.ZERO
	for i in fx.count:
		if fx._shape[i] != GroundEffects.DISCO:
			continue
		var c := fx._pos[i]
		var d := Vector3(p.x - c.x, 0.0, p.z - c.z)
		if d.length() < fx._size[i].x + 0.4:
			out += d.normalized() if d.length() > 0.05 else Vector3.RIGHT
	return out


func _charge_incoming(p: Vector3) -> bool:
	var boss: BossController = game.boss
	if boss.state != BossController.State.INVESTIDA:
		return false
	var index: int = game.enemies.boss_index()
	if index == -1:
		return false
	return game.enemies.position_of(index).distance_to(p) < 3.5


func _auto_pick() -> void:
	var panel: LevelUpPanel = game.level_up_panel
	if not panel.is_open() or panel.is_locked():
		return
	var ids := panel.choice_ids()
	var pick := _rng.randi_range(0, ids.size() - 1)
	if _choice == "prioridade":
		var best := 999
		for k in ids.size():
			var rank := PRIORITY.find(ids[k])
			if rank != -1 and rank < best:
				best = rank
				pick = k
	panel.choose(pick)


func _report_match() -> bool:
	var stats: RunStats = game.stats
	var t: float = game.elapsed()
	var lines: Array[String] = []
	var result := "vitória" if game.is_victory() else ("derrota" if game.is_over() else "limite")
	lines.append(
		(
			"Resultado: %s aos %s · nível %d · abates %d · esquivas %d"
			% [result, Hud.format_time(t), game.progression.level, game.kills(), stats.dodges]
		)
	)
	var by_weapon: Array[String] = []
	for id in game.arsenal.owned_ids():
		by_weapon.append(
			(
				"%s nv%d: %.0f de dano (%.1f/s), %d abates"
				% [
					id,
					game.arsenal.level(id),
					stats.damage_of(id),
					stats.damage_of(id) / maxf(t, 1.0),
					stats.kills_of(id)
				]
			)
		)
	lines.append("Armas: " + " · ".join(by_weapon))
	var kinds: Array[String] = []
	for kind in EnemyTypes.COUNT:
		kinds.append(
			(
				"%s %d abates/%.0f dano"
				% [
					EnemyTypes.display_name(kind),
					stats.kills_by_kind.get(kind, 0),
					stats.damage_by_kind.get(kind, 0.0)
				]
			)
		)
	lines.append("Por tipo: " + " · ".join(kinds))
	var taken: Array[String] = []
	for source in stats.damage_taken_by_source:
		taken.append("%s %.0f" % [source, stats.damage_taken_by_source[source]])
	lines.append("Dano recebido: %.0f (%s)" % [stats.damage_taken, ", ".join(taken)])
	var upgrades: Array[String] = []
	for id in Upgrades.all_ids():
		if game.upgrades.stacks(id) > 0:
			upgrades.append("%s %d" % [id, game.upgrades.stacks(id)])
	lines.append("Melhorias: " + ", ".join(upgrades))
	if stats.boss_spawned_at >= 0.0:
		lines.append(
			(
				"Chefe: surgiu %s · %s · dano nele %.0f · dano dele %.0f · ataques %s"
				% [
					Hud.format_time(stats.boss_spawned_at),
					(
						"derrotado em %.1f s" % stats.boss_fight_seconds()
						if stats.bosses_defeated > 0
						else "não derrotado"
					),
					stats.boss_damage_dealt,
					stats.boss_damage_taken,
					game.boss.attack_counts
				]
			)
		)
	for line in lines:
		print(line)
	_results.append_array(lines)
	return _finish()


func _finish() -> bool:
	if _failures.is_empty():
		print("BALANCEAMENTO: OK")
		quit(0)
	else:
		for failure in _failures:
			printerr("FALHOU: " + failure)
		quit(1)
	return true
