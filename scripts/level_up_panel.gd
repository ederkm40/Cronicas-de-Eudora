class_name LevelUpPanel
extends Control
## Tela de escolha do level-up. Aparece com o jogo pausado e continua funcionando
## durante a pausa (process_mode = ALWAYS).
##
## Pensada para celular em retrato: até três cartões grandes, um embaixo do outro,
## fáceis de tocar com o polegar. Cada cartão diz se é uma arma nova, a evolução de uma
## arma ou uma melhoria. Ao lado de cada cartão há o botão de bloquear, e embaixo o de
## trocar as opções. No computador: teclas 1, 2 e 3 escolhem; R troca.
## Na tela deitada, a coluna fica centralizada com largura fixa.

signal chosen(id: StringName)
signal reroll_requested
signal banish_requested(index: int)

const CARD_COLOR := Color(0.13, 0.11, 0.18, 0.96)
const CARD_HOVER := Color(0.2, 0.17, 0.28, 0.98)
const CARD_BORDER := Color(0.48, 0.36, 1.0)
const WEAPON_BORDER := Color(1.0, 0.62, 0.25)
const EVOLUTION_BORDER := Color(1.0, 0.9, 0.35)
const ACCENT := Color(0.45, 0.95, 1.0)
const WEAPON_ACCENT := Color(1.0, 0.75, 0.4)
const COLUMN_WIDTH := 640

## Segundos com os cartões travados, para um toque do joystick não escolher sem querer.
@export var input_delay := 0.35

var _title: Label
var _cards_box: VBoxContainer
var _reroll_button: Button
var _banish_info: Label
var _buttons: Array[Button] = []
var _lock_buttons: Array[Button] = []
var _ids: Array[StringName] = []
var _offers: LevelUpOffers
var _unlock_timer := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.01, 0.04, 0.8)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.custom_minimum_size = Vector2(COLUMN_WIDTH, 0)
	column.add_theme_constant_override("separation", 18)
	center.add_child(column)

	_title = _label(52, Color.WHITE)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_title)

	var subtitle := _label(28, Color(1, 1, 1, 0.7))
	subtitle.text = "Escolha uma opção"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(subtitle)

	_cards_box = VBoxContainer.new()
	_cards_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cards_box.add_theme_constant_override("separation", 16)
	column.add_child(_cards_box)

	var footer := HBoxContainer.new()
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_theme_constant_override("separation", 16)
	column.add_child(footer)
	_reroll_button = Button.new()
	_reroll_button.custom_minimum_size = Vector2(300, 84)
	_reroll_button.focus_mode = Control.FOCUS_NONE
	_reroll_button.add_theme_font_size_override("font_size", 28)
	_reroll_button.pressed.connect(reroll)
	footer.add_child(_reroll_button)
	_banish_info = _label(24, Color(1, 1, 1, 0.7))
	_banish_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_banish_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_banish_info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(_banish_info)


func is_open() -> bool:
	return visible


func choice_ids() -> Array[StringName]:
	return _ids.duplicate()


func is_locked() -> bool:
	return _unlock_timer > 0.0


## Mostra os cartões das ofertas sorteadas.
func open(level: int, ids: Array[StringName], offers: LevelUpOffers) -> void:
	_title.text = "Nível %d!" % level
	_offers = offers
	show_choices(ids)
	_unlock_timer = input_delay
	_set_buttons_disabled(true)
	visible = true


## Troca os cartões mostrados (abertura, troca de opções ou bloqueio).
func show_choices(ids: Array[StringName]) -> void:
	for child in _cards_box.get_children():
		_cards_box.remove_child(child)
		child.queue_free()
	_buttons.clear()
	_lock_buttons.clear()
	_ids = ids.duplicate()
	for i in _ids.size():
		var row := HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override("separation", 12)
		var card := _make_card(i, _ids[i])
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(card)
		var lock := _make_lock_button(i)
		row.add_child(lock)
		_cards_box.add_child(row)
		_buttons.append(card)
		_lock_buttons.append(lock)
	_refresh_footer()
	_set_buttons_disabled(is_locked())


func _refresh_footer() -> void:
	if _offers == null:
		return
	_reroll_button.text = "Trocar opções (%d)" % _offers.rerolls_left
	_reroll_button.disabled = is_locked() or not _offers.can_reroll()
	_banish_info.text = "Bloqueios: %d" % _offers.banishes_left
	for i in _lock_buttons.size():
		_lock_buttons[i].disabled = is_locked() or not _offers.can_banish(_ids[i])


func reroll_button() -> Button:
	return _reroll_button


func card_buttons() -> Array[Button]:
	return _buttons.duplicate()


func lock_buttons() -> Array[Button]:
	return _lock_buttons.duplicate()


## Pede a troca das opções (mesmo caminho do botão).
func reroll() -> void:
	if visible and not is_locked() and _offers and _offers.can_reroll():
		reroll_requested.emit()


## Pede o bloqueio do cartão `index` (mesmo caminho do botão).
func banish(index: int) -> void:
	if not visible or is_locked() or index < 0 or index >= _ids.size():
		return
	if _offers and _offers.can_banish(_ids[index]):
		banish_requested.emit(index)


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
			_refresh_footer()


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
		KEY_R:
			reroll()


func _set_buttons_disabled(value: bool) -> void:
	for button in _buttons:
		button.disabled = value
	if value:
		_reroll_button.disabled = true
		for lock in _lock_buttons:
			lock.disabled = true


func _make_card(index: int, id: StringName) -> Button:
	var is_evolution := not WeaponCatalog.evolution(id).is_empty()
	var is_weapon := WeaponCatalog.is_weapon(id) or is_evolution
	var border := WEAPON_BORDER if is_weapon else CARD_BORDER
	if is_evolution:
		border = EVOLUTION_BORDER
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 176)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override("normal", _card_style(CARD_COLOR, 2, border))
	button.add_theme_stylebox_override("hover", _card_style(CARD_HOVER, 3, border))
	button.add_theme_stylebox_override("pressed", _card_style(CARD_HOVER, 4, border))
	button.add_theme_stylebox_override("disabled", _card_style(CARD_COLOR, 2, border))
	button.pressed.connect(choose.bind(index))

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	button.add_child(margin)

	var lines := VBoxContainer.new()
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lines.alignment = BoxContainer.ALIGNMENT_CENTER
	lines.add_theme_constant_override("separation", 4)
	margin.add_child(lines)

	var tag := _label(20, border)
	tag.text = _offers.tag_of(id) if _offers else ""
	lines.add_child(tag)
	var name_label := _label(32, Color.WHITE)
	name_label.text = _offers.name_of(id) if _offers else String(id)
	lines.add_child(name_label)
	var description := _label(23, Color(1, 1, 1, 0.86))
	description.text = _offers.description_of(id) if _offers else ""
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lines.add_child(description)
	var next := _label(22, WEAPON_ACCENT if is_weapon else ACCENT)
	next.text = _offers.detail_of(id) if _offers else ""
	next.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lines.add_child(next)
	return button


## Botão de bloquear: tira a opção desta partida e põe outra no lugar.
func _make_lock_button(index: int) -> Button:
	var lock := Button.new()
	lock.text = "Bloquear"
	lock.custom_minimum_size = Vector2(118, 0)
	lock.focus_mode = Control.FOCUS_NONE
	lock.add_theme_font_size_override("font_size", 20)
	lock.add_theme_stylebox_override("normal", _card_style(Color(0.1, 0.08, 0.13, 0.95), 1))
	lock.add_theme_stylebox_override("hover", _card_style(Color(0.2, 0.1, 0.14, 0.98), 2))
	lock.add_theme_stylebox_override("pressed", _card_style(Color(0.3, 0.1, 0.14, 0.98), 2))
	lock.add_theme_stylebox_override("disabled", _card_style(Color(0.08, 0.07, 0.1, 0.6), 1))
	lock.pressed.connect(banish.bind(index))
	return lock


func _card_style(color: Color, border: int, border_color: Color = CARD_BORDER) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(border)
	style.set_corner_radius_all(16)
	return style


func _label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
