extends "res://tests/suites/base.gd"
## Integridade do arquivo de progressão permanente e retomada do joystick depois da pausa
## (manutenção pós-0.3-alpha).

const TESTS := [
	"test_save_estrutura_invalida_recomeca_com_copia",
	"test_save_campos_invalidos_sao_ajustados",
	"test_save_campos_ausentes_e_desconhecidos",
	"test_save_futuro_invalido_nao_quebra_nem_sobrescreve",
	"test_save_invalido_nao_impede_a_partida",
	"test_joystick_retoma_com_dedo_pressionado",
	"test_joystick_solto_durante_a_pausa_volta_neutro",
	"test_joystick_segue_o_dedo_movido_na_pausa",
	"test_joystick_varios_level_ups_seguidos",
	"test_joystick_retomada_sem_esquiva_acidental",
	"test_atracao_do_eco_texto_e_efeito_no_ima",
]


func _write_save(text: String) -> void:
	_delete_save()
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _read_file(file_path: String) -> String:
	return FileAccess.get_file_as_string(file_path) if FileAccess.file_exists(file_path) else ""


# ---------------------------------------------------------------- save


func test_save_estrutura_invalida_recomeca_com_copia() -> void:
	var cases := [
		"[1, 2, 3]",
		'"texto"',
		"{isso não é json",
		'{"versao": "um", "ecos": 50}',
		'{"versao": -1, "ecos": 50}',
		'{"versao": 1, "ecos": 50, "estatisticas": [1, 2]}',
		'{"versao": 1, "ecos": 50, "estatisticas": "x"}',
		'{"versao": 1, "ecos": 50, "estatisticas": null}',
		'{"versao": 1, "ecos": 50, "melhorias": [3]}',
		'{"versao": 1, "ecos": 50, "melhorias": "vigor"}',
		'{"versao": 1, "ecos": 50, "melhorias": null}',
	]
	for text: String in cases:
		_write_save(text)
		var meta := MetaProgress.load_from(TEST_SAVE)
		var note := meta.load_note
		_check(note == "corrompido", "%s: deveria ser corrompido (%s)" % [text, note])
		var empty := meta.ecos == 0 and meta.level_of(MetaProgress.VIGOR) == 0
		_check(empty, "%s: começa do zero" % text)
		_check(not meta.load_issues.is_empty(), "%s: o motivo deveria ser registrado" % text)
		var copy := _read_file(TEST_SAVE + ".corrompido")
		_check(copy == text, "%s: cópia idêntica ao original" % text)
		_check(_read_file(TEST_SAVE) == text, "%s: o original não é sobrescrito ao carregar" % text)
	# Depois de salvar, o arquivo volta a ser válido e a cópia continua lá.
	_write_save('{"versao": 1, "melhorias": [3]}')
	var meta := MetaProgress.load_from(TEST_SAVE)
	meta.ecos = 7
	_check(meta.save(), "a progressão nova deveria salvar")
	var again := MetaProgress.load_from(TEST_SAVE)
	_check(again.load_note == "carregado" and again.ecos == 7, "o arquivo salvo é válido")
	var kept := _read_file(TEST_SAVE + ".corrompido")
	_check(kept == '{"versao": 1, "melhorias": [3]}', "cópia mantida")
	_delete_save()


func test_save_campos_invalidos_sao_ajustados() -> void:
	var text := (
		'{"versao": 1, "ecos": -40, "estatisticas": {"partidas": "três", "vitorias": 2.5,'
		+ ' "abates": -1, "melhor_tempo": "x"}, "melhorias": {"vigor_ancestral": 9,'
		+ ' "furia_latente": -2, "atracao_do_eco": true, "renovacao": 1}}'
	)
	_write_save(text)
	var meta := MetaProgress.load_from(TEST_SAVE)
	_check(meta.load_note == "ajustado", "campos inválidos: ajustado (%s)" % meta.load_note)
	_check(meta.ecos == 0, "Ecos negativos viram 0")
	_check(meta.runs == 0 and meta.total_kills == 0, "partidas (texto) e abates (negativo) viram 0")
	_check(meta.victories == 2, "vitórias fracionadas são arredondadas para baixo")
	_check(_near(meta.best_time, 0.0), "melhor tempo inválido vira 0")
	_check(meta.level_of(MetaProgress.VIGOR) == 5, "nível acima do limite vira o limite (5)")
	_check(meta.level_of(MetaProgress.FURY) == 0, "nível negativo vira 0")
	_check(meta.level_of(MetaProgress.MAGNET) == 0, "nível que não é número vira 0")
	_check(meta.level_of(MetaProgress.RENEWAL) == 1, "o campo válido é mantido")
	_check(meta.load_issues.size() == 8, "8 problemas registrados (%d)" % meta.load_issues.size())
	_check(_read_file(TEST_SAVE + ".corrompido") == text, "cópia do original antes de ajustar")
	_check(_read_file(TEST_SAVE) == text, "o original fica intacto até salvar")
	_check(meta.save(), "salva os valores ajustados")
	var again := MetaProgress.load_from(TEST_SAVE)
	_check(again.load_note == "carregado" and again.load_issues.is_empty(), "salvo sem problemas")
	_check(again.level_of(MetaProgress.VIGOR) == 5, "o valor ajustado é o salvo")
	_delete_save()


func test_save_campos_ausentes_e_desconhecidos() -> void:
	_write_save('{"versao": 1}')
	var meta := MetaProgress.load_from(TEST_SAVE)
	var clean := meta.load_note == "carregado" and meta.load_issues.is_empty()
	_check(clean, "campos opcionais ausentes")
	_check(meta.ecos == 0 and meta.runs == 0, "ausente vale 0")
	_check(not FileAccess.file_exists(TEST_SAVE + ".corrompido"), "sem cópia para arquivo íntegro")
	_write_save('{"versao": 1, "ecos": 12, "campo_novo": {"a": 1}, "melhorias": {"outra": 3}}')
	meta = MetaProgress.load_from(TEST_SAVE)
	meta.save()
	var data: Dictionary = JSON.parse_string(_read_file(TEST_SAVE))
	var extra: bool = data.has("campo_novo") and data.campo_novo.a == 1
	_check(extra, "campo desconhecido mantido ao salvar")
	_check(int(data.melhorias.outra) == 3, "melhoria desconhecida mantida ao salvar")
	_check(int(data.ecos) == 12, "Ecos mantidos")
	_delete_save()


func test_save_futuro_invalido_nao_quebra_nem_sobrescreve() -> void:
	var text := '{"versao": 7, "ecos": "muitos", "estatisticas": [1], "melhorias": "nova"}'
	_write_save(text)
	var meta := MetaProgress.load_from(TEST_SAVE)
	_check(meta.read_only, "versão futura fica só leitura")
	_check(meta.ecos == 0, "valores que não entende viram 0 só na memória")
	meta.ecos = 999
	_check(not meta.save(), "não salva por cima de uma versão futura")
	_check(_read_file(TEST_SAVE) == text, "o arquivo futuro fica intacto")
	_check(not FileAccess.file_exists(TEST_SAVE + ".corrompido"), "versão futura não é corrompida")
	_delete_save()


func test_save_invalido_nao_impede_a_partida() -> void:
	_write_save('{"versao": 1, "ecos": 30, "estatisticas": "quebrado"}')
	await _new_game(false, true)
	_check(is_instance_valid(game) and game.player.alive, "a partida começa normalmente")
	_check(game.meta.load_note == "corrompido" and game.meta.ecos == 0, "com progressão segura")
	_check(_near(game.player.max_hp, 100.0), "sem bônus vindos de dados inválidos")
	await _frames(30)
	_check(game.elapsed() > 0.3, "o jogo roda")


# ---------------------------------------------------------------- joystick depois da pausa


## Segura o dedo no joystick e arrasta para a direita da tela.
func _hold_right(at: Vector2) -> void:
	_touch(true, at)
	await _frames(2)
	_drag(at + Vector2(60, 0))
	await _frames(2)
	_drag(at + Vector2(100, 0))
	await _frames(10)


func _moved_during(frames: int) -> Vector3:
	var start: Vector3 = game.player.global_position
	await _frames(frames)
	return game.player.global_position - start


func test_joystick_retoma_com_dedo_pressionado() -> void:
	await _new_game()
	var at := Vector2(360, 1000)
	await _hold_right(at)
	var right: Vector3 = game.camera_rig.ground_right()
	_check((await _moved_during(10)).dot(right) > 0.5, "o joystick move antes da pausa")
	_grant_level()
	await _frames(2)
	_check(paused and not game.joystick.enabled, "a pausa desliga o joystick")
	_check(game.joystick.output == Vector2.ZERO, "sem saída durante a pausa")
	_check((await _moved_during(20)).length() < 0.001, "sem movimento durante a pausa")
	await _choose(game.level_up_panel.choice_ids()[0])
	_check(not paused and game.joystick.enabled, "a partida retoma")
	_check(game.joystick.is_active(), "o dedo que continuou na tela segue no joystick")
	var after := await _moved_during(30)
	_check(after.length() > 1.5, "volta a andar sem tocar de novo (andou %.2f m)" % after.length())
	_check(after.normalized().dot(right) > 0.9, "na mesma direção de antes")
	_check(game.player.dodges_used == 0, "sem esquiva acidental")
	_touch(false, at + Vector2(100, 0))
	await _frames(2)
	var still := (await _moved_during(10)).length()
	_check(still < 0.001, "soltar para o personagem (sem entrada presa)")
	_check(game.player.dodges_used == 0, "soltar depois da pausa não conta como toque curto")


func test_joystick_solto_durante_a_pausa_volta_neutro() -> void:
	await _new_game()
	var at := Vector2(360, 1000)
	await _hold_right(at)
	_grant_level()
	await _frames(2)
	_touch(false, at + Vector2(100, 0))  # soltou durante a escolha
	await _frames(5)
	await _choose(game.level_up_panel.choice_ids()[0])
	_check(not game.joystick.is_active() and game.joystick.output == Vector2.ZERO, "volta neutro")
	_check((await _moved_during(30)).length() < 0.001, "sem movimento sozinho")
	# Um toque novo funciona normalmente.
	_touch(true, at)
	_drag(at + Vector2(0, -100))
	var up := await _moved_during(30)
	_touch(false, at + Vector2(0, -100))
	var forward: Vector3 = game.camera_rig.ground_forward()
	_check(up.normalized().dot(forward) > 0.9, "o toque novo move para cima")
	_check(game.player.dodges_used == 0, "sem esquiva acidental")


func test_joystick_segue_o_dedo_movido_na_pausa() -> void:
	await _new_game()
	var at := Vector2(360, 1000)
	await _hold_right(at)
	_grant_level()
	await _frames(2)
	_drag(at + Vector2(40, 0))  # o dedo desliza durante a escolha (sem efeito na pausa)
	_drag(at + Vector2(-100, 0))
	await _frames(3)
	_check(game.joystick.output == Vector2.ZERO, "arrastar na pausa não gera saída")
	await _choose(game.level_up_panel.choice_ids()[0])
	var left := await _moved_during(30)
	_touch(false, at + Vector2(-100, 0))
	_check(left.normalized().dot(-game.camera_rig.ground_right()) > 0.9, "retoma na posição atual")


func test_joystick_varios_level_ups_seguidos() -> void:
	await _new_game()
	var at := Vector2(360, 1000)
	await _hold_right(at)
	var right: Vector3 = game.camera_rig.ground_right()
	game.progression.add_xp(Progression.requirement(1) + Progression.requirement(2))
	await _frames(2)
	await _choose(game.level_up_panel.choice_ids()[0])
	_check(paused and game.level_up_panel.is_open(), "a segunda escolha abre em seguida")
	await _choose(game.level_up_panel.choice_ids()[0])
	_check(not paused, "depois das duas escolhas a partida segue")
	_check((await _moved_during(20)).dot(right) > 1.0, "continua andando depois de 2 escolhas")
	# Outra pausa mais tarde, com o mesmo dedo.
	_grant_level()
	await _frames(2)
	await _choose(game.level_up_panel.choice_ids()[0])
	_check((await _moved_during(20)).dot(right) > 1.0, "continua andando depois da 3ª pausa")
	_touch(false, at + Vector2(100, 0))
	await _frames(2)
	_check(game.player.dodges_used == 0 and game.joystick.dodge_gestures == 0, "sem esquiva")


func test_joystick_retomada_sem_esquiva_acidental() -> void:
	await _new_game()
	var at := Vector2(360, 1000)
	# Um toque curto logo antes da pausa e outro logo depois não formam um duplo toque.
	await _tap(at)
	_grant_level()
	await _frames(2)
	await _double_tap(at, 4)  # toques durante a escolha: ignorados
	await _choose(game.level_up_panel.choice_ids()[0])
	await _tap(at)
	await _frames(10)
	_check(game.player.dodges_used == 0, "a pausa interrompe o duplo toque")
	# O duplo toque continua funcionando depois.
	await _frames(30)
	await _double_tap(at, 5)
	await _frames(15)
	_check(game.player.dodges_used == 1, "o duplo toque normal funciona depois da pausa")


## A Atração do eco aumenta o ímã dos orbes, e o texto da loja diz isso (antes dizia
## "raio de coleta", que é outra distância: 0,6 m, e não muda).
func test_atracao_do_eco_texto_e_efeito_no_ima() -> void:
	var text: String = MetaProgress.definition(MetaProgress.MAGNET).description
	_check("ímã" in text, "o texto fala do ímã (%s)" % text)
	_check(not "coleta" in text, "o texto não fala em raio de coleta")
	_delete_save()
	var meta := MetaProgress.load_from(TEST_SAVE)
	meta.ecos = 1000
	_check(meta.buy(MetaProgress.MAGNET) and meta.buy(MetaProgress.MAGNET), "compra 2 níveis")
	_check(meta.save(), "deveria salvar")
	await _new_game(false, true)
	var radius: float = game.orbs.magnet_radius
	_check(_near(radius, 3.0 * 1.4), "Atração 2: ímã de 4,2 m (%.2f)" % radius)
