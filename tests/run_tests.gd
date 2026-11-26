extends SceneTree
## Executor dos testes do jogo. Roda as suítes de tests/suites/ em sequência.
## Uso: godot --headless --path . --fixed-fps 60 --script res://tests/run_tests.gd
## Cada teste abre uma partida nova, sem hordas automáticas, e controla os inimigos um a um.
## Sai com código 0 se todos passarem e 1 se algum falhar.

const SUITES := [
	"res://tests/suites/progressao.gd",
	"res://tests/suites/armas_e_ofertas.gd",
	"res://tests/suites/inimigos_e_chefe.gd",
	"res://tests/suites/esquiva_e_encerramento.gd",
	"res://tests/suites/save_e_joystick.gd",
]
const TEST_SAVE := "user://teste_progresso.json"

var game: Node
var _failures: Array[String] = []
var _current := ""
var _checks := 0


func _initialize() -> void:
	# Progressão permanente num arquivo só dos testes, apagado antes de cada partida.
	MetaProgress.path = TEST_SAVE
	_run_all.call_deferred()


func _run_all() -> void:
	seed(20261126)
	var total := 0
	var failed_tests := 0
	for path in SUITES:
		var script := load(path) as GDScript
		if script == null or not script.can_instantiate():
			# Suíte com erro de sintaxe: conta como falha e segue, em vez de travar o executor.
			total += 1
			failed_tests += 1
			_failures.append("%s: a suíte não carregou (erro no script)" % path)
			print("  FALHOU ", path.get_file())
			continue
		var suite: RefCounted = script.new()
		suite.runner = self
		print("== ", path.get_file())
		for test_name in suite.TESTS:
			total += 1
			_current = test_name
			var before := _failures.size()
			await Callable(suite, test_name).call()
			await close_game()
			if _failures.size() == before:
				print("  ok    ", test_name)
			else:
				failed_tests += 1
				print("  FALHOU ", test_name)
	print("")
	print("%d testes, %d verificações, %d falhas" % [total, _checks, failed_tests])
	if _failures.is_empty():
		print("TESTES: OK")
		quit(0)
	else:
		for failure in _failures:
			printerr("FALHOU: " + failure)
		quit(1)


func check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append("%s: %s" % [_current, message])


func close_game() -> void:
	paused = false
	if is_instance_valid(game):
		game.queue_free()
		game = null
	if is_instance_valid(current_scene):
		current_scene.queue_free()
	await process_frame
