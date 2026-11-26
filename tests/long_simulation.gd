extends SceneTree
## Simulação prolongada para avaliar desempenho e estabilidade.
##
## Uso:
##   godot --headless --path . --fixed-fps 60 --script res://tests/long_simulation.gd \
##     -- --segundos=600
## Opções (depois de "--"):
##   --segundos=N     tempo de partida simulado (padrão 600 = 10 minutos)
##   --invulneravel   o personagem não morre (bom para medir a horda cheia)
##   --armas-maximas  começa com a Aura e a Lâmina no nível 5 (pior caso de processamento)
##
## O piloto anda em círculos por 2 minutos (fugindo da horda e coletando orbes) e depois
## fica parado até morrer. Quando morre, a simulação aperta "Jogar de novo" e continua:
## isso testa o reinício repetido. Com --invulneravel, ele só anda em círculos, sem morrer.
## A cada nível escolhe uma melhoria aleatória. A pausa do level-up não conta como tempo.
##
## Sai com código 1 se encontrar sinais de problema: memória ou nós crescendo sem parar,
## partida travada na pausa, ou nenhuma subida de nível.

const KITE_SECONDS := 120.0

var game: Node
var _target_seconds := 600.0
var _invulnerable := false
var _max_weapons := false
var _rng := RandomNumberGenerator.new()

var _sim_time := 0.0  ## Tempo de partida (sem pausas), somado entre reinícios.
var _game_time := 0.0  ## Tempo da partida atual.
var _configured := false
var _frames := 0
var _frame_usec := PackedInt32Array()
var _last_tick := 0
var _deaths := 0
var _level_ups := 0
var _max_level := 1
var _max_enemies := 0
var _max_orbs := 0
var _max_projectiles := 0
var _max_enemy_shots := 0
var _max_effects := 0
var _bosses_seen := 0
var _bosses_defeated := 0
var _paused_streak := 0
var _longest_pause := 0
var _restarting := false
var _next_report := 60.0
var _nodes_after_first_game := -1
var _memory_start := 0
var _failures: Array[String] = []


func _initialize() -> void:
	MetaProgress.path = "user://teste_simulacao_progresso.json"
	if FileAccess.file_exists(MetaProgress.path):
		DirAccess.remove_absolute(MetaProgress.path)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--segundos="):
			_target_seconds = float(arg.get_slice("=", 1))
		elif arg == "--invulneravel":
			_invulnerable = true
		elif arg == "--armas-maximas":
			_max_weapons = true
	_rng.seed = 2026
	seed(2026)
	_start_game()
	_memory_start = OS.get_static_memory_usage()
	_last_tick = Time.get_ticks_usec()
	print(
		(
			"Simulação: %.0f s de partida, %s"
			% [_target_seconds, "invulnerável" if _invulnerable else "reinicia ao morrer"]
		)
	)


func _start_game() -> void:
	game = (load("res://scenes/main.tscn") as PackedScene).instantiate()
	root.add_child(game)
	current_scene = game
	_configured = false


func _process(delta: float) -> bool:
	var now := Time.get_ticks_usec()
	_frame_usec.append(now - _last_tick)
	_last_tick = now
	_frames += 1

	if _restarting:
		if is_instance_valid(current_scene) and current_scene != game:
			game = current_scene
			_configured = false
			_restarting = false
		return false

	var player: Player = game.player
	if player == null:
		return false
	if not _configured:
		_configured = true
		_game_time = 0.0
		player.invulnerable = _invulnerable
		if _max_weapons:
			for i in 5:
				game.apply_offer(WeaponCatalog.AURA)
				game.apply_offer(WeaponCatalog.BLADE)
	if not player.alive:
		_deaths += 1
		_restarting = true
		if _nodes_after_first_game == -1:
			_nodes_after_first_game = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
		game.results.restart_requested.emit()
		return false

	if game.is_over() and player.alive:  # vitória: recomeça também
		_bosses_defeated += 1
		_restarting = true
		game.results.restart_requested.emit()
		return false

	var panel: LevelUpPanel = game.level_up_panel
	if paused:
		_paused_streak += 1
		_longest_pause = maxi(_longest_pause, _paused_streak)
		if panel.is_open() and not panel.is_locked():
			panel.choose(_rng.randi_range(0, panel.choice_ids().size() - 1))
			_level_ups += 1
		return false
	_paused_streak = 0

	_sim_time += delta
	_game_time += delta
	if _invulnerable or _game_time < KITE_SECONDS:
		player.scripted_input = Vector2.from_angle(_game_time * 0.5)
	else:
		player.scripted_input = Vector2.ZERO
	_max_level = maxi(_max_level, game.progression.level)
	_max_enemies = maxi(_max_enemies, game.enemies.count)
	_max_orbs = maxi(_max_orbs, game.orbs.count)
	_max_projectiles = maxi(_max_projectiles, game.weapon.active_projectiles())
	_max_enemy_shots = maxi(_max_enemy_shots, game.enemy_projectiles.count)
	_max_effects = maxi(_max_effects, game.effects.count)
	if game.enemies.boss_index() != -1:
		_bosses_seen = 1

	if _sim_time >= _next_report:
		_next_report += 60.0
		var linha := "  %3d s · nível %d · inimigos %d · orbes %d · projéteis %d"
		linha += " · nós %d · memória %.1f MB · mortes %d"
		print(
			(
				linha
				% [
					int(_sim_time),
					game.progression.level,
					game.enemies.count,
					game.orbs.count,
					game.weapon.active_projectiles(),
					int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
					OS.get_static_memory_usage() / 1048576.0,
					_deaths
				]
			)
		)

	if _sim_time >= _target_seconds:
		_report()
		return true
	return false


func _report() -> void:
	var sorted := _frame_usec.duplicate()
	sorted.sort()
	var total := 0
	for t in sorted:
		total += t
	var avg := total / float(sorted.size()) / 1000.0
	var p95 := sorted[int(sorted.size() * 0.95)] / 1000.0
	var p99 := sorted[int(sorted.size() * 0.99)] / 1000.0
	var worst := sorted[sorted.size() - 1] / 1000.0
	var nodes_now := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	var memory_growth := (OS.get_static_memory_usage() - _memory_start) / 1048576.0

	print("")
	print("Resultado")
	print("  Quadros: %d · tempo de partida: %.0f s" % [_frames, _sim_time])
	var tempos := "  Tempo por quadro (CPU, este computador): média %.2f ms · p95 %.2f ms"
	tempos += " · p99 %.2f ms · pior %.1f ms"
	print(tempos % [avg, p95, p99, worst])
	print(
		(
			"  Máximos: inimigos %d · orbes %d · projéteis %d · projéteis inimigos %d · efeitos %d"
			% [_max_enemies, _max_orbs, _max_projectiles, _max_enemy_shots, _max_effects]
		)
	)
	var boss_line := "  Chefe: apareceu %s · vitórias %d"
	print(boss_line % ["sim" if _bosses_seen > 0 else "não", _bosses_defeated])
	print(
		(
			"  Níveis escolhidos: %d · maior nível numa partida: %d · mortes/reinícios: %d"
			% [_level_ups, _max_level, _deaths]
		)
	)
	print(
		(
			"  Nós na árvore agora: %d%s"
			% [
				nodes_now,
				(
					""
					if _nodes_after_first_game == -1
					else " (na 1ª morte: %d)" % _nodes_after_first_game
				)
			]
		)
	)
	print("  Memória: %+.1f MB desde o início" % memory_growth)
	print("  Pausa mais longa: %d quadros" % _longest_pause)

	_check(_level_ups > 0, "nenhuma subida de nível aconteceu")
	if not _invulnerable and _target_seconds > KITE_SECONDS * 2.0:
		_check(_deaths > 0, "o piloto deveria ter morrido e reiniciado pelo menos uma vez")
	_check(_longest_pause < 120, "a partida ficou presa na pausa (%d quadros)" % _longest_pause)
	if _nodes_after_first_game != -1:
		_check(
			nodes_now <= _nodes_after_first_game + 40,
			"os nós cresceram entre reinícios (%d -> %d)" % [_nodes_after_first_game, nodes_now]
		)
	_check(memory_growth < 64.0, "a memória cresceu %.1f MB" % memory_growth)

	if _failures.is_empty():
		print("SIMULAÇÃO LONGA: OK")
		quit(0)
	else:
		for failure in _failures:
			printerr("FALHOU: " + failure)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
