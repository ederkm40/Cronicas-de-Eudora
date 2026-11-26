class_name Hud
extends Control
## Interface da partida: tempo, abates, vida, experiência, armas, barra do chefe,
## avisos no meio da tela e o indicador da esquiva. O fim da partida fica em ResultsScreen.

var _status: Label
var _hp_bar: ProgressBar
var _xp_bar: ProgressBar
var _level_label: Label
var _weapons: Label
var _boss_box: VBoxContainer
var _boss_name: Label
var _boss_bar: ProgressBar
var _banner: Label
var _banner_time := 0.0
var _dodge_label: Label
var _dodge_bar: ProgressBar
var _debug: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 56)
	margin.add_theme_constant_override("margin_bottom", 32)
	add_child(margin)

	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	_status = _make_label(34)
	column.add_child(_status)

	_hp_bar = _make_bar(Color(0.85, 0.25, 0.3), 22)
	column.add_child(_hp_bar)

	# Linha da experiência: "Nv. 3" + barra até o próximo nível.
	var xp_row := HBoxContainer.new()
	xp_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	xp_row.add_theme_constant_override("separation", 12)
	column.add_child(xp_row)
	_level_label = _make_label(26)
	_level_label.custom_minimum_size = Vector2(96, 0)
	xp_row.add_child(_level_label)
	_xp_bar = _make_bar(Color(0.35, 0.95, 1.0), 16)
	_xp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_xp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	xp_row.add_child(_xp_bar)

	_weapons = _make_label(22)
	_weapons.modulate = Color(1, 0.9, 0.75, 0.9)
	column.add_child(_weapons)

	# Barra do chefe: só aparece no encontro final.
	_boss_box = VBoxContainer.new()
	_boss_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_boss_box.visible = false
	column.add_child(_boss_box)
	_boss_name = _make_label(26)
	_boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_box.add_child(_boss_name)
	_boss_bar = _make_bar(Color(0.9, 0.3, 0.75), 20)
	_boss_box.add_child(_boss_bar)

	_banner = _make_label(36)
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_banner.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	column.add_child(_banner)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(spacer)

	# Esquiva: pequena e no rodapé, para não disputar espaço com o polegar.
	var dodge_row := HBoxContainer.new()
	dodge_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dodge_row.alignment = BoxContainer.ALIGNMENT_CENTER
	dodge_row.add_theme_constant_override("separation", 10)
	column.add_child(dodge_row)
	_dodge_label = _make_label(22)
	dodge_row.add_child(_dodge_label)
	_dodge_bar = _make_bar(Color(0.5, 1.0, 1.0), 10)
	_dodge_bar.custom_minimum_size = Vector2(120, 10)
	_dodge_bar.max_value = 1.0
	_dodge_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dodge_row.add_child(_dodge_bar)

	_debug = _make_label(20)
	_debug.modulate = Color(1, 1, 1, 0.6)
	column.add_child(_debug)


func _process(delta: float) -> void:
	if _banner_time > 0.0:
		_banner_time -= delta
		if _banner_time <= 0.0:
			_banner.text = ""


func _make_bar(color: Color, height: int) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, height)
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(6)
	var back := StyleBoxFlat.new()
	back.bg_color = Color(1, 1, 1, 0.12)
	back.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", back)
	return bar


func _make_label(font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("outline_size", 6)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func update_stats(elapsed: float, kills: int, hp: float, max_hp: float, enemy_count: int,
		level: int = 1, xp: int = 0, xp_needed: int = 1) -> void:
	_status.text = "%s   ·   Abates: %d" % [format_time(elapsed), kills]
	_hp_bar.max_value = max_hp
	_hp_bar.value = hp
	_level_label.text = "Nv. %d" % level
	_xp_bar.max_value = xp_needed
	_xp_bar.value = xp
	_debug.text = "FPS %d   ·   Inimigos %d" % [Engine.get_frames_per_second(), enemy_count]


func xp_bar_ratio() -> float:
	return _xp_bar.value / _xp_bar.max_value


## Linha com as armas e seus níveis.
func set_weapons(text: String) -> void:
	_weapons.text = text


func weapons_text() -> String:
	return _weapons.text


## Barra de vida do chefe. `ratio` de 0 a 1.
func set_boss(visible_bar: bool, ratio: float = 1.0, title: String = "") -> void:
	_boss_box.visible = visible_bar
	_boss_bar.max_value = 1.0
	_boss_bar.value = ratio
	_boss_name.text = title


func boss_bar_visible() -> bool:
	return _boss_box.visible


func boss_bar_ratio() -> float:
	return _boss_bar.value


## Aviso no meio da tela por alguns segundos (0 = fica até ser trocado).
func show_banner(text: String, seconds: float = 3.0) -> void:
	_banner.text = text
	_banner_time = seconds


func banner_text() -> String:
	return _banner.text


## 1 = esquiva pronta.
func set_dodge(charge: float) -> void:
	_dodge_bar.value = charge
	_dodge_label.text = "Esquiva pronta" if charge >= 1.0 else "Esquiva"
	_dodge_label.modulate = Color(0.6, 1.0, 1.0) if charge >= 1.0 else Color(1, 1, 1, 0.55)


static func format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%02d:%02d" % [total / 60, total % 60]
