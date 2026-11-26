extends Node
## Ponte de testes para o navegador. Existe só na build "Web QA" (funcionalidade de
## exportação `qa`), usada pelos testes do Playwright no CI. A build de produção ("Web"),
## publicada no site e nas prévias, exclui este arquivo (`exclude_filter` do preset) e
## `main.gd` só carrega a ponte quando a funcionalidade `qa` existe. Sem `class_name` de
## propósito: nada no jogo depende desta classe.
##
## A cada 0,1 s escreve o estado da partida em `window.__eudora` (posição, vida, nível,
## esquivas, tela de level-up, tela de resultados, chefe) e a posição dos botões na tela,
## em frações da tela (0 a 1). Assim os testes do Playwright tocam nos botões de verdade.
## Também lê comandos de `window.__eudoraComandos` para preparar situações (dar XP, chamar
## o chefe), sem atalhos no caminho que está sendo testado (toque, gesto, botão).

const INTERVAL := 0.1

var _game: Node
var _timer := 0.0
var _active := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_game = get_parent()
	if not (OS.has_feature("web") and OS.has_feature("qa")):
		return
	_active = true
	# Termina com "void 0": o eval não devolve objetos do JS para o Godot converter.
	var setup := "window.__eudoraComandos = window.__eudoraComandos || []; void 0"
	JavaScriptBridge.eval(setup, true)


func _process(delta: float) -> void:
	if not _active:
		return
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = INTERVAL
	_run_commands()
	JavaScriptBridge.eval("window.__eudora = %s; void 0" % JSON.stringify(snapshot()), true)


func _run_commands() -> void:
	var raw: Variant = JavaScriptBridge.eval(
		"JSON.stringify((window.__eudoraComandos || []).splice(0))", true
	)
	if not (raw is String):
		return
	var list: Variant = JSON.parse_string(raw)
	if not (list is Array):
		return
	for command in list:
		execute(str(command))


## Executa um comando de teste ("nome" ou "nome:valor").
func execute(command: String) -> void:
	var parts := command.split(":")
	var value := parts[1] if parts.size() > 1 else ""
	var enemies: EnemyManager = _game.enemies
	match parts[0]:
		"xp":
			_game.progression.add_xp(int(value))
		"hordas":
			enemies.spawning_enabled = value == "1"
		"invulneravel":
			_game.player.invulnerable = value == "1"
		"limpar":
			while enemies.count > 0:
				enemies._remove(enemies.count - 1)
		"chefe":
			_game.start_encounter()
		"chefe_vida":
			if enemies.boss_index() != -1:
				enemies._hp[enemies.boss_index()] = float(value)
		"morrer":
			_game.player.invulnerable = false
			_game.player.take_damage(1.0e9, "teste")


func snapshot() -> Dictionary:
	var player: Player = _game.player
	var panel: LevelUpPanel = _game.level_up_panel
	var results: ResultsScreen = _game.results
	var enemies: EnemyManager = _game.enemies
	var weapons := {}
	for id in _game.arsenal.owned_ids():
		weapons[String(id)] = _game.arsenal.level(id)
	var boss_index := enemies.boss_index()
	return {
		"partida": _game.get_instance_id(),
		"tempo": _game.elapsed(),
		"pausado": get_tree().paused,
		"x": player.global_position.x,
		"z": player.global_position.z,
		"vida": player.hp,
		"vida_max": player.max_hp,
		"vivo": player.alive,
		"nivel": _game.progression.level,
		"xp_total": _game.progression.total_xp,
		"esquivas": player.dodges_used,
		"gestos_esquiva": _game.joystick.dodge_gestures,
		"esquiva_pronta": player.dodge_ready(),
		"inimigos": enemies.count,
		"abates": _game.kills(),
		"armas": weapons,
		"fim": _game.is_over(),
		"vitoria": _game.is_victory(),
		"chefe": boss_index != -1,
		"chefe_vida": enemies.hp_of(boss_index) if boss_index != -1 else 0.0,
		"painel":
		{
			"aberto": panel.is_open(),
			"travado": panel.is_locked(),
			"opcoes": panel.choice_ids().map(func(id: StringName) -> String: return String(id)),
			"cartoes": panel.card_buttons().map(_rect),
			"bloquear": panel.lock_buttons().map(_rect),
			"trocar": _rect(panel.reroll_button()),
			"trocas": _game.offers.rerolls_left,
			"bloqueios": _game.offers.banishes_left,
		},
		"resultados":
		{
			"aberto": results.is_open(),
			"reiniciar": _rect(results.restart_button()),
		},
	}


## Retângulo do controle em frações da área visível: [x, y, largura, altura].
func _rect(control: Control) -> Array:
	var size := get_viewport().get_visible_rect().size
	var r := control.get_global_rect()
	return [r.position.x / size.x, r.position.y / size.y, r.size.x / size.x, r.size.y / size.y]
