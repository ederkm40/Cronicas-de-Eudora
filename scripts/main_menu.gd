class_name MainMenu
extends Control
## Menu inicial: a primeira tela do jogo. Mostra o título, os Ecos e o botão JOGAR, e leva
## às telas de Personagens, Missões, Loja e Configurações. Toda tela tem "Voltar"; o voltar
## do navegador ou do Android e o Esc fazem o mesmo (BackNavigation).
##
## Ao tocar em JOGAR, o menu grava a escolha em `RunSetup.current` e troca para a partida.
## Parte 1: só existem o personagem e a missão atuais, mostrados com números do código.

signal screen_changed(screen: StringName)

const GAME_SCENE := "res://scenes/main.tscn"
const GAME_SCRIPT := "res://scripts/main.gd"  ## Para ler a hora do chefe sem abrir a partida.
const QA_BRIDGE_PATH := "res://scripts/web_bridge.gd"
const COLUMN_WIDTH := 600
const HOME := &"inicio"
const CHARACTERS := &"personagens"
const MISSIONS := &"missoes"
const SHOP := &"loja"
const SETTINGS := &"configuracoes"
const TITLES := {
	CHARACTERS: "Personagens",
	MISSIONS: "Missões",
	SHOP: "Loja",
	SETTINGS: "Configurações",
}
const CHARACTER_NAME := "Personagem padrão"
const MISSION_NAME := "Partida padrão"
const COMING_SOON := "Mais opções chegam nas próximas etapas do menu."

var meta: MetaProgress
var settings: GameSettings
var setup: RunSetup
var _screens := {}  ## nome -> tela (Control)
var _back_buttons := {}  ## nome -> botão Voltar da tela
var _nav_buttons := {}  ## nome -> botão da tela inicial
var _current: StringName = HOME
var _play: Button
var _ecos: Label
var _selection: Label
var _shop: ShopPanel
var _settings_panel: SettingsPanel
var _back: BackNavigation
var _starting := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	meta = MetaProgress.load_from()
	settings = GameSettings.load_from()
	setup = RunSetup.take()
	var background := ColorRect.new()
	background.color = Color(0.07, 0.06, 0.09)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	_screens[HOME] = _build_home()
	_screens[CHARACTERS] = _build_screen(CHARACTERS, _build_characters())
	_screens[MISSIONS] = _build_screen(MISSIONS, _build_missions())
	_shop = ShopPanel.new()
	_shop.purchased.connect(func(_id: StringName) -> void: _refresh_home())
	_screens[SHOP] = _build_screen(SHOP, _shop)
	_shop.meta = meta
	_settings_panel = SettingsPanel.new()
	_screens[SETTINGS] = _build_screen(SETTINGS, _settings_panel)
	_settings_panel.settings = settings

	_back = BackNavigation.new()
	add_child(_back)
	_back.back_requested.connect(back)
	_refresh_home()
	show_screen(HOME)
	_pulse_play()
	_attach_qa_bridge()


# ---------------------------------------------------------------- navegação


func current_screen() -> StringName:
	return _current


func show_screen(screen: StringName) -> void:
	if not _screens.has(screen):
		return
	for key in _screens:
		_screens[key].visible = key == screen
	_current = screen
	if screen == SHOP:
		_shop.refresh()
	elif screen == SETTINGS:
		_settings_panel.refresh()
	elif screen == HOME:
		_refresh_home()
	screen_changed.emit(screen)


## Voltar: de qualquer tela para a inicial. Na inicial não faz nada (não há para onde ir).
func back() -> void:
	if _current != HOME:
		show_screen(HOME)


## Grava a escolha e abre a partida.
func start_run() -> void:
	if _starting:
		return
	_starting = true
	RunSetup.current = setup
	get_tree().change_scene_to_file(GAME_SCENE)


func play_button() -> Button:
	return _play


func nav_button(screen: StringName) -> Button:
	return _nav_buttons.get(screen)


func back_button(screen: StringName = _current) -> Button:
	return _back_buttons.get(screen)


func shop_panel() -> ShopPanel:
	return _shop


func settings_panel() -> SettingsPanel:
	return _settings_panel


func back_navigation() -> BackNavigation:
	return _back


# ---------------------------------------------------------------- telas


func _build_home() -> Control:
	var column := _centered_column()
	var title := UiStyle.label(68, UiStyle.GOLD)
	title.text = "Crônicas\nde Eudora"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)
	_ecos = UiStyle.label(32, UiStyle.ACCENT)
	_ecos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(_ecos)
	column.add_child(_spacer(24))
	_play = UiStyle.button("JOGAR", 56, 150, UiStyle.Kind.PRIMARY)
	_play.pressed.connect(start_run)
	column.add_child(_play)
	_selection = UiStyle.label(22, UiStyle.MUTED)
	_selection.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_selection.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_selection)
	column.add_child(_spacer(12))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	column.add_child(grid)
	for screen: StringName in [CHARACTERS, MISSIONS, SHOP, SETTINGS]:
		var button := UiStyle.button(TITLES[screen], 30, 112)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(show_screen.bind(screen))
		grid.add_child(button)
		_nav_buttons[screen] = button
	return column.get_parent().get_parent()


## Tela secundária: "Voltar" e título no alto, conteúdo com rolagem (cabe na tela deitada).
func _build_screen(screen: StringName, content: Control) -> Control:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 48)
	margin.add_theme_constant_override("margin_bottom", 32)
	root.add_child(margin)
	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 20)
	margin.add_child(outer)
	var header := HBoxContainer.new()
	header.custom_minimum_size.x = COLUMN_WIDTH
	header.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	header.add_theme_constant_override("separation", 20)
	outer.add_child(header)
	var back_button := UiStyle.button("‹ Voltar", 28, 80, UiStyle.Kind.QUIET)
	back_button.custom_minimum_size.x = 190
	back_button.pressed.connect(back)
	header.add_child(back_button)
	_back_buttons[screen] = back_button
	var title := UiStyle.label(44, UiStyle.GOLD)
	title.text = TITLES[screen]
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)
	content.custom_minimum_size.x = COLUMN_WIDTH
	center.add_child(content)
	return root


func _build_characters() -> Control:
	var player := Player as Script
	var lines := [
		"Vida: %d" % roundi(player.get_property_default_value("base_max_hp")),
		"Velocidade: %s m/s" % _decimal(float(player.get_property_default_value("move_speed"))),
		"Arma inicial: %s" % WeaponCatalog.definition(WeaponCatalog.BOLT).name,
		"Esquiva: duplo toque no joystick",
	]
	return _choice_list(CHARACTER_NAME, lines)


func _build_missions() -> Control:
	var main_script := load(GAME_SCRIPT) as Script
	var boss_at := float(main_script.get_property_default_value("encounter_time"))
	var lines := [
		"Sobreviva às hordas e fique mais forte.",
		"Aos %s surge a Sentinela do Eco." % Hud.format_time(boss_at),
		"Vitória: derrotar a Sentinela.",
	]
	return _choice_list(MISSION_NAME, lines)


## Lista com uma opção (a atual, já escolhida) e o aviso de que outras virão.
func _choice_list(title: String, lines: Array) -> Control:
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	var card := PanelContainer.new()
	card.add_theme_stylebox_override(
		"panel", UiStyle.box(Color(0.2, 0.16, 0.1, 0.95), UiStyle.GOLD, 3)
	)
	column.add_child(card)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 6)
	card.add_child(body)
	var name_label := UiStyle.label(34)
	name_label.text = title
	body.add_child(name_label)
	var chosen := UiStyle.label(24, UiStyle.GOLD)
	chosen.text = "Escolhido"
	body.add_child(chosen)
	for line: String in lines:
		var text := UiStyle.label(24, UiStyle.MUTED)
		text.text = line
		text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.add_child(text)
	var note := UiStyle.label(22, UiStyle.MUTED)
	note.text = COMING_SOON
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(note)
	return column


func _refresh_home() -> void:
	if _ecos == null:
		return
	_ecos.text = "Ecos: %d" % (meta.ecos if meta else 0)
	_selection.text = "%s · %s" % [CHARACTER_NAME, MISSION_NAME]


## Coluna centralizada na tela inteira (tela inicial).
func _centered_column() -> VBoxContainer:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(COLUMN_WIDTH, 0)
	column.add_theme_constant_override("separation", 16)
	center.add_child(column)
	return column


## Número com uma casa e vírgula, como no Brasil (5,0).
static func _decimal(value: float) -> String:
	return ("%.1f" % value).replace(".", ",")


func _spacer(height: int) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	return spacer


## O botão JOGAR brilha devagar: chama o polegar e mostra que o jogo está vivo.
func _pulse_play() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(_play, "modulate", Color(1.25, 1.2, 1.1), 0.9)
	tween.tween_property(_play, "modulate", Color.WHITE, 0.9)


## Ponte de testes do navegador: só na build "Web QA" (ver main.gd).
func _attach_qa_bridge() -> void:
	if not (OS.has_feature("web") and OS.has_feature("qa")):
		return
	if not ResourceLoader.exists(QA_BRIDGE_PATH):
		return
	add_child((load(QA_BRIDGE_PATH) as GDScript).new())
