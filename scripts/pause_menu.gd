class_name PauseMenu
extends Control
## Tela de pausa: as configurações (SettingsPanel, o mesmo painel do menu), Continuar e
## Encerrar partida. Abre pelo botão "II" do HUD, pelas teclas Esc e P e pelo voltar do
## celular. Funciona com o jogo pausado (process_mode = ALWAYS). Coluna central.

signal resumed
signal settings_changed
signal quit_requested  ## "Encerrar partida", depois de confirmar.

const COLUMN_WIDTH := 560
const QUIT_TEXT := "Encerrar partida"
const CONFIRM_TEXT := "Toque de novo para encerrar"

var settings: GameSettings:
	set(value):
		settings = value
		if _panel:
			_panel.settings = value
var _panel: SettingsPanel
var _resume: Button
var _quit: Button
var _confirming := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	add_child(UiStyle.backdrop(0.82))
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(COLUMN_WIDTH, 0)
	column.add_theme_constant_override("separation", 16)
	center.add_child(column)
	var title := UiStyle.label(56)
	title.text = "Pausado"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	_panel = SettingsPanel.new()
	column.add_child(_panel)
	_panel.settings = settings
	_panel.settings_changed.connect(func() -> void: settings_changed.emit())
	_resume = UiStyle.button("Continuar", 34, 96, UiStyle.Kind.PRIMARY)
	_resume.pressed.connect(close)
	column.add_child(_resume)
	_quit = UiStyle.button(QUIT_TEXT, 26, 76, UiStyle.Kind.QUIET)
	_quit.pressed.connect(_on_quit)
	column.add_child(_quit)


func is_open() -> bool:
	return visible


func open() -> void:
	_panel.refresh()
	_set_confirming(false)
	visible = true


func close() -> void:
	if not visible:
		return
	visible = false
	resumed.emit()


func option_button(key: String) -> Button:
	return _panel.option_button(key)


func resume_button() -> Button:
	return _resume


func quit_button() -> Button:
	return _quit


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if visible and key and key.pressed and not key.echo:
		if key.physical_keycode == KEY_ESCAPE or key.physical_keycode == KEY_P:
			close()
			get_viewport().set_input_as_handled()


## Encerrar pede um segundo toque, para um toque sem querer não acabar com a partida.
func _on_quit() -> void:
	if not _confirming:
		_set_confirming(true)
		return
	_set_confirming(false)
	visible = false
	quit_requested.emit()


func _set_confirming(value: bool) -> void:
	_confirming = value
	_quit.text = CONFIRM_TEXT if value else QUIT_TEXT
