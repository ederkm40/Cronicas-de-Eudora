class_name ShopPanel
extends VBoxContainer
## Loja das melhorias permanentes, paga com Ecos (MetaProgress). Usada no menu e na tela de
## resultados. Cada compra é salva na hora.

signal purchased(id: StringName)

const NOTE := "Valem a partir da próxima partida e ficam salvas neste navegador."

var meta: MetaProgress:
	set(value):
		meta = value
		refresh()
var _ecos: Label
var _rows: VBoxContainer
var _buttons := {}  ## id -> botão de compra


func _ready() -> void:
	add_theme_constant_override("separation", 14)
	_ecos = UiStyle.label(30, UiStyle.ACCENT)
	_ecos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_ecos)
	var note := UiStyle.label(22, UiStyle.MUTED)
	note.text = NOTE
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(note)
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 12)
	add_child(_rows)
	refresh()


func buy_button(id: StringName) -> Button:
	return _buttons.get(id)


func refresh() -> void:
	if _rows == null:
		return
	for child in _rows.get_children():
		child.queue_free()
	_buttons.clear()
	if meta == null:
		_ecos.text = ""
		return
	_ecos.text = "Ecos: %d" % meta.ecos
	for definition in MetaProgress.UPGRADES:
		var id: StringName = definition.id
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		var text := VBoxContainer.new()
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_label := UiStyle.label(28)
		name_label.text = "%s  %d/%d" % [definition.name, meta.level_of(id), meta.max_level_of(id)]
		text.add_child(name_label)
		var description := UiStyle.label(22, UiStyle.MUTED)
		description.text = definition.description
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text.add_child(description)
		row.add_child(text)
		var cost := meta.cost_of(id)
		var buy := UiStyle.button("Máximo" if cost < 0 else "%d Ecos" % cost, 24, 76)
		buy.custom_minimum_size.x = 170
		buy.disabled = not meta.can_buy(id)
		buy.pressed.connect(_buy.bind(id))
		row.add_child(buy)
		_rows.add_child(row)
		_buttons[id] = buy


func _buy(id: StringName) -> void:
	if meta and meta.buy(id):
		meta.save()
		purchased.emit(id)
	refresh()
