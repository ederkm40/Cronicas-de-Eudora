class_name LevelUpPanel
extends Control
## Tela de escolha de melhoria. Aparece com o jogo pausado e continua funcionando
## durante a pausa (process_mode = ALWAYS).
##
## Pensada para celular em retrato: três cartões grandes, um embaixo do outro,
## fáceis de tocar com o polegar. No computador, as teclas 1, 2 e 3 também escolhem.

signal chosen(id: StringName)

@export var input_delay := 0.35 ## Segundos com os cartões travados, para um toque do joystick não escolher sem querer.

const CARD_COLOR := Color(0.13, 0.11, 0.18, 0.96)
const CARD_HOVER := Color(0.2, 0.17, 0.28, 0.98)
const CARD_BORDER := Color(0.48, 0.36, 1.0)
const ACCENT := Color(0.45, 0.95, 1.0)

var _title: Label
var _cards_box: VBoxContainer
var _buttons: Array[Button] = []
var _ids: Array[StringName] = []
var _unlock_timer := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.04, 0.78)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 40)
	margin.add_theme_constant_override("margin_top", 200)
	margin.add_theme_constant_override("margin_bottom", 120)
	add_child(margin)

	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 20)
	margin.add_child(column)

	_title = _label(52, Color.WHITE)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_title)

	var subtitle := _label(28, Color(1, 1, 1, 0.7))
	subtitle.text = "Escolha uma melhoria"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(subtitle)

	_cards_box = VBoxContainer.new()
	_cards_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cards_box.add_theme_constant_override("separation", 18)
	column.add_child(_cards_box)


func is_open() -> bool:
	return visible


func choice_ids() -> Array[StringName]:
	return _ids.duplicate()


func is_locked() -> bool:
	return _unlock_timer > 0.0


## Mostra os cartões das melhorias sorteadas.
func open(level: int, ids: Array[StringName], upgrades: Upgrades) -> void:
	_title.text = "Nível %d!" % level
	for child in _cards_box.get_children():
		child.queue_free()
	_buttons.clear()
	_ids = ids.duplicate()
	for i in _ids.size():
		var button := _make_card(i, _ids[i], upgrades)
		_cards_box.add_child(button)
		_buttons.append(button)
	_unlock_timer = input_delay
	_set_buttons_disabled(true)
	visible = true


func close() -> void:
	visible = false
	_ids.clear()


## Escolhe o cartão de posição `index` (0, 1 ou 2). É o mesmo caminho do toque.
func choose(index: int) -> void:
	if not visible or is_locked() or index < 0 or index >= _ids.size():
		return
	var id := _ids[index]
	close()
	chosen.emit(id)


func _process(delta: float) -> void:
	if visible and _unlock_timer > 0.0:
		_unlock_timer -= delta
		if _unlock_timer <= 0.0:
			_set_buttons_disabled(false)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match (event as InputEventKey).physical_keycode:
		KEY_1, KEY_KP_1:
			choose(0)
		KEY_2, KEY_KP_2:
			choose(1)
		KEY_3, KEY_KP_3:
			choose(2)


func _set_buttons_disabled(value: bool) -> void:
	for button in _buttons:
		button.disabled = value


func _make_card(index: int, id: StringName, upgrades: Upgrades) -> Button:
	var definition := Upgrades.definition(id)
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 168)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", _card_style(CARD_COLOR, 2))
	button.add_theme_stylebox_override("hover", _card_style(CARD_HOVER, 3))
	button.add_theme_stylebox_override("pressed", _card_style(CARD_HOVER, 4))
	button.add_theme_stylebox_override("disabled", _card_style(CARD_COLOR, 2))
	button.pressed.connect(choose.bind(index))

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	button.add_child(margin)

	var lines := VBoxContainer.new()
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lines.alignment = BoxContainer.ALIGNMENT_CENTER
	lines.add_theme_constant_override("separation", 6)
	margin.add_child(lines)

	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lines.add_child(header)
	var name_label := _label(34, Color.WHITE)
	name_label.text = definition.name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(name_label)
	var rank := _label(24, Color(1, 1, 1, 0.6))
	rank.text = "%d/%d" % [upgrades.stacks(id), int(definition.max)]
	header.add_child(rank)

	var description := _label(26, Color(1, 1, 1, 0.88))
	description.text = definition.description
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lines.add_child(description)

	var next := _label(24, ACCENT)
	next.text = upgrades.describe_next(id)
	lines.add_child(next)
	return button


func _card_style(color: Color, border: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = CARD_BORDER
	style.set_border_width_all(border)
	style.set_corner_radius_all(16)
	return style


func _label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
