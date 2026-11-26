extends SceneTree
## Teste rápido sem tela: roda a partida simulada e confere se o básico funciona.
## Uso: godot --headless --path . --fixed-fps 60 --script res://tests/smoke_test.gd
## Sai com código 0 se tudo passou e 1 se algo falhou.

const SIMULATED_SECONDS := 45.0

var _main: Node
var _time := 0.0
var _start_pos := Vector3.ZERO
var _touched := false
var _moved_with_joystick := false
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
	_check(_moved_with_joystick, "o teste do joystick não chegou a rodar")
	_check(_main._kills > 0, "a arma automática deveria matar inimigos")
	_check(enemies.count > 0 or _main._kills > 0, "inimigos deveriam aparecer")
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


func _send_drag(position: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = 0
	event.position = position
	event.relative = Vector2(100, 0)
	Input.parse_input_event(event)
