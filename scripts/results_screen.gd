class_name ResultsScreen
extends Control
## Tela de fim de partida (vitória ou derrota) com o resumo real da partida, "Jogar de novo",
## "Voltar ao menu" e, numa segunda página, a loja (ShopPanel, a mesma do menu).
## Funciona com o jogo pausado (process_mode = ALWAYS). Coluna de largura fixa, centralizada,
## para ficar legível em retrato e em paisagem.

signal restart_requested
signal menu_requested

const COLUMN_WIDTH := 640
const VICTORY_COLOR := Color(1.0, 0.85, 0.35)
const DEFEAT_COLOR := Color(1.0, 0.45, 0.45)
const MUTED := Color(1, 1, 1, 0.72)

var _summary_page: VBoxContainer
var _shop_page: VBoxContainer
var _title: Label
var _subtitle: Label
var _lines: VBoxContainer
var _ecos_label: Label
var _restart: Button
var _menu: Button
var _shop_button: Button
var _shop: ShopPanel
var _meta: MetaProgress


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false

	add_child(UiStyle.backdrop())
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	_summary_page = _build_summary()
	center.add_child(_summary_page)
	_shop_page = _build_shop()
	_shop_page.visible = false
	center.add_child(_shop_page)


func _build_summary() -> VBoxContainer:
	var column := _column()
	_title = _label(64, Color.WHITE)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_title)
	_subtitle = _label(26, MUTED)
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_subtitle)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(COLUMN_WIDTH, 620)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_lines = VBoxContainer.new()
	_lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lines.add_theme_constant_override("separation", 6)
	scroll.add_child(_lines)
	_ecos_label = _label(28, Color(0.55, 0.95, 1.0))
	_ecos_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ecos_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_ecos_label)
	_restart = UiStyle.button("Jogar de novo", 36, 104, UiStyle.Kind.PRIMARY)
	_restart.pressed.connect(func() -> void: restart_requested.emit())
	column.add_child(_restart)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	column.add_child(row)
	_menu = UiStyle.button("Voltar ao menu", 26, 84)
	_menu.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_menu.pressed.connect(func() -> void: menu_requested.emit())
	row.add_child(_menu)
	_shop_button = UiStyle.button("Loja", 26, 84)
	_shop_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shop_button.pressed.connect(show_shop)
	row.add_child(_shop_button)
	return column


func _build_shop() -> VBoxContainer:
	var column := _column()
	var title := _label(52, Color.WHITE)
	title.text = "Melhorias permanentes"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	_shop = ShopPanel.new()
	column.add_child(_shop)
	var back := UiStyle.button("Voltar", 30, 88, UiStyle.Kind.QUIET)
	back.pressed.connect(show_summary)
	column.add_child(back)
	return column


func _column() -> VBoxContainer:
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(COLUMN_WIDTH, 0)
	column.add_theme_constant_override("separation", 16)
	return column


func is_open() -> bool:
	return visible


func restart_button() -> Button:
	return _restart


func title_text() -> String:
	return _title.text


func menu_button() -> Button:
	return _menu


func shop_button() -> Button:
	return _shop_button


func buy_button(id: StringName) -> Button:
	return _shop.buy_button(id)


func is_shop_open() -> bool:
	return visible and _shop_page.visible


## Mostra o resumo. `data` vem de main.gd (só números realmente contados na partida).
func show_results(data: Dictionary, meta: MetaProgress) -> void:
	_meta = meta
	var won: bool = data.won
	_title.text = "Vitória!" if won else "Você caiu!"
	_title.add_theme_color_override("font_color", VICTORY_COLOR if won else DEFEAT_COLOR)
	_subtitle.text = (
		"O Sentinela do Eco foi derrotado."
		if won
		else "A horda venceu desta vez. Os Ecos ficam com você."
	)
	if data.get("quit", false):
		_title.text = "Partida encerrada"
		_subtitle.text = "Você saiu pela pausa. Os Ecos desta partida ficam com você."
	for child in _lines.get_children():
		child.queue_free()
	_add_line("Tempo", Hud.format_time(data.time))
	_add_line("Nível alcançado", str(data.level))
	_add_line("Inimigos eliminados", str(data.kills))
	_add_line("Dano causado", _number(data.damage_dealt))
	_add_line("Dano recebido", _number(data.damage_taken))
	_add_line("Esquivas", str(data.dodges))
	_add_line("Chefes derrotados", str(data.bosses))
	_add_line("Elites derrotados", str(data.get("elites", 0)))
	_add_line("Fendas do Eco fechadas", str(data.get("rifts", 0)))
	_add_line("Armas evoluídas", str(data.get("evolutions", 0)))
	if data.boss_seconds >= 0.0:
		_add_line("Tempo contra o chefe", Hud.format_time(data.boss_seconds))
	_add_header("Armas")
	for weapon: Dictionary in data.weapons:
		_add_line(
			"%s · Nv. %d" % [weapon.name, weapon.level],
			"%s de dano · %d abates" % [_number(weapon.damage), weapon.kills]
		)
	_add_header("Melhorias")
	if data.upgrades.is_empty():
		_add_line("Nenhuma", "")
	for line: String in data.upgrades:
		_add_line(line, "")
	var note := ""
	if meta and meta.read_only:
		note = " (não salvo: progresso de uma versão mais nova)"
	_ecos_label.text = "+%d Ecos · total %d%s" % [data.ecos_earned, meta.ecos if meta else 0, note]
	show_summary()
	visible = true


func show_summary() -> void:
	_shop_page.visible = false
	_summary_page.visible = true


func show_shop() -> void:
	_summary_page.visible = false
	_shop_page.visible = true
	_shop.meta = _meta


func close() -> void:
	visible = false


func _add_header(text: String) -> void:
	var label := _label(30, Color(1.0, 0.8, 0.5))
	label.text = text
	_lines.add_child(label)


func _add_line(left: String, right: String) -> void:
	var row := HBoxContainer.new()
	var a := _label(26, Color.WHITE)
	a.text = left
	a.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(a)
	var b := _label(26, MUTED)
	b.text = right
	row.add_child(b)
	_lines.add_child(row)


static func _number(value: float) -> String:
	var n := roundi(value)
	var digits := str(absi(n))
	var out := ""
	while digits.length() > 3:
		out = "." + digits.substr(digits.length() - 3) + out
		digits = digits.substr(0, digits.length() - 3)
	return ("-" if n < 0 else "") + digits + out


func _label(font_size: int, color: Color) -> Label:
	return UiStyle.label(font_size, color)
