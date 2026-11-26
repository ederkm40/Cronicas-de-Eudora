class_name PauseMenu
extends Control
## Tela de pausa com as configurações (GameSettings). Abre pelo botão "II" do HUD ou pelas
## teclas Esc e P. Cada botão de opção troca o valor ao ser tocado, aplica na hora e salva.
## Funciona com o jogo pausado (process_mode = ALWAYS). Coluna central, legível em pé e deitado.

signal resumed
signal settings_changed

const COLUMN_WIDTH := 560
const LABELS := {
	"mao": "Mão",
	"joystick_modo": "Joystick",
	"joystick_tamanho": "Tamanho do joystick",
	"joystick_altura": "Altura do joystick fixo",
	"som": "Som",
	"tremor": "Tremor de tela",
	"numeros_dano": "Números de dano",
}
const VALUE_NAMES := {
	"destro": "Destro",
	"canhoto": "Canhoto",
	"flutuante": "Flutuante",
	"fixo": "Fixo",
	"pequeno": "Pequeno",
	"medio": "Médio",
	"grande": "Grande",
	"baixa": "Baixa",
	"media": "Média",
	"alta": "Alta",
}

var settings: GameSettings
var _buttons := {}  ## chave -> botão
var _resume: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.04, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(COLUMN_WIDTH, 0)
	column.add_theme_constant_override("separation", 12)
	center.add_child(column)
	var title := Label.new()
	title.text = "Pausado"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	column.add_child(title)
	for key in LABELS:
		var row := HBoxContainer.new()
		var name_label := Label.new()
		name_label.text = LABELS[key]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 26)
		row.add_child(name_label)
		var button := _button(26, 72)
		button.custom_minimum_size.x = 210
		button.pressed.connect(_toggle.bind(key))
		row.add_child(button)
		column.add_child(row)
		_buttons[key] = button
	_resume = _button(34, 96)
	_resume.text = "Continuar"
	_resume.pressed.connect(close)
	column.add_child(_resume)


func is_open() -> bool:
	return visible


func open() -> void:
	_refresh()
	visible = true


func close() -> void:
	if not visible:
		return
	visible = false
	resumed.emit()


func option_button(key: String) -> Button:
	return _buttons.get(key)


func resume_button() -> Button:
	return _resume


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if visible and key and key.pressed and not key.echo:
		if key.physical_keycode == KEY_ESCAPE or key.physical_keycode == KEY_P:
			close()
			get_viewport().set_input_as_handled()


func _toggle(key: String) -> void:
	if settings == null:
		return
	settings.cycle(key)
	settings.save()
	_refresh()
	settings_changed.emit()


func _refresh() -> void:
	if settings == null:
		return
	for key in _buttons:
		var value: Variant = settings.values[key]
		var text := str(VALUE_NAMES.get(value, str(value)))
		if value is bool:
			text = "Ligado" if value else "Desligado"
		_buttons[key].text = text
	var fixed: bool = settings.values.joystick_modo == "fixo"
	_buttons["joystick_altura"].disabled = not fixed


func _button(font_size: int, height: int) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, height)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", font_size)
	return button
