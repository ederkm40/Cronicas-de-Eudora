extends SceneTree
## Teste rápido sem tela: roda uma partida simulada de ponta a ponta e confere o básico.
## Uso: godot --headless --path . --fixed-fps 60 --script res://tests/smoke_test.gd
## Sai com código 0 se tudo passou e 1 se algo falhou.
##
## Roteiro: joystick (toque e arraste) -> teclado (D) -> anda em círculos coletando orbes
## -> escolhe melhorias sempre que sobe de nível -> confere o ciclo inteiro no final.

const SIMULATED_SECONDS := 60.0

var _main: Node
var _time := 0.0 ## Tempo real da simulação (corre mesmo com a partida pausada).
var _start_pos := Vector3.ZERO
var _touched := false
var _moved_with_joystick := false
var _key_start := Vector3.ZERO
var _key_phase := 0
var _choices_made := 0
var _paused_frames := 0
var _failures: Array[String] = []


func _initialize() -> void:
	var scene: PackedScene = load("res://scenes/main.tscn")
	_main = scene.instantiate()
	root.add_child(_main)


func _process(delta: float) -> bool:
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
		_check(direction.dot(right) > 0.95, "arrastar para a direita deveria andar para a direita da tela")
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

	# Depois dos controles, anda em círculos para coletar orbes.
	if _key_phase == 2:
		player.scripted_input = Vector2.from_angle(_time * 0.6)

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
	print("Nível: %d · XP coletada: %d · Melhorias escolhidas: %d" % [progression.level, progression.total_xp, _choices_made])
	var stacks := []
	for id in Upgrades.all_ids():
		stacks.append("%s=%d" % [id, _main.upgrades.stacks(id)])
	print("Melhorias: " + ", ".join(stacks))
	_check(_moved_with_joystick, "o teste do joystick não chegou a rodar")
	_check(_key_phase == 2, "o teste do teclado não chegou a rodar")
	_check(_main._kills > 0, "a arma automática deveria matar inimigos")
	_check(enemies.count > 0 or _main._kills > 0, "inimigos deveriam aparecer")
	_check(progression.total_xp > 0, "deveria coletar experiência")
	_check(progression.level >= 2, "deveria subir pelo menos 1 nível em 60 s")
	_check(_choices_made == progression.level - 1, "cada nível ganho deveria ter uma melhoria escolhida")
	_check(_paused_frames > 0, "a partida deveria ter pausado nas escolhas")
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
