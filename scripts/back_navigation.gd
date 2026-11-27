class_name BackNavigation
extends Node
## Um só sinal para "voltar", venha de onde vier:
## - Esc no computador;
## - o botão voltar do Android num app exportado (NOTIFICATION_WM_GO_BACK_REQUEST);
## - o botão voltar do navegador do celular. Sem tratamento, ele sairia da página do jogo.
##   No primeiro toque, a página ganha uma entrada extra no histórico. Quando o voltar a
##   consome (evento `popstate`), o jogo põe outra no lugar e emite `back_requested`.
##   Precisa do primeiro toque: o Chrome ignora entradas criadas sem interação do usuário.
## Funciona com o jogo pausado. Cada cena tem o seu; o ouvinte do navegador sai junto com o nó.

signal back_requested

var handle_escape := true  ## A partida trata o Esc sozinha (abre e fecha a pausa).
var _web := false
var _armed := false
var _callback: JavaScriptObject  ## Guardado aqui: sem referência, o Godot o descartaria.
var _window: JavaScriptObject


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_web = OS.has_feature("web")
	if _web:
		_window = JavaScriptBridge.get_interface("window")
		_callback = JavaScriptBridge.create_callback(_on_popstate)
		_window.addEventListener("popstate", _callback)


func _exit_tree() -> void:
	if _web and _window != null:
		_window.removeEventListener("popstate", _callback)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		back_requested.emit()


func _input(event: InputEvent) -> void:
	if _web and not _armed and (event is InputEventScreenTouch or event is InputEventMouseButton):
		_armed = true
		_push_history()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if handle_escape and key and key.pressed and not key.echo:
		if key.physical_keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			back_requested.emit()


## Uma entrada só por página, mesmo trocando de cena (marcador em `window`). Termina com
## "void 0": o eval não devolve nada para o Godot converter (ver CLAUDE.md).
func _push_history() -> void:
	JavaScriptBridge.eval(
		(
			"if (!window.__eudoraHistorico) { history.pushState({eudora: 1}, '');"
			+ " window.__eudoraHistorico = 1; } void 0"
		),
		true
	)


func _on_popstate(_args: Array) -> void:
	JavaScriptBridge.eval("history.pushState({eudora: 1}, ''); void 0", true)
	back_requested.emit()
