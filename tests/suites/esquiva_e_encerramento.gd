extends "res://tests/suites/base.gd"
## Esquiva (teclado e duplo toque), resultados, reinício e progressão permanente.

const TESTS := [
	"test_esquiva_pelo_teclado",
	"test_esquiva_invulnerabilidade_e_recarga",
	"test_duplo_toque_esquiva_na_direcao",
	"test_duplo_toque_intervalos",
	"test_duplo_toque_sem_ativacao_acidental",
	"test_derrota_e_estatisticas_reais",
	"test_reinicio_apos_vitoria_limpa_tudo",
	"test_progressao_permanente_salva",
	"test_progressao_migracao_e_protecao",
]


# ---------------------------------------------------------------- esquiva


func test_esquiva_pelo_teclado() -> void:
	await _new_game()
	var player: Player = game.player
	var start := player.global_position
	var facing := player.facing()
	_key(KEY_SPACE, true)
	await _frames(1)
	_key(KEY_SPACE, false)
	await _frames(20)
	_check(player.dodges_used == 1, "Espaço deveria esquivar")
	var moved := player.global_position - start
	_check(_near(moved.length(), 4.0, 0.3), "a esquiva anda 4 m (andou %.2f)" % moved.length())
	_check(moved.normalized().dot(facing) > 0.95, "parado, esquiva para a frente")
	_key(KEY_SPACE, true)
	await _frames(1)
	_key(KEY_SPACE, false)
	_check(player.dodges_used == 1, "durante a recarga não esquiva de novo")
	await _frames(90)
	# Segurando D: esquiva para a direita da tela.
	_key(KEY_D, true)
	await _frames(2)
	var before := player.global_position
	_key(KEY_SPACE, true)
	await _frames(1)
	_key(KEY_SPACE, false)
	await _frames(11)
	_key(KEY_D, false)
	var dir := (player.global_position - before).normalized()
	_check(player.dodges_used == 2, "depois da recarga esquiva de novo")
	_check(dir.dot(game.camera_rig.ground_right()) > 0.95, "com D, esquiva para a direita")


func test_esquiva_invulnerabilidade_e_recarga() -> void:
	await _new_game()
	var player: Player = game.player
	_check(player.request_dodge(Vector3.RIGHT), "a esquiva deveria começar")
	player.take_damage(50.0)
	_check(_near(player.hp, 100.0), "durante a esquiva não leva dano")
	_check(not player.request_dodge(Vector3.LEFT), "na recarga, nova esquiva é recusada")
	_check(player.dodge_charge() < 0.1, "indicador de recarga vazio")
	await _frames(22)
	player.take_damage(50.0)
	_check(_near(player.hp, 50.0), "depois da invulnerabilidade volta a levar dano")
	await _frames(70)
	_check(player.dodge_ready() and player.dodge_charge() >= 1.0, "recarga completa em 1,4 s")
	# Inimigos encostados não ferem durante a esquiva.
	_spawn_still(0.3, 1.0e6)
	_disable_bolt()
	player.request_dodge(Vector3.ZERO + game.camera_rig.ground_forward())
	var hp := player.hp
	await _frames(5)
	_check(_near(player.hp, hp), "contato não fere durante a esquiva")


func test_duplo_toque_esquiva_na_direcao() -> void:
	await _new_game()
	var player: Player = game.player
	var at := Vector2(360, 1000)
	await _double_tap(at, 5)
	await _frames(15)
	_check(player.dodges_used == 1, "duplo toque deveria esquivar")
	_check(game.joystick.dodge_gestures == 1, "um gesto reconhecido")
	await _frames(90)
	# Peteleco no segundo toque: esquiva para onde arrastou (direita da tela).
	var start := player.global_position
	await _tap(at)
	await _frames(4)
	_touch(true, at)
	await _frames(2)
	_drag(at + Vector2(60, 0))
	await _frames(2)
	_drag(at + Vector2(140, 0))
	await _frames(10)
	_touch(false, at + Vector2(140, 0))
	await _frames(2)
	_check(player.dodges_used == 2, "toque + peteleco deveria esquivar")
	_check(game.joystick.dodge_gestures == 2, "um gesto só, mesmo arrastando mais")
	var dir := (player.global_position - start).normalized()
	_check(dir.dot(game.camera_rig.ground_right()) > 0.9, "esquiva para a direita da tela")


func test_duplo_toque_intervalos() -> void:
	var at := Vector2(360, 1000)
	for gap in [2, 6, 12, 18, 25, 40]:
		await _new_game()
		await _double_tap(at, gap)
		await _frames(10)
		var expected := 1 if gap <= 18 else 0
		_check(
			game.player.dodges_used == expected,
			"intervalo de %d quadros: esperado %d esquiva(s)" % [gap, expected]
		)


func test_duplo_toque_sem_ativacao_acidental() -> void:
	await _new_game()
	var player: Player = game.player
	var at := Vector2(360, 1000)
	# Movimento normal: segurar, girar, soltar e tocar de novo para mudar de direção.
	_touch(true, at)
	for k in 40:
		_drag(at + Vector2.from_angle(float(k) * 0.2) * 80.0)
		await process_frame
	_touch(false, at)
	await _frames(4)
	_touch(true, at)
	_drag(at + Vector2(0, -80))
	await _frames(30)
	_touch(false, at + Vector2(0, -80))
	await _frames(2)
	_check(player.dodges_used == 0, "movimentar o joystick não esquiva")
	await _frames(40)
	# Toques longe um do outro.
	await _tap(at)
	await _frames(4)
	await _tap(at + Vector2(300, 0))
	await _frames(4)
	_check(player.dodges_used == 0, "toques distantes não contam como duplo toque")
	await _frames(40)
	# Primeiro toque longo (segurou): não é toque.
	await _tap(at, 20)
	await _frames(4)
	await _tap(at)
	await _frames(4)
	_check(player.dodges_used == 0, "um toque segurado não arma a esquiva")
	await _frames(40)
	# Segundo toque arrastando devagar: é movimento, não esquiva.
	await _tap(at)
	await _frames(4)
	_touch(true, at)
	await _frames(25)
	_drag(at + Vector2(80, 0))
	await _frames(5)
	_touch(false, at + Vector2(80, 0))
	await _frames(2)
	_check(player.dodges_used == 0, "arrastar devagar depois do toque não esquiva")
	await _frames(40)
	# Durante a escolha de melhoria, o joystick fica desligado.
	_grant_level()
	await _frames(2)
	await _double_tap(at, 5)
	await _frames(5)
	_check(player.dodges_used == 0 and game.joystick.dodge_gestures == 0, "sem esquiva no menu")


# ---------------------------------------------------------------- encerramento


func test_derrota_e_estatisticas_reais() -> void:
	await _new_game()
	for k in 3:
		var index: int = game.enemies.spawn_at(_enemy_point(4.0 + k), 15.0)
		game.enemies._speed[index] = 0.0
	await _frames(240)
	_check(game.kills() == 3, "os 3 inimigos deveriam cair (caíram %d)" % game.kills())
	game.player.take_damage(1.0e6, "teste")
	await _frames(1)
	_check(game.is_over() and not game.is_victory(), "derrota")
	_check(game.results.is_open(), "a tela de resultados aparece na derrota")
	var data: Dictionary = game.result_data()
	_check(data.kills == 3, "abates no resumo")
	var dealt: float = data.damage_dealt
	_check(_near(dealt, 45.0, 0.01), "dano causado = vida tirada (%.1f)" % dealt)
	_check(_near(data.damage_taken, 100.0, 0.01), "dano recebido = vida perdida")
	var bolt: Dictionary = data.weapons[0]
	_check(bolt.id == WeaponCatalog.BOLT and bolt.kills == 3, "abates do Raio arcano")
	_check(_near(bolt.damage, 45.0, 0.01), "dano do Raio arcano")
	var reward := MetaProgress.reward_for(game.elapsed(), 3, 0)
	_check(game.ecos_earned == reward, "Ecos ganhos pela fórmula (%d)" % game.ecos_earned)
	var saved := MetaProgress.load_from(TEST_SAVE)
	_check(saved.ecos == reward and saved.runs == 1, "o resultado foi salvo")


func test_reinicio_apos_vitoria_limpa_tudo() -> void:
	await _new_game()
	game.player.invulnerable = true
	game.apply_offer(WeaponCatalog.AURA)
	game.apply_offer(WeaponCatalog.BLADE)
	var none: Array[StringName] = []
	game.offers.banish(Upgrades.DAMAGE, none)
	game.offers.rerolls_left = 0
	for k in 10:
		game.enemies.spawn_at(_enemy_point(5.0 + k), 1000.0, k % 5)
	game.enemy_projectiles.fire(_enemy_point(5.0), Vector3.LEFT, 1.0, 1.0, 10.0, 0)
	game.start_encounter()
	await _frames(30)
	game.enemies.damage(game.enemies.boss_index(), 1.0e7, &"teste")
	await _frames(2)
	_check(game.is_victory(), "vitória antes do reinício")
	var earned: int = game.ecos_earned
	var old := game
	game.results.restart_requested.emit()
	await _frames(3)
	game = current_scene
	_check(game != old and is_instance_valid(game), "partida nova criada")
	_check(not is_instance_valid(old), "a partida anterior foi liberada")
	if game == old or not is_instance_valid(game):
		return
	_check(not paused, "a partida nova não começa pausada")
	_check(game.enemies.boss_index() == -1 and not game.boss.is_active(), "sem chefe")
	_check(game.enemies.count <= 2, "sem a horda anterior (%d inimigos)" % game.enemies.count)
	_check(game.enemy_projectiles.count == 0, "sem projéteis inimigos")
	_check(game.effects.count == 0, "sem efeitos no chão")
	_check(game.arsenal.owned_ids() == [WeaponCatalog.BOLT], "só a arma inicial")
	_check(game.aura.level == 0 and game.blades.level == 0, "aura e lâmina desligadas")
	var fresh: RunStats = game.stats
	_check(fresh.total_damage() == 0.0 and fresh.bosses_defeated == 0, "estatísticas zeradas")
	_check(game.offers.banished_ids().is_empty() and game.offers.rerolls_left == 2, "ofertas novas")
	_check(not game.is_over() and not game.results.is_open(), "partida em andamento")
	_check(not game.encounter_started() and game.elapsed() < 0.2, "relógio zerado")
	_check(game.meta.ecos == earned, "os Ecos ganhos continuam salvos")


# ---------------------------------------------------------------- progressão permanente


func test_progressao_permanente_salva() -> void:
	_delete_save()
	var meta := MetaProgress.load_from(TEST_SAVE)
	_check(meta.load_note == "novo" and meta.ecos == 0, "sem arquivo, começa do zero")
	meta.ecos = 100
	_check(meta.buy(MetaProgress.VIGOR), "compra com Ecos suficientes")
	_check(meta.ecos == 85 and meta.level_of(MetaProgress.VIGOR) == 1, "custo descontado")
	meta.ecos = 5
	_check(not meta.buy(MetaProgress.FURY), "sem Ecos suficientes, não compra")
	_check(meta.save(), "deveria salvar")
	var again := MetaProgress.load_from(TEST_SAVE)
	_check(again.load_note == "carregado" and again.ecos == 5, "os Ecos voltam ao carregar")
	_check(again.level_of(MetaProgress.VIGOR) == 1, "as melhorias voltam ao carregar")
	again.ecos = 10000
	while again.buy(MetaProgress.RENEWAL):
		pass
	_check(again.level_of(MetaProgress.RENEWAL) == 2, "Renovação no máximo (2)")
	_check(again.cost_of(MetaProgress.RENEWAL) == -1, "no máximo, sem preço")
	again.buy(MetaProgress.VIGOR)
	again.buy(MetaProgress.FURY)
	again.save()
	# Bônus aplicados na partida seguinte.
	await _new_game(false, true)
	_check(_near(game.player.max_hp, 116.0), "Vigor 2: vida máxima 116 (%.1f)" % game.player.max_hp)
	_check(_near(game.player.hp, 116.0), "começa com a vida cheia")
	_check(_near(game.weapon.damage_multiplier, 1.05), "Fúria 1: +5% de dano")
	_check(game.offers.rerolls_left == 4, "Renovação 2: 4 trocas")
	_check(_near(game.orbs.magnet_radius, 3.0), "sem Atração, ímã normal")
	# A loja da tela de resultados compra e salva.
	game.player.take_damage(1.0e6, "teste")
	await _frames(1)
	game.meta.ecos = 1000
	game.results.show_shop()
	await _frames(1)
	var button: Button = game.results.buy_button(MetaProgress.MAGNET)
	_check(button != null and not button.disabled, "botão de compra disponível")
	button.pressed.emit()
	_check(MetaProgress.load_from(TEST_SAVE).level_of(MetaProgress.MAGNET) == 1, "compra salva")


func test_progressao_migracao_e_protecao() -> void:
	_delete_save()
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string('{"ecos": 30, "melhorias": {"vigor_ancestral": 2}}')
	file.close()
	var old := MetaProgress.load_from(TEST_SAVE)
	_check(old.load_note == "migrado de 0", "formato sem versão é migrado (%s)" % old.load_note)
	_check(old.ecos == 30 and old.level_of(MetaProgress.VIGOR) == 2, "dados preservados")
	old.save()
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(TEST_SAVE))
	_check(int(data.versao) == MetaProgress.VERSION, "salvo na versão atual")
	# Versão mais nova: lê, mas não salva por cima.
	var future_text := '{"versao": 99, "ecos": 500, "campo_novo": true}'
	file = FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string(future_text)
	file.close()
	var future := MetaProgress.load_from(TEST_SAVE)
	_check(future.read_only and future.ecos == 500, "versão futura: só leitura")
	_check(not future.save() and not future.buy(MetaProgress.MAGNET), "não salva nem compra")
	_check(FileAccess.get_file_as_string(TEST_SAVE) == future_text, "o arquivo futuro fica intacto")
	# Corrompido: guarda cópia e começa do zero.
	file = FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	file.store_string("{isso não é json")
	file.close()
	var broken := MetaProgress.load_from(TEST_SAVE)
	_check(broken.load_note == "corrompido" and broken.ecos == 0, "corrompido: começa do zero")
	_check(FileAccess.file_exists(TEST_SAVE + ".corrompido"), "cópia do arquivo corrompido")
	_check(MetaProgress.reward_for(600.0, 300, 1) == 30 + 20 + 40, "fórmula da recompensa")
	_delete_save()
