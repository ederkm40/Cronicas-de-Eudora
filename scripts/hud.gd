class_name Hud
extends Control
## Interface da partida: tempo, abates, vida, contador de desempenho e tela de derrota.

signal restart_requested

var _status: Label
var _hp_bar: ProgressBar
var _xp_bar: ProgressBar
var _level_label: Label
var _debug: Label
var _game_over: Control
var _summary: Label


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

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(spacer)

	_debug = _make_label(20)
	_debug.modulate = Color(1, 1, 1, 0.6)
	column.add_child(_debug)

	_build_game_over()


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


func _build_game_over() -> void:
	_game_over = ColorRect.new()
	(_game_over as ColorRect).color = Color(0, 0, 0, 0.6)
	_game_over.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_game_over.mouse_filter = Control.MOUSE_FILTER_STOP
	_game_over.visible = false
	add_child(_game_over)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_game_over.add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	center.add_child(box)

	var title := _make_label(56)
	title.text = "Você caiu!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	_summary = _make_label(30)
	_summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_summary)

	var button := Button.new()
	button.text = "Jogar de novo"
	button.custom_minimum_size = Vector2(360, 96)
	button.add_theme_font_size_override("font_size", 34)
	button.pressed.connect(func() -> void: restart_requested.emit())
	box.add_child(button)


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


func show_game_over(elapsed: float, kills: int, level: int = 1) -> void:
	_summary.text = "Sobreviveu %s\nNível %d · %d abates" % [format_time(elapsed), level, kills]
	_game_over.visible = true


static func format_time(seconds: float) -> String:
	var total := int(seconds)
	return "%02d:%02d" % [total / 60, total % 60]
