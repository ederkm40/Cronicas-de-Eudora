extends "res://tests/suites/base.gd"
## Progressão da partida (0.2): orbes, XP, level-up, melhorias, pausa e reinício.

const TESTS := [
	"test_inimigo_derrotado_gera_orbe",
	"test_coleta_de_orbes_por_proximidade",
	"test_acumulo_de_experiencia",
	"test_subida_de_nivel",
	"test_varios_niveis_de_uma_vez",
	"test_tres_opcoes_distintas",
	"test_efeito_poder_arcano",
	"test_efeito_cadencia",
	"test_efeito_nucleo_vital",
	"test_efeito_passos_ligeiros",
	"test_efeito_projetil_adicional",
	"test_efeito_campo_de_ruptura",
	"test_acumulo_e_limites_das_melhorias",
	"test_pausa_e_retomada",
	"test_level_up_bloqueado_apos_derrota",
	"test_reinicio_sem_melhorias_anteriores",
]

# ---------------------------------------------------------------- experiência


func test_inimigo_derrotado_gera_orbe() -> void:
	await _new_game()
	var where := _enemy_point(9.0)
	var index: int = game.enemies.spawn_at(where, 5.0)
	_check(game.orbs.count == 0, "não deveria haver orbes no começo")
	game.enemies.damage(index, 999.0)
	_check(game.kills() == 1, "o abate deveria ser contado")
	_check(
		game.orbs.count == 1, "um inimigo derrotado deveria deixar 1 orbe (há %d)" % game.orbs.count
	)
	if game.orbs.count == 1:
		_check(game.orbs.value_of(0) == 1, "o orbe deveria valer 1 de XP")
		_check(
			game.orbs.position_of(0).distance_to(Vector3(where.x, 0, where.z)) < 0.01,
			"o orbe deveria nascer onde o inimigo morreu"
		)


func test_coleta_de_orbes_por_proximidade() -> void:
	await _new_game()
	var player: Player = game.player
	game.orbs.spawn(_enemy_point(2.0), 1)  # dentro do ímã (3 m)
	game.orbs.spawn(_enemy_point(10.0), 1)  # longe
	await _frames(60)
	_check(
		game.orbs.count == 1, "só o orbe próximo deveria ser coletado (restam %d)" % game.orbs.count
	)
	_check(game.orbs.total_collected == 1, "1 de XP deveria ter sido coletado")
	_check(game.progression.total_xp == 1, "a experiência coletada deveria chegar à progressão")
	# Andando até o orbe distante, ele também é coletado.
	player.scripted_input = Vector2(1, 0)  # direita da tela
	await _frames(150)
	player.scripted_input = Vector2.ZERO
	_check(game.orbs.count == 0, "andar até o orbe distante deveria coletá-lo")
	_check(
		game.progression.total_xp == 2,
		"a experiência total deveria ser 2 (é %d)" % game.progression.total_xp
	)


func test_acumulo_de_experiencia() -> void:
	var p := Progression.new()
	p.add_xp(2)
	_check(p.level == 1 and p.xp == 2, "2 de XP no nível 1")
	p.add_xp(1)
	_check(p.level == 1 and p.xp == 3 and p.total_xp == 3, "a experiência deveria acumular")
	var previous := 0
	for level in range(1, 31):
		var need := Progression.requirement(level)
		_check(need > previous, "a XP necessária deveria crescer a cada nível (nível %d)" % level)
		previous = need
	# A barra do HUD mostra o progresso até o próximo nível.
	await _new_game()
	game.progression.add_xp(3)
	await _frames(1)
	var need := Progression.requirement(1)
	_check(_near(game.hud.xp_bar_ratio(), 3.0 / need), "a barra de XP deveria mostrar 3/%d" % need)


func test_subida_de_nivel() -> void:
	var p := Progression.new()
	var levels: Array[int] = []
	p.leveled_up.connect(func(level: int) -> void: levels.append(level))
	p.add_xp(Progression.requirement(1))
	_check(p.level == 2 and p.xp == 0, "completar a XP deveria levar ao nível 2")
	_check(levels == [2], "o aviso de subida de nível deveria sair uma vez")
	_check(p.pending_level_ups == 1, "deveria haver 1 escolha pendente")

	await _new_game()
	_grant_level()
	await _frames(2)
	_check(game.level_up_panel.is_open(), "a tela de level-up deveria abrir")
	_check(paused, "a partida deveria pausar no level-up")


func test_varios_niveis_de_uma_vez() -> void:
	await _new_game()
	var p: Progression = game.progression
	p.add_xp(Progression.requirement(1) + Progression.requirement(2))
	_check(p.level == 3 and p.pending_level_ups == 2, "deveria subir 2 níveis de uma vez")
	await _frames(2)
	_check(game.level_up_panel.is_open(), "a primeira escolha deveria abrir")
	var first: StringName = game.level_up_panel.choice_ids()[0]
	await _choose(first)
	_check(game.level_up_panel.is_open() and paused, "a segunda escolha deveria abrir em seguida")
	await _choose(game.level_up_panel.choice_ids()[0])
	_check(
		not game.level_up_panel.is_open() and not paused,
		"depois das duas escolhas a partida deveria continuar"
	)
	_check(p.pending_level_ups == 0, "não deveria sobrar escolha pendente")
	# E dá para continuar subindo depois.
	_grant_level()
	await _frames(2)
	_check(
		game.level_up_panel.is_open(), "um novo nível na mesma partida deveria abrir outra escolha"
	)


func test_tres_opcoes_distintas() -> void:
	var upgrades := Upgrades.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var seen := {}
	for i in 300:
		var choices := upgrades.roll_choices(3, rng)
		_check(choices.size() == 3, "deveria sortear 3 opções")
		var unique := {}
		for id in choices:
			unique[id] = true
			seen[id] = true
			_check(Upgrades.all_ids().has(id), "opção desconhecida: %s" % id)
		_check(unique.size() == 3, "as 3 opções deveriam ser diferentes: %s" % [choices])
	_check(seen.size() == 6, "as 6 melhorias deveriam aparecer nos sorteios")
	# Na tela: três cartões com melhorias diferentes.
	await _new_game()
	_grant_level()
	await _frames(2)
	var ids: Array[StringName] = game.level_up_panel.choice_ids()
	_check(ids.size() == 3, "a tela deveria mostrar 3 cartões")
	_check(
		ids[0] != ids[1] and ids[1] != ids[2] and ids[0] != ids[2],
		"os cartões deveriam ser diferentes"
	)
	_check(game.level_up_panel._buttons.size() == 3, "deveria haver 3 botões tocáveis")


# ---------------------------------------------------------------- efeitos


## Atira um projétil num inimigo parado e devolve quanto de vida ele perdeu.
func _damage_of_one_shot() -> float:
	var index: int = game.enemies.spawn_at(_enemy_point(4.0), 1000.0)
	game.enemies.base_speed = 0.0
	game.enemies._speed[index] = 0.0
	var before: float = game.enemies.hp_of(index)
	var shots_before: int = game.weapon.shots_fired
	while game.weapon.shots_fired == shots_before:
		await process_frame
	game.weapon.fire_interval = 999.0  # não atira de novo durante a medição
	game.weapon._cooldown = 999.0
	await _frames(40)
	return before - game.enemies.hp_of(0)


func test_efeito_poder_arcano() -> void:
	await _new_game()
	var base := await _damage_of_one_shot()
	_check(_near(base, 10.0), "dano base deveria ser 10 (foi %.2f)" % base)
	await _new_game()
	game.upgrades.apply(Upgrades.DAMAGE, game.player, game.weapon)
	var boosted := await _damage_of_one_shot()
	_check(_near(boosted, 12.0), "com Poder arcano o dano deveria ser 12 (foi %.2f)" % boosted)


## Conta os projéteis disparados em `seconds` contra um inimigo indestrutível.
func _shots_in(seconds: float) -> int:
	var index: int = game.enemies.spawn_at(_enemy_point(6.0), 1.0e9)
	game.enemies._speed[index] = 0.0
	game.weapon.projectile_damage = 0.0
	await _frames(1)
	var start: int = game.weapon.shots_fired
	await _frames(int(seconds * 60.0))
	return game.weapon.shots_fired - start


func test_efeito_cadencia() -> void:
	await _new_game()
	var base := await _shots_in(9.0)
	await _new_game()
	game.upgrades.apply(Upgrades.FIRE_RATE, game.player, game.weapon)
	_check(
		_near(game.weapon.effective_fire_interval(), 0.45 / 1.15),
		"o intervalo entre disparos deveria cair 15%"
	)
	var boosted := await _shots_in(9.0)
	_check(boosted > base, "com Cadência deveria disparar mais (%d contra %d)" % [boosted, base])
	var ratio := float(boosted) / float(base)
	_check(
		ratio > 1.08 and ratio < 1.22,
		"o ganho deveria ficar perto de 15%% (foi %.0f%%)" % ((ratio - 1.0) * 100.0)
	)


func test_efeito_nucleo_vital() -> void:
	await _new_game()
	var player: Player = game.player
	player.take_damage(60.0)
	_check(_near(player.hp, 40.0), "vida depois do dano deveria ser 40")
	game.upgrades.apply(Upgrades.VITALITY, player, game.weapon)
	_check(_near(player.max_hp, 125.0), "vida máxima deveria ir a 125 (foi %.1f)" % player.max_hp)
	_check(_near(player.hp, 65.0), "deveria recuperar 25 de vida (vida %.1f)" % player.hp)
	# A cura não passa do máximo.
	player.hp = player.max_hp - 5.0
	game.upgrades.apply(Upgrades.VITALITY, player, game.weapon)
	_check(_near(player.max_hp, 150.0), "com 2 níveis a vida máxima deveria ser 150")
	_check(_near(player.hp, 145.0), "a cura deveria parar no máximo (vida %.1f)" % player.hp)


## Metros andados em 1 segundo com o movimento comandado.
func _distance_in_one_second() -> float:
	var player: Player = game.player
	var start := player.global_position
	player.scripted_input = Vector2(0, -1)
	await _frames(60)
	player.scripted_input = Vector2.ZERO
	return player.global_position.distance_to(start)


func test_efeito_passos_ligeiros() -> void:
	await _new_game()
	var base := await _distance_in_one_second()
	_check(_near(base, 5.0, 0.15), "velocidade base deveria ser 5 m/s (foi %.2f)" % base)
	await _new_game()
	game.upgrades.apply(Upgrades.SPEED, game.player, game.weapon)
	var boosted := await _distance_in_one_second()
	_check(
		_near(boosted, 5.75, 0.15), "com Passos ligeiros deveria ser 5,75 m/s (foi %.2f)" % boosted
	)


func test_efeito_projetil_adicional() -> void:
	await _new_game()
	game.upgrades.apply(Upgrades.PROJECTILE, game.player, game.weapon)
	var index: int = game.enemies.spawn_at(_enemy_point(8.0), 1.0e9)
	game.enemies._speed[index] = 0.0
	while game.weapon.shots_fired == 0:
		await process_frame
	_check(
		game.weapon.shots_fired == 2,
		"um disparo deveria soltar 2 projéteis (soltou %d)" % game.weapon.shots_fired
	)
	var a: Vector3 = game.weapon._velocities[0].normalized()
	var b: Vector3 = game.weapon._velocities[1].normalized()
	_check(rad_to_deg(a.angle_to(b)) > 5.0, "os projéteis deveriam sair em leque")


func test_efeito_campo_de_ruptura() -> void:
	# Inimigo a 12 m: fora do alcance base (11 m), dentro do alcance com a melhoria (13,2 m).
	await _new_game()
	var index: int = game.enemies.spawn_at(_enemy_point(12.0), 1000.0)
	game.enemies._speed[index] = 0.0
	await _frames(60)
	_check(game.weapon.shots_fired == 0, "sem melhoria não deveria atirar a 12 m")
	game.upgrades.apply(Upgrades.RANGE, game.player, game.weapon)
	_check(_near(game.weapon.effective_range(), 13.2), "alcance deveria ir a 13,2 m")
	await _frames(60)
	_check(game.weapon.shots_fired > 0, "com Campo de ruptura deveria atirar a 12 m")
	await _frames(60)
	_check(game.enemies.hp_of(0) < 1000.0, "o projétil deveria chegar ao inimigo a 12 m")


func test_acumulo_e_limites_das_melhorias() -> void:
	await _new_game()
	var up: Upgrades = game.upgrades
	for i in 3:
		up.apply(Upgrades.DAMAGE, game.player, game.weapon)
	_check(_near(game.weapon.damage_multiplier, 1.6), "3x Poder arcano = +60% de dano")
	for i in 2:
		up.apply(Upgrades.FIRE_RATE, game.player, game.weapon)
	_check(_near(game.weapon.fire_rate_multiplier, 1.3), "2x Cadência = +30% de disparo")
	for i in 4:
		_check(
			up.apply(Upgrades.PROJECTILE, game.player, game.weapon),
			"Projétil adicional deveria aceitar 4 níveis"
		)
	_check(game.weapon.projectiles_per_shot() == 5, "4x Projétil adicional = 5 por disparo")
	_check(
		not up.apply(Upgrades.PROJECTILE, game.player, game.weapon),
		"o 5º nível de Projétil adicional deveria ser recusado"
	)
	_check(game.weapon.projectiles_per_shot() == 5, "o limite não deveria passar de 5 projéteis")
	_check(
		not up.available_ids().has(Upgrades.PROJECTILE),
		"melhoria no limite não deveria ser sorteada"
	)
	for i in 10:
		up.apply(Upgrades.SPEED, game.player, game.weapon)
	_check(_near(game.player.speed_multiplier, 1.75), "Passos ligeiros deveria parar em +75%")
	# Com só 2 melhorias disponíveis, o sorteio mostra as 2, sem repetir.
	for id in [Upgrades.DAMAGE, Upgrades.FIRE_RATE, Upgrades.VITALITY, Upgrades.RANGE]:
		while up.apply(id, game.player, game.weapon):
			pass
	_check(up.available_ids().is_empty(), "todas no limite")
	_check(up.roll_choices(3).is_empty(), "sem melhorias disponíveis, nada a sortear")


# ---------------------------------------------------------------- pausa, derrota e reinício


func _snapshot() -> Dictionary:
	var enemy_sum := Vector3.ZERO
	for i in game.enemies.count:
		enemy_sum += game.enemies.position_of(i)
	var shot_sum := Vector3.ZERO
	for p in game.weapon._positions:
		shot_sum += p
	var orb_sum := Vector3.ZERO
	for i in game.orbs.count:
		orb_sum += game.orbs.position_of(i)
	return {
		"inimigos": game.enemies.count,
		"posição dos inimigos": enemy_sum,
		"projéteis": game.weapon.active_projectiles(),
		"posição dos projéteis": shot_sum,
		"orbes": game.orbs.count,
		"posição dos orbes": orb_sum,
		"tempo da partida": game.elapsed(),
		"tempo das hordas": game.enemies.elapsed,
		"temporizador de hordas": game.enemies._spawn_timer,
		"recarga da arma": game.weapon._cooldown,
		"jogador": game.player.global_position,
		"vida": game.player.hp,
	}


func test_pausa_e_retomada() -> void:
	await _new_game(true)  # com hordas de verdade
	game.player.invulnerable = true
	await _frames(600)  # 10 s de partida
	game.orbs.spawn(_enemy_point(6.0), 1)  # um orbe se movendo em direção ao jogador durante a pausa
	_check(game.enemies.count > 0, "deveria haver inimigos antes da pausa")
	_grant_level()
	await _frames(1)
	_check(paused and game.level_up_panel.is_open(), "deveria pausar ao subir de nível")
	var before := _snapshot()
	# Durante a pausa, tocar e arrastar não pode mover o jogador.
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(360, 1100)
	Input.parse_input_event(touch)
	var drag := InputEventScreenDrag.new()
	drag.position = Vector2(460, 1100)
	Input.parse_input_event(drag)
	await _frames(180)
	touch.pressed = false
	Input.parse_input_event(touch)
	var after := _snapshot()
	for key in before:
		_check(
			before[key] == after[key],
			"%s mudou durante a pausa (%s -> %s)" % [key, before[key], after[key]]
		)
	# Toque logo na abertura é ignorado (trava curta contra toque acidental).
	game.level_up_panel._unlock_timer = 0.3
	game.level_up_panel.choose(0)
	_check(game.level_up_panel.is_open(), "a escolha deveria ficar travada nos primeiros instantes")
	await _choose(game.level_up_panel.choice_ids()[0])
	_check(
		not paused and not game.level_up_panel.is_open(),
		"a partida deveria continuar depois da escolha"
	)
	await _frames(60)
	var resumed := _snapshot()
	_check(
		resumed["tempo da partida"] > after["tempo da partida"], "o tempo deveria voltar a correr"
	)
	_check(
		resumed["posição dos inimigos"] != after["posição dos inimigos"],
		"os inimigos deveriam voltar a andar"
	)
	_check(game.joystick.enabled, "o joystick deveria voltar a funcionar")


func test_level_up_bloqueado_apos_derrota() -> void:
	await _new_game()
	game.player.take_damage(1000.0)
	_check(game.is_over(), "a partida deveria terminar")
	_grant_level()
	await _frames(5)
	_check(
		not game.level_up_panel.is_open(), "a tela de level-up não deveria abrir depois da derrota"
	)
	_check(not paused, "a partida não deveria pausar depois da derrota")
	_check(game.results.is_open(), "a tela de resultados deveria continuar visível")


func test_reinicio_sem_melhorias_anteriores() -> void:
	await _new_game()
	for id in Upgrades.all_ids():
		game.upgrades.apply(id, game.player, game.weapon)
	game.progression.add_xp(100)
	await _frames(2)
	await _choose(game.level_up_panel.choice_ids()[0])
	game.player.invulnerable = false
	game.level_up_panel.close()
	paused = false
	game.player.take_damage(1.0e6)
	var old := game
	game.results.restart_requested.emit()  # mesmo caminho do botão "Jogar de novo"
	await _frames(3)
	game = current_scene
	_check(game != old and is_instance_valid(game), "o reinício deveria criar uma partida nova")
	if game == old or not is_instance_valid(game):
		return
	_check(not paused, "a partida nova não deveria começar pausada")
	_check(
		game.progression.level == 1 and game.progression.total_xp == 0,
		"nível e XP deveriam voltar ao início"
	)
	_check(game.kills() == 0 and game.orbs.count == 0, "abates e orbes deveriam zerar")
	for id in Upgrades.all_ids():
		_check(game.upgrades.stacks(id) == 0, "%s não deveria passar para a partida nova" % id)
	_check(
		_near(game.weapon.damage_multiplier, 1.0) and _near(game.weapon.fire_rate_multiplier, 1.0),
		"arma sem melhorias"
	)
	_check(
		_near(game.weapon.range_multiplier, 1.0) and game.weapon.projectiles_per_shot() == 1,
		"alcance e projéteis no padrão"
	)
	_check(_near(game.player.max_hp, 100.0) and _near(game.player.hp, 100.0), "vida no padrão")
	_check(_near(game.player.speed_multiplier, 1.0), "velocidade no padrão")
	_check(game.player.alive and not game.is_over(), "o jogador deveria estar vivo")
