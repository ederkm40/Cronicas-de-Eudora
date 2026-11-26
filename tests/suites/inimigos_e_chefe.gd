extends "res://tests/suites/base.gd"
## Os quatro tipos de inimigos, a mistura por tempo e o chefe do encontro final.

const NEW_KINDS := [
	EnemyTypes.RAPIDO,
	EnemyTypes.RESISTENTE,
	EnemyTypes.ATIRADOR,
	EnemyTypes.EXPLOSIVO,
]
const TESTS := [
	"test_mistura_de_inimigos_por_tempo",
	"test_velocidade_e_resistencia_dos_tipos",
	"test_lancador_distancia_aviso_e_disparo",
	"test_volatil_aviso_explosao_e_abate",
	"test_chefe_surge_aos_dez_minutos",
	"test_chefe_ataques_com_aviso",
	"test_chefe_fase_dois_e_vitoria",
]

# ---------------------------------------------------------------- inimigos


func test_mistura_de_inimigos_por_tempo() -> void:
	var w0 := EnemyTypes.spawn_weights(0.0)
	for kind in range(1, EnemyTypes.COUNT):
		_check(w0[kind] == 0.0, "no começo só aparece o comum (tipo %d)" % kind)
	var w60 := EnemyTypes.spawn_weights(60.0)
	_check(w60[EnemyTypes.RAPIDO] > 0.0, "o Espreitador aparece depois de 45 s")
	_check(w60[EnemyTypes.RESISTENTE] == 0.0 and w60[EnemyTypes.EXPLOSIVO] == 0.0, "ainda não")
	var w400 := EnemyTypes.spawn_weights(400.0)
	for kind in NEW_KINDS:
		_check(w400[kind] > 0.0, "aos 400 s o tipo %d aparece" % kind)
	_check(w400[EnemyTypes.CHEFE] == 0.0, "o chefe nunca é sorteado")
	# Na partida, com hordas de verdade.
	await _new_game(true)
	game.player.invulnerable = true
	game.enemies.elapsed = 400.0
	await _frames(300)
	for kind in NEW_KINDS:
		_check(game.enemies.count_of_kind(kind) > 0, "tipo %d deveria nascer aos 400 s" % kind)
	_check(game.enemies.count_of_kind(EnemyTypes.CHEFE) == 0, "o chefe não nasce nas hordas")


func test_velocidade_e_resistencia_dos_tipos() -> void:
	await _new_game()
	_disable_bolt()
	game.player.invulnerable = true
	game.enemies.separation_strength = 0.0
	var right: Vector3 = game.camera_rig.ground_right()
	var forward: Vector3 = game.camera_rig.ground_forward()
	var kinds := [EnemyTypes.COMUM, EnemyTypes.RAPIDO, EnemyTypes.RESISTENTE, EnemyTypes.EXPLOSIVO]
	var dirs := [right, -right, forward, -forward]
	var ids := []
	for k in kinds.size():
		var where: Vector3 = game.player.global_position + dirs[k] * 9.0
		var index: int = game.enemies.spawn_at(where, 1.0e6, kinds[k])
		ids.append(game.enemies.id_of(index))
	await _frames(60)
	var moved := {}
	for k in kinds.size():
		var p: Vector3 = game.enemies.position_of(_index_of_id(ids[k]))
		moved[kinds[k]] = 9.0 - p.distance_to(game.player.global_position)
	_check(moved[EnemyTypes.RAPIDO] > moved[EnemyTypes.COMUM] * 1.6, "Espreitador bem mais rápido")
	_check(moved[EnemyTypes.RESISTENTE] < moved[EnemyTypes.COMUM] * 0.75, "Couraçado mais lento")
	_check(moved[EnemyTypes.EXPLOSIVO] > moved[EnemyTypes.COMUM], "Volátil um pouco mais rápido")
	# Resistência: o Couraçado ignora 35% do dano e tem 5x a vida do comum.
	var tank: int = game.enemies.spawn_at(_enemy_point(5.0), -1.0, EnemyTypes.RESISTENTE)
	_check(_near(game.enemies.hp_of(tank), 100.0), "Couraçado com 5x a vida base")
	game.enemies.damage(tank, 100.0, &"teste")
	_check(_near(game.enemies.hp_of(tank), 35.0), "Couraçado recebe 65% do dano")
	var weak: int = game.enemies.spawn_at(_enemy_point(5.0), -1.0, EnemyTypes.RAPIDO)
	_check(_near(game.enemies.hp_of(weak), 9.0), "Espreitador com 45% da vida base")


func test_lancador_distancia_aviso_e_disparo() -> void:
	await _new_game()
	_disable_bolt()
	var index: int = game.enemies.spawn_at(_enemy_point(3.0), 1.0e6, EnemyTypes.ATIRADOR)
	var id: int = game.enemies.id_of(index)
	await _frames(90)
	var p: Vector3 = game.enemies.position_of(_index_of_id(id))
	var dist := p.distance_to(game.player.global_position)
	_check(dist >= 4.5, "perto demais, o Lançador recua (está a %.1f m)" % dist)
	# Aviso antes do disparo: para e brilha; só depois sai o projétil.
	var saw_windup := false
	var fired_after_windup := false
	for f in 400:
		await process_frame
		var i := _index_of_id(id)
		if game.enemies.state_of(i) == EnemyManager.ACTIVE:
			saw_windup = true
		if game.enemy_projectiles.count > 0:
			fired_after_windup = saw_windup
			break
	_check(saw_windup and fired_after_windup, "o disparo deveria vir depois do aviso")
	var hp_before: float = game.player.hp
	for f in 180:
		await process_frame
		if game.player.hp < hp_before:
			break
	var taken: float = game.stats.damage_taken_by_source.get("Lançador", 0.0)
	var shot: float = game.enemies.shooter_projectile_damage
	_check(taken >= shot, "o projétil do Lançador deveria acertar o jogador parado (%.1f)" % taken)
	# Fora da tela ele se aproxima e não atira.
	await _new_game()
	_disable_bolt()
	var far: int = game.enemies.spawn_at(_enemy_point(11.0), 1.0e6, EnemyTypes.ATIRADOR)
	var far_id: int = game.enemies.id_of(far)
	var half: Vector2 = game.camera_rig.visible_ground_half_extent()
	var shots_offscreen := 0
	for f in 240:
		await process_frame
		var pos: Vector3 = game.enemies.position_of(_index_of_id(far_id))
		if not game.enemies.is_on_screen(pos, half, 0.0):
			shots_offscreen += game.enemy_projectiles.count
	var final_pos: Vector3 = game.enemies.position_of(_index_of_id(far_id))
	_check(game.enemies.is_on_screen(final_pos, half, 0.0), "o Lançador entra na tela")
	_check(shots_offscreen == 0, "o Lançador não atira de fora da tela")


func test_volatil_aviso_explosao_e_abate() -> void:
	await _new_game()
	_disable_bolt()
	var index := _spawn_still(1.5, 1000.0, EnemyTypes.EXPLOSIVO)
	await _frames(2)
	_check(game.enemies.state_of(index) == EnemyManager.ACTIVE, "o pavio deveria acender perto")
	_check(game.effects.count >= 1, "deveria haver um aviso no chão")
	var hp_before: float = game.player.hp
	await _frames(56)
	_check(game.enemies.count == 0, "o Volátil explode e some")
	var blast: float = hp_before - game.player.hp
	_check(_near(blast, 26.0), "a explosão tira 26 (tirou %.1f)" % blast)
	_check(game.orbs.count == 0 and game.kills() == 0, "explodir não conta abate nem deixa orbe")
	_check(game.stats.explosions == 1, "explosão contada")
	# Eliminado antes de explodir: sem explosão, com orbe, e o aviso some.
	await _new_game()
	_disable_bolt()
	var second := _spawn_still(1.5, 10.0, EnemyTypes.EXPLOSIVO)
	await _frames(2)
	var fx: int = game.enemies._fx[second]
	_check(game.effects.is_active(fx), "aviso ativo")
	game.enemies.damage(second, 999.0, &"teste")
	_check(not game.effects.is_active(fx), "o aviso some com o Volátil")
	_check(game.orbs.count == 1, "eliminado, deixa orbe")
	var hp_mid: float = game.player.hp
	await _frames(90)
	_check(_near(game.player.hp, hp_mid), "eliminado antes, não explode")
	# Fugindo do raio durante o aviso, não leva dano.
	await _new_game()
	_disable_bolt()
	_spawn_still(1.5, 1000.0, EnemyTypes.EXPLOSIVO)
	await _frames(2)
	game.player.scripted_input = Vector2(-1, 0)  # para a esquerda, longe do Volátil
	var hp_run: float = game.player.hp
	await _frames(60)
	game.player.scripted_input = Vector2.ZERO
	_check(_near(game.player.hp, hp_run), "saindo do raio, a explosão não acerta")


# ---------------------------------------------------------------- chefe


func test_chefe_surge_aos_dez_minutos() -> void:
	await _new_game()
	game.player.invulnerable = true
	_disable_bolt()
	game._elapsed = 595.0
	await _frames(60)
	_check(not game.encounter_started(), "antes dos 10 minutos não há chefe")
	_check(game.hud.banner_text().contains("encontro final"), "aviso de que o encontro vai começar")
	await _frames(300)
	_check(game.encounter_started(), "aos 10 minutos o encontro começa")
	_check(game.enemies.boss_index() != -1, "o chefe deveria existir")
	_check(_near(game.stats.boss_spawned_at, 600.0, 0.05), "surgiu aos 600 s")
	_check(game.hud.boss_bar_visible(), "a barra de vida do chefe aparece")
	_check(_near(game.hud.boss_bar_ratio(), 1.0), "a barra começa cheia")
	await _frames(300)
	_check(not game.is_over(), "com o chefe vivo, a partida não termina sozinha")
	var rate: float = game.encounter_spawn_rate
	_check(rate < 1.0 and _near(game.enemies.spawn_rate_multiplier, rate), "hordas mais lentas")
	_check(game.enemies.excluded_kinds == [EnemyTypes.ATIRADOR], "sem Lançadores novos no encontro")


func test_chefe_ataques_com_aviso() -> void:
	await _new_game()
	_disable_bolt()
	game.player.invulnerable = true
	game.start_encounter()
	var warned_before := {}
	for f in 60 * 20:
		await process_frame
		var state: int = game.boss.state
		var preparing := (
			state == BossController.State.PREPARAR_INVESTIDA
			or state == BossController.State.PREPARAR_ERUPCAO
		)
		if preparing and game.effects.count > 0:
			warned_before[state] = true
	var counts: Dictionary = game.boss.attack_counts
	_check(counts.get("investida", 0) >= 1, "o chefe deveria investir (%s)" % [counts])
	_check(counts.get("erupção", 0) >= 1, "o chefe deveria usar a erupção (%s)" % [counts])
	_check(counts.get("rajada", 0) >= 1, "o chefe deveria usar a rajada (%s)" % [counts])
	_check(warned_before.has(BossController.State.PREPARAR_INVESTIDA), "aviso antes da investida")
	_check(warned_before.has(BossController.State.PREPARAR_ERUPCAO), "aviso antes da erupção")
	# A erupção acerta quem fica parado no lugar marcado.
	game.player.invulnerable = false
	game.player.hp = game.player.max_hp
	game.boss._enter(BossController.State.PREPARAR_ERUPCAO)
	await _frames(int(game.boss.eruption_windup * 60.0) + 4)
	var taken: float = game.stats.boss_damage_taken
	_check(taken >= 30.0, "parado na erupção, leva o dano do chefe (%.1f)" % taken)


func test_chefe_fase_dois_e_vitoria() -> void:
	await _new_game()
	game.player.invulnerable = true
	game.start_encounter()
	await _frames(2)
	_check(not game.is_over(), "o encontro começa sem terminar a partida")
	var full: float = game.boss.max_hp
	game.enemies.damage(game.enemies.boss_index(), full * 0.6, &"teste")
	await _frames(2)
	_check(game.boss.phase == 2, "abaixo de 50% o chefe entra na fase 2")
	_check(game.enemies.count >= 7, "a fase 2 traz reforços (%d inimigos)" % game.enemies.count)
	_check(_near(game.hud.boss_bar_ratio(), 0.4, 0.01), "a barra acompanha o dano")
	_check(not game.is_over(), "com o chefe vivo não há vitória")
	game.enemies.damage(game.enemies.boss_index(), 1.0e6, &"teste")
	await _frames(2)
	_check(game.is_over() and game.is_victory(), "derrotar o chefe vence a partida")
	_check(game.results.is_open() and paused, "tela de vitória com o jogo congelado")
	_check(not game.hud.boss_bar_visible() and not game.boss.is_active(), "chefe encerrado")
	_check(game.stats.bosses_defeated == 1, "chefe derrotado contado")
	_check(game.ecos_earned >= 40, "a vitória dá pelo menos 40 Ecos (%d)" % game.ecos_earned)
	var data: Dictionary = game.result_data()
	_check(data.won and data.bosses == 1 and data.boss_seconds >= 0.0, "resumo da vitória")
