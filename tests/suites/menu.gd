extends "res://tests/suites/base.gd"
## Menu inicial (Parte 1): navegação e voltar, configurações e loja compartilhadas com a
## partida, JOGAR com o pacote da escolha, "Voltar ao menu", "Encerrar partida" e o botão
## de pausa visível.

const MENU_SCENE := "res://scenes/menu.tscn"
const TESTS := [
	"test_menu_abre_na_tela_inicial",
	"test_navegacao_voltar_e_esc",
	"test_voltar_do_android_no_menu",
	"test_telas_mostram_personagem_e_missao_atuais",
	"test_configuracoes_do_menu_valem_na_partida",
	"test_configuracoes_da_pausa_aparecem_no_menu",
	"test_loja_do_menu_compra_e_vale_na_partida",
	"test_jogar_abre_a_partida_com_a_escolha",
	"test_resultados_voltar_ao_menu",
	"test_pausa_encerrar_partida_pede_confirmacao",
	"test_voltar_do_celular_na_partida",
	"test_botao_de_pausa_visivel",
	"test_menu_cabe_em_pe",
]


func _open_menu(keep_save: bool = false) -> MainMenu:
	await _close_game()
	paused = false
	RunSetup.current = null
	if not keep_save:
		_delete_save()
		_delete_settings()
	var menu: MainMenu = (load(MENU_SCENE) as PackedScene).instantiate()
	runner.root.add_child(menu)
	current_scene = menu
	game = menu
	await process_frame
	return menu


func _delete_settings() -> void:
	if FileAccess.file_exists(TEST_SETTINGS):
		DirAccess.remove_absolute(TEST_SETTINGS)


## Espera a troca de cena terminar e devolve a cena nova.
func _wait_scene_change(old: Node) -> Node:
	for i in 10:
		await process_frame
		if current_scene != null and current_scene != old and current_scene.is_inside_tree():
			break
	game = current_scene
	return current_scene


func test_menu_abre_na_tela_inicial() -> void:
	_check(
		ProjectSettings.get_setting("application/run/main_scene") == MENU_SCENE,
		"o jogo abre no menu"
	)
	_delete_save()
	var meta := MetaProgress.load_from(TEST_SAVE)
	meta.ecos = 37
	meta.save()
	var menu := await _open_menu(true)
	_check(menu.current_screen() == MainMenu.HOME, "começa na tela inicial")
	_check(menu.meta.ecos == 37, "lê os Ecos salvos")
	_check(_has_text(menu, "Ecos: 37"), "mostra os Ecos")
	_check(menu.play_button().is_visible_in_tree(), "botão JOGAR visível")
	_check(menu.play_button().size.y >= 140.0, "JOGAR grande para o polegar")
	for screen in [MainMenu.CHARACTERS, MainMenu.MISSIONS, MainMenu.SHOP, MainMenu.SETTINGS]:
		var button := menu.nav_button(screen)
		_check(button != null and button.is_visible_in_tree(), "botão %s visível" % screen)


func test_navegacao_voltar_e_esc() -> void:
	var menu := await _open_menu()
	for screen in [MainMenu.CHARACTERS, MainMenu.MISSIONS, MainMenu.SHOP, MainMenu.SETTINGS]:
		menu.nav_button(screen).pressed.emit()
		_check(menu.current_screen() == screen, "abre %s" % screen)
		_check(not menu.play_button().is_visible_in_tree(), "a inicial some em %s" % screen)
		var back := menu.back_button()
		_check(back != null and back.is_visible_in_tree(), "%s tem Voltar" % screen)
		back.pressed.emit()
		_check(menu.current_screen() == MainMenu.HOME, "Voltar leva à inicial (%s)" % screen)
	menu.nav_button(MainMenu.SHOP).pressed.emit()
	_key(KEY_ESCAPE, true)
	_key(KEY_ESCAPE, false)
	await process_frame
	_check(menu.current_screen() == MainMenu.HOME, "Esc volta à inicial")
	menu.back()
	_check(menu.current_screen() == MainMenu.HOME, "voltar na inicial não sai dela")


func test_voltar_do_android_no_menu() -> void:
	var menu := await _open_menu()
	menu.nav_button(MainMenu.SETTINGS).pressed.emit()
	menu.back_navigation().notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	_check(menu.current_screen() == MainMenu.HOME, "o voltar do Android volta à inicial")


func test_telas_mostram_personagem_e_missao_atuais() -> void:
	var menu := await _open_menu()
	menu.nav_button(MainMenu.CHARACTERS).pressed.emit()
	_check(_has_text(menu, MainMenu.CHARACTER_NAME), "mostra o personagem atual")
	_check(_has_text(menu, "Vida: 100"), "vida do código (100)")
	_check(_has_text(menu, "Velocidade: 5,0 m/s"), "velocidade do código (5,0 m/s)")
	_check(_has_text(menu, "Arma inicial: Raio arcano"), "arma inicial do código")
	menu.back()
	menu.nav_button(MainMenu.MISSIONS).pressed.emit()
	_check(_has_text(menu, MainMenu.MISSION_NAME), "mostra a missão atual")
	_check(_has_text(menu, "Aos 10:00 surge a Sentinela do Eco."), "hora do chefe do código")
	_check(_has_text(menu, MainMenu.COMING_SOON), "avisa que outras opções virão")


func test_configuracoes_do_menu_valem_na_partida() -> void:
	var menu := await _open_menu()
	menu.nav_button(MainMenu.SETTINGS).pressed.emit()
	var hand := menu.settings_panel().option_button("mao")
	_check(hand.text == "Destro", "começa destro")
	hand.pressed.emit()
	_check(hand.text == "Canhoto", "troca para canhoto")
	_check(GameSettings.load_from().left_handed(), "salvo no arquivo")
	menu.play_button().pressed.emit()
	var main := await _wait_scene_change(menu)
	_check(main.settings.left_handed(), "a partida abre canhota")
	main.open_pause()
	_check(main.pause_menu.option_button("mao").text == "Canhoto", "a pausa mostra canhoto")


func test_configuracoes_da_pausa_aparecem_no_menu() -> void:
	_delete_settings()
	await _new_game()
	game.open_pause()
	game.pause_menu.option_button("som").pressed.emit()
	_check(not game.settings.values.som, "som desligado na pausa")
	var menu := await _open_menu(true)
	menu.nav_button(MainMenu.SETTINGS).pressed.emit()
	_check(menu.settings_panel().option_button("som").text == "Desligado", "o menu mostra")
	_delete_settings()


func test_loja_do_menu_compra_e_vale_na_partida() -> void:
	_delete_save()
	var meta := MetaProgress.load_from(TEST_SAVE)
	meta.ecos = 100
	meta.save()
	var menu := await _open_menu(true)
	menu.nav_button(MainMenu.SHOP).pressed.emit()
	var buy := menu.shop_panel().buy_button(MetaProgress.VIGOR)
	_check(buy != null and not buy.disabled, "Vigor à venda")
	buy.pressed.emit()
	_check(menu.meta.level_of(MetaProgress.VIGOR) == 1, "comprado")
	var saved := MetaProgress.load_from(TEST_SAVE)
	_check(saved.level_of(MetaProgress.VIGOR) == 1 and saved.ecos == 85, "salvo (85 Ecos)")
	menu.back()
	_check(_has_text(menu, "Ecos: 85"), "a inicial mostra os Ecos depois da compra")
	menu.play_button().pressed.emit()
	var main := await _wait_scene_change(menu)
	_check(_near(main.player.max_hp, 108.0), "Vigor 1 na partida: 108 de vida")


func test_jogar_abre_a_partida_com_a_escolha() -> void:
	var menu := await _open_menu()
	menu.play_button().pressed.emit()
	menu.play_button().pressed.emit()  # dois toques rápidos abrem uma partida só
	var main := await _wait_scene_change(menu)
	_check(main != null and main.has_method("start_encounter"), "abriu a partida")
	_check(not is_instance_valid(menu), "o menu foi liberado")
	_check(RunSetup.current != null, "a escolha foi gravada")
	_check(main.setup.character_id == RunSetup.DEFAULT_CHARACTER, "personagem atual")
	_check(main.setup.mission_id == RunSetup.DEFAULT_MISSION, "missão atual")
	_check(_near(main.encounter_time, 600.0), "a partida continua igual (chefe aos 600 s)")
	RunSetup.current = null


func test_resultados_voltar_ao_menu() -> void:
	await _new_game()
	game.player.take_damage(1.0e6, "teste")
	await _frames(1)
	_check(game.results.is_open(), "resultados abertos")
	var menu_button: Button = game.results.menu_button()
	_check(menu_button.is_visible_in_tree(), "botão Voltar ao menu visível")
	_check(game.results.restart_button().is_visible_in_tree(), "Jogar de novo continua")
	var old: Node = game
	menu_button.pressed.emit()
	var menu: Node = await _wait_scene_change(old)
	_check(menu is MainMenu, "voltou ao menu")
	_check(not paused, "o jogo não fica pausado no menu")
	_check(menu.current_screen() == MainMenu.HOME, "na tela inicial")


func test_pausa_encerrar_partida_pede_confirmacao() -> void:
	await _new_game()
	game.open_pause()
	var quit: Button = game.pause_menu.quit_button()
	quit.pressed.emit()
	_check(game.pause_menu.is_open(), "o primeiro toque só pede confirmação")
	_check(quit.text == PauseMenu.CONFIRM_TEXT, "o botão pede outro toque")
	_check(not game.is_over(), "a partida continua")
	game.pause_menu.close()
	game.open_pause()
	_check(quit.text == PauseMenu.QUIT_TEXT, "reabrir a pausa cancela a confirmação")
	quit.pressed.emit()
	quit.pressed.emit()
	_check(game.is_over() and not game.is_victory(), "encerrada como derrota")
	_check(game.results.is_open(), "abre os resultados")
	_check(game.results.title_text() == "Partida encerrada", "título próprio")
	_check(paused, "a partida fica congelada atrás dos resultados")
	_check(game.meta.runs == 1, "a partida conta no progresso")


func test_voltar_do_celular_na_partida() -> void:
	await _new_game()
	game.back_navigation.back_requested.emit()
	_check(game.pause_menu.is_open() and paused, "o voltar abre a pausa")
	game.back_navigation.back_requested.emit()
	_check(not game.pause_menu.is_open() and not paused, "o voltar de novo continua")
	_grant_level()
	await _frames(1)
	_check(game.level_up_panel.is_open(), "level-up aberto")
	game.back_navigation.back_requested.emit()
	_check(not game.pause_menu.is_open(), "no level-up o voltar não abre a pausa")


func test_botao_de_pausa_visivel() -> void:
	await _new_game()
	var button: Button = game.hud.pause_button()
	_check(button.size.x >= 88.0 and button.size.y >= 72.0, "grande (%s)" % button.size)
	var style := button.get_theme_stylebox("normal") as StyleBoxFlat
	_check(style != null, "tem fundo próprio")
	if style:
		_check(style.border_width_left >= 2, "tem borda")
		var ground := Color(0.14, 0.13, 0.17)
		var contrast := style.border_color.get_luminance() - ground.get_luminance()
		_check(contrast > 0.3, "a borda se destaca do chão (%.2f)" % contrast)


func test_menu_cabe_em_pe() -> void:
	var menu := await _open_menu()
	var home := menu.play_button().get_parent() as Control
	var needed := home.get_combined_minimum_size()
	_check(needed.x <= 720.0, "a tela inicial cabe na largura (%.0f)" % needed.x)
	_check(needed.y <= 1180.0, "a tela inicial cabe na altura (%.0f)" % needed.y)
	menu.nav_button(MainMenu.SETTINGS).pressed.emit()
	var back := menu.back_button()
	_check(back.get_global_rect().position.y >= 0.0, "Voltar dentro da tela")


## Algum Label visível do nó contém o texto?
func _has_text(node: Node, text: String) -> bool:
	for child in node.find_children("*", "Label", true, false):
		var label := child as Label
		if label.is_visible_in_tree() and text in label.text:
			return true
	return false
