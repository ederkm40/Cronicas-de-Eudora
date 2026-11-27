extends SceneTree
## Teste rápido sem tela: roda uma partida simulada de ponta a ponta e confere o básico.
## Uso: godot --headless --path . --fixed-fps 60 --script res://tests/smoke_test.gd
## Sai com código 0 se tudo passou e 1 se algo falhou.
##
## Roteiro: abre o menu e toca em JOGAR -> joystick (toque e arraste) -> teclado (D)
## -> esquiva (Espaço) -> anda em círculos coletando orbes -> escolhe a primeira oferta
## sempre que sobe de nível (pode ser arma nova)
## -> aos 20 s força um elite e uma Fenda do Eco -> aos 40 s pausa com Esc e retoma
## -> confere o ciclo inteiro no final.

const SIMULATED_SECONDS := 60.0

var _main: Node
var _menu: Node
var _menu_frames := 0
var _time := 0.0  ## Tempo real da simulação (corre mesmo com a partida pausada).
var _start_pos := Vector3.ZERO
var _touched := false
var _moved_with_joystick := false
var _key_start := Vector3.ZERO
var _key_phase := 0
var _choices_made := 0
var _paused_frames := 0
var _dodge_phase := 0
var _event_phase := 0  ## 0.4: elite e fenda forçados, depois pausa pelo teclado.
var _pause_seen := false
var _failures: Array[String] = []


func _initialize() -> void:
	MetaProgress.path = "user://teste_smoke_progresso.json"
	GameSettings.path = "user://teste_config_simulacao.json"
	if FileAccess.file_exists(MetaProgress.path):
		DirAccess.remove_absolute(MetaProgress.path)
	# Começa como o jogador: pela cena inicial do projeto (o menu) e o botão JOGAR.
	var scene: PackedScene = load(ProjectSettings.get_setting("application/run/main_scene"))
	_menu = scene.instantiate()
	root.add_child(_menu)
	current_scene = _menu


## Toca em JOGAR no menu e espera a partida abrir (no máximo 2 s).
func _wait_for_game() -> bool:
	_menu_frames += 1
	if _menu_frames == 2:
		_check(_menu is MainMenu, "o jogo deveria abrir no menu")
		_menu.play_button().pressed.emit()
	if current_scene != null and current_scene != _menu and current_scene.has_method("elapsed"):
		_main = current_scene
		_check(not is_instance_valid(_menu), "o menu deveria ser liberado ao jogar")
		return false
	if _menu_frames > 120:
		_check(false, "JOGAR deveria abrir a partida")
		for failure in _failures:
			printerr("FALHOU: " + failure)
		quit(1)
		return true
	return false


func _process(delta: float) -> bool:
	if _main == null:
		return _wait_for_game()
	_time += delta
	var player: Player = _main.player

	# Simula um dedo: toca, arrasta para a direita por 1 segundo e solta.
	if not _touched and _time > 0.2:
		_touched = true
		_start_pos = player.global_position
		_send_touch(true, Vector2(360, 900))
		_send_drag(Vector2(460, 900))
	if _touched and not _moved_with_joystick and _time > 1.2:
		_moved_with_joystick = true
		var moved := player.global_position.distance_to(_start_pos)
		_check(moved > 3.0, "joystick deveria mover o jogador (moveu %.2f m)" % moved)
		var right: Vector3 = _main.camera_rig.ground_right()
		var direction := (player.global_position - _start_pos).normalized()
		_check(
			direction.dot(right) > 0.95,
			"arrastar para a direita deveria andar para a direita da tela"
		)
		_send_touch(false, Vector2(460, 900))

	# Teclado: segura D por meio segundo.
	if _key_phase == 0 and _time > 1.5 and not paused:
		_key_phase = 1
		_key_start = player.global_position
		_send_key(KEY_D, true)
	elif _key_phase == 1 and _time > 2.0:
		_key_phase = 2
		_send_key(KEY_D, false)
		var moved := player.global_position.distance_to(_key_start)
		_check(moved > 1.5, "a tecla D deveria mover o jogador (moveu %.2f m)" % moved)

	# Esquiva pelo teclado.
	if _dodge_phase == 0 and _key_phase == 2 and _time > 2.5 and not paused:
		_dodge_phase = 1
		_send_key(KEY_SPACE, true)
	elif _dodge_phase == 1 and _time > 2.6:
		_dodge_phase = 2
		_send_key(KEY_SPACE, false)

	# Depois dos controles, anda em círculos para coletar orbes.
	if _key_phase == 2:
		player.scripted_input = Vector2.from_angle(_time * 0.6)

	# 0.4: eventos e pausa numa partida real.
	if _event_phase == 0 and _time > 20.0 and not paused:
		_event_phase = 1
		_check(_main.director.spawn_elite() != -1, "o elite deveria aparecer")
		_main.director.start_rift()
	elif _event_phase == 1 and _time > 40.0 and not paused:
		_event_phase = 2
		_send_key(KEY_ESCAPE, true)
		_send_key(KEY_ESCAPE, false)
	elif _event_phase == 2 and _time > 40.3:
		_event_phase = 3
		_pause_seen = paused and _main.pause_menu.is_open()
		_main.pause_menu.close()

	# Sobe de nível -> escolhe a primeira melhoria assim que os cartões destravam.
	var panel: LevelUpPanel = _main.level_up_panel
	if paused:
		_paused_frames += 1
	if panel.is_open() and not panel.is_locked():
		panel.choose(0)
		_choices_made += 1

	if _time >= SIMULATED_SECONDS or not player.alive:
		_report()
		return true
	return false


func _report() -> void:
	var player: Player = _main.player
	var enemies: EnemyManager = _main.enemies
	print("Tempo simulado: %.1f s" % _time)
	print("Vida do jogador: %.1f / %.1f (vivo: %s)" % [player.hp, player.max_hp, player.alive])
	print("Inimigos ativos: %d" % enemies.count)
	print("Abates: %d" % _main._kills)
	var progression: Progression = _main.progression
	print(
		(
			"Nível: %d · XP coletada: %d · Melhorias escolhidas: %d"
			% [progression.level, progression.total_xp, _choices_made]
		)
	)
	var stacks := []
	for id in Upgrades.all_ids():
		stacks.append("%s=%d" % [id, _main.upgrades.stacks(id)])
	print("Melhorias: " + ", ".join(stacks))
	var weapons := []
	for id in _main.arsenal.owned_ids():
		weapons.append("%s=%d" % [id, _main.arsenal.level(id)])
	print("Armas: " + ", ".join(weapons))
	var stats: RunStats = _main.stats
	print("Dano por arma: %s · esquivas: %d" % [stats.damage_by_weapon, stats.dodges])
	_check(player.dodges_used == 1, "a tecla Espaço deveria esquivar uma vez")
	_check(stats.total_damage() > 0.0, "o dano causado deveria ser contado")
	_check(_moved_with_joystick, "o teste do joystick não chegou a rodar")
	_check(_key_phase == 2, "o teste do teclado não chegou a rodar")
	_check(_main._kills > 0, "a arma automática deveria matar inimigos")
	_check(enemies.count > 0 or _main._kills > 0, "inimigos deveriam aparecer")
	_check(progression.total_xp > 0, "deveria coletar experiência")
	_check(progression.level >= 2, "deveria subir pelo menos 1 nível em 60 s")
	_check(
		_choices_made == progression.level - 1, "cada nível ganho deveria ter uma opção escolhida"
	)
	_check(_paused_frames > 0, "a partida deveria ter pausado nas escolhas")
	_check(_event_phase == 3, "o roteiro de eventos e pausa não chegou ao fim")
	_check(_pause_seen, "Esc deveria abrir a pausa com as configurações")
	var played := 0
	for sound in _main.sounds.played:
		played += _main.sounds.played[sound]
	print(
		(
			"Sons tocados: %d · estouros de abate: %d · fenda ativa: %s"
			% [played, _main.feel.pops, _main.director.rift_active]
		)
	)
	_check(played > 0, "os sons deveriam tocar")
	_check(_main.feel.pops > 0, "os abates deveriam ter estouro no chão")
	_check(not paused or not player.alive, "a partida não deveria terminar presa na pausa")
	if _failures.is_empty():
		print("SMOKE TEST: OK")
		quit(0)
	else:
		for failure in _failures:
			printerr("FALHOU: " + failure)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _send_touch(pressed: bool, position: Vector2) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.pressed = pressed
	event.position = position
	Input.parse_input_event(event)


func _send_key(key: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.keycode = key
	event.pressed = pressed
	Input.parse_input_event(event)


func _send_drag(position: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = 0
	event.position = position
	event.relative = Vector2(100, 0)
	Input.parse_input_event(event)
