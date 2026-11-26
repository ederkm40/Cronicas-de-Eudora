extends RefCounted
## Base das suítes de testes. Cada suíte (tests/suites/*.gd) estende esta base e lista os
## testes em TESTS. O executor é tests/run_tests.gd: ele roda uma suíte por vez, abre e fecha
## as partidas e conta as verificações.
##
## As propriedades abaixo repassam para o executor (a SceneTree), para que os testes usem
## `game`, `paused`, `current_scene` e `await process_frame` como num script de SceneTree.

const MAIN_SCENE := "res://scenes/main.tscn"
const TEST_SAVE := "user://teste_progresso.json"

var runner: SceneTree
var game: Node:
	get:
		return runner.game
	set(value):
		runner.game = value
var paused: bool:
	get:
		return runner.paused
	set(value):
		runner.paused = value
var current_scene: Node:
	get:
		return runner.current_scene
	set(value):
		runner.current_scene = value
var process_frame: Signal:
	get:
		return runner.process_frame


func _check(condition: bool, message: String) -> void:
	runner.check(condition, message)


func _close_game() -> void:
	await runner.close_game()


func _near(a: float, b: float, tolerance: float = 0.001) -> bool:
	return absf(a - b) <= tolerance


## Abre uma partida nova, com o nascimento automático de hordas desligado.
func _new_game(spawning: bool = false, keep_save: bool = false) -> void:
	await _close_game()
	paused = false
	if not keep_save:
		_delete_save()
	game = (load(MAIN_SCENE) as PackedScene).instantiate()
	runner.root.add_child(game)
	current_scene = game
	game.enemies.spawning_enabled = spawning
	await process_frame


func _frames(amount: int) -> void:
	for i in amount:
		await process_frame


## Coloca a experiência suficiente para subir um nível, como se viesse dos orbes.
func _grant_level() -> void:
	game.progression.add_xp(game.progression.xp_to_next() - game.progression.xp)


## Espera a tela de level-up destravar e escolhe a melhoria pelo mesmo caminho do toque.
func _choose(id: StringName) -> void:
	var panel: LevelUpPanel = game.level_up_panel
	while panel.is_locked():
		await process_frame
	var index := panel.choice_ids().find(id)
	if index == -1:
		# A melhoria não foi sorteada: aplica direto para testar o efeito.
		game.upgrades.apply(id, game.player, game.weapon)
		panel.choose(0)
	else:
		panel.choose(index)
	await process_frame


func _enemy_point(distance: float) -> Vector3:
	return game.player.global_position + game.camera_rig.ground_right() * distance


func _delete_save() -> void:
	for suffix in ["", ".tmp", ".corrompido"]:
		if FileAccess.file_exists(TEST_SAVE + suffix):
			DirAccess.remove_absolute(TEST_SAVE + suffix)


## Desliga o Raio arcano (alcance zero) para medir só a arma em teste.
func _disable_bolt() -> void:
	game.weapon.attack_range = 0.0


## Inimigo parado a `distance` metros à direita da tela.
func _spawn_still(distance: float, hp: float, kind: int = EnemyTypes.COMUM) -> int:
	var index: int = game.enemies.spawn_at(_enemy_point(distance), hp, kind)
	game.enemies._speed[index] = 0.0
	return index


func _clear_enemies() -> void:
	while game.enemies.count > 0:
		game.enemies._remove(game.enemies.count - 1)


func _index_of_id(id: int) -> int:
	for i in game.enemies.count:
		if game.enemies.id_of(i) == id:
			return i
	return -1


func _touch(pressed: bool, position: Vector2) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.pressed = pressed
	event.position = position
	Input.parse_input_event(event)


func _drag(position: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = 0
	event.position = position
	Input.parse_input_event(event)


func _key(key: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.keycode = key
	event.pressed = pressed
	Input.parse_input_event(event)


## Toque curto: encosta, espera `hold` quadros e solta.
func _tap(position: Vector2, hold: int = 3) -> void:
	_touch(true, position)
	await _frames(hold)
	_touch(false, position)
	await _frames(1)


## Dois toques curtos com `gap` quadros entre soltar o primeiro e tocar o segundo.
func _double_tap(position: Vector2, gap: int) -> void:
	await _tap(position)
	await _frames(maxi(gap - 1, 0))
	await _tap(position)
