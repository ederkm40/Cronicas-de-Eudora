extends SceneTree
## Testes específicos do jogo: progressão (0.2), armas, ofertas, inimigos, chefe, esquiva,
## encerramento e progressão permanente (0.3).
## Uso: godot --headless --path . --fixed-fps 60 --script res://tests/run_tests.gd
## Cada teste abre uma partida nova, sem hordas automáticas, e controla os inimigos um a um.
## Sai com código 0 se todos passarem e 1 se algum falhar.

const MAIN_SCENE := "res://scenes/main.tscn"
const TEST_SAVE := "user://teste_progresso.json"
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
	"test_arsenal_espacos_independentes",
	"test_aura_pulso_alcance_e_dano",
	"test_aura_contra_horda",
	"test_lamina_orbital",
	"test_niveis_e_limites_das_armas",
	"test_ofertas_validas_e_distintas",
	"test_ofertas_preservam_a_progressao",
	"test_troca_de_opcoes",
	"test_bloqueio_de_opcoes",
	"test_mistura_de_inimigos_por_tempo",
	"test_velocidade_e_resistencia_dos_tipos",
	"test_lancador_distancia_aviso_e_disparo",
	"test_volatil_aviso_explosao_e_abate",
	"test_chefe_surge_aos_dez_minutos",
	"test_chefe_ataques_com_aviso",
	"test_chefe_fase_dois_e_vitoria",
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

var game: Node
var _failures: Array[String] = []
var _current := ""
var _checks := 0


func _initialize() -> void:
	# Progressão permanente num arquivo só dos testes, apagado antes de cada partida.
	MetaProgress.path = TEST_SAVE
	_run_all.call_deferred()


func _run_all() -> void:
	seed(20261126)
	var failed_tests := 0
	for test_name in TESTS:
		_current = test_name
		var before := _failures.size()
		await Callable(self, test_name).call()
		await _close_game()
		if _failures.size() == before:
			print("  ok    ", test_name)
		else:
			failed_tests += 1
			print("  FALHOU ", test_name)
	print("")
	print("%d testes, %d verificações, %d falhas" % [TESTS.size(), _checks, failed_tests])
	if _failures.is_empty():
		print("TESTES: OK")
		quit(0)
	else:
		for failure in _failures:
			printerr("FALHOU: " + failure)
		quit(1)


# ---------------------------------------------------------------- ajudantes


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append("%s: %s" % [_current, message])


func _near(a: float, b: float, tolerance: float = 0.001) -> bool:
	return absf(a - b) <= tolerance


## Abre uma partida nova, com o nascimento automático de hordas desligado.
func _new_game(spawning: bool = false, keep_save: bool = false) -> void:
	await _close_game()
	paused = false
	if not keep_save:
		_delete_save()
	game = (load(MAIN_SCENE) as PackedScene).instantiate()
	root.add_child(game)
	current_scene = game
	game.enemies.spawning_enabled = spawning
	await process_frame


func _close_game() -> void:
	paused = false
	if is_instance_valid(game):
		game.queue_free()
		game = null
	if is_instance_valid(current_scene):
		current_scene.queue_free()
	await process_frame


func _frames(amount: int) -> void:
	for i in amount:
		await process_frame


## Coloca a experiência suficiente para subir um nível, como se viesse dos orbes.
func _grant_level() -> void:
	game.progression.add_xp(game.progression.xp_to_next() - game.progression.xp)


## Espera a tela de level-up destravar e escolhe a melhoria pelo mesmo caminho do toque.
func _choose(id: StringName) -> void:
	var panel: LevelUpPanel = game.level_up_panel
	while panel.is_locked():
		await process_frame
	var index := panel.choice_ids().find(id)
	if index == -1:
		# A melhoria não foi sorteada: aplica direto para testar o efeito.
		game.upgrades.apply(id, game.player, game.weapon)
		panel.choose(0)
	else:
		panel.choose(index)
	await process_frame


func _enemy_point(distance: float) -> Vector3:
	return game.player.global_position + game.camera_rig.ground_right() * distance


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


# ---------------------------------------------------------------- ajudantes 0.3


func _delete_save() -> void:
	for suffix in ["", ".tmp", ".corrompido"]:
		if FileAccess.file_exists(TEST_SAVE + suffix):
			DirAccess.remove_absolute(TEST_SAVE + suffix)


## Desliga o Raio arcano (alcance zero) para medir só a arma em teste.
func _disable_bolt() -> void:
	game.weapon.attack_range = 0.0


## Inimigo parado a `distance` metros à direita da tela.
func _spawn_still(distance: float, hp: float, kind: int = EnemyTypes.COMUM) -> int:
	var index: int = game.enemies.spawn_at(_enemy_point(distance), hp, kind)
	game.enemies._speed[index] = 0.0
	return index


func _clear_enemies() -> void:
	while game.enemies.count > 0:
		game.enemies._remove(game.enemies.count - 1)


func _index_of_id(id: int) -> int:
	for i in game.enemies.count:
		if game.enemies.id_of(i) == id:
			return i
	return -1


func _touch(pressed: bool, position: Vector2) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.pressed = pressed
	event.position = position
	Input.parse_input_event(event)


func _drag(position: Vector2) -> void:
	var event := InputEventScreenDrag.new()
	event.index = 0
	event.position = position
	Input.parse_input_event(event)


func _key(key: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.keycode = key
	event.pressed = pressed
	Input.parse_input_event(event)


## Toque curto: encosta, espera `hold` quadros e solta.
func _tap(position: Vector2, hold: int = 3) -> void:
	_touch(true, position)
	await _frames(hold)
	_touch(false, position)
	await _frames(1)


## Dois toques curtos com `gap` quadros entre soltar o primeiro e tocar o segundo.
func _double_tap(position: Vector2, gap: int) -> void:
	await _tap(position)
	await _frames(maxi(gap - 1, 0))
	await _tap(position)


# ---------------------------------------------------------------- armas


func test_arsenal_espacos_independentes() -> void:
	var a := Arsenal.new()
	_check(a.owned_ids() == [WeaponCatalog.BOLT], "o jogador começa só com o Raio arcano")
	_check(a.acquire(WeaponCatalog.AURA), "deveria adquirir a aura")
	_check(a.level(WeaponCatalog.AURA) == 1 and a.level(WeaponCatalog.BOLT) == 1, "níveis próprios")
	_check(a.level_up(WeaponCatalog.AURA), "a aura deveria evoluir")
	_check(a.level(WeaponCatalog.BLADE) == 0, "evoluir a aura não mexe na lâmina")
	_check(a.acquire(WeaponCatalog.BLADE), "deveria adquirir a lâmina")
	_check(
		a.level(WeaponCatalog.AURA) == 2 and a.level(WeaponCatalog.BLADE) == 1,
		"adquirir a lâmina não muda o nível da aura"
	)
	_check(a.owned_ids().size() == 3, "três armas em três espaços")
	_check(not a.acquire(WeaponCatalog.AURA), "uma arma não é adquirida duas vezes")
	for i in 10:
		a.level_up(WeaponCatalog.AURA)
	_check(a.level(WeaponCatalog.AURA) == 5, "a aura para no nível 5")
	_check(not a.can_offer(WeaponCatalog.AURA), "arma no nível máximo não pode ser oferecida")
	var small := Arsenal.new()
	small.max_slots = 2
	small.acquire(WeaponCatalog.AURA)
	_check(not small.acquire(WeaponCatalog.BLADE), "sem espaço livre, nada de arma nova")
	_check(not small.can_offer(WeaponCatalog.BLADE), "sem espaço, a arma não é oferecida")
	_check(_near(WeaponCatalog.stats(WeaponCatalog.AURA, 5).damage, 16.0), "dano da aura no nível 5")
	_check(WeaponCatalog.stats(WeaponCatalog.AURA, 6).is_empty(), "não existe nível 6")
	# Na partida: a arma nova soma, não substitui a inicial.
	await _new_game()
	_spawn_still(6.0, 1.0e9)
	game.apply_offer(WeaponCatalog.AURA)
	await _frames(60)
	_check(game.weapon.shots_fired > 0, "o Raio arcano continua disparando com a aura")
	_check(game.aura.level == 1 and game.aura.visible, "a aura deveria estar ativa")


func test_aura_pulso_alcance_e_dano() -> void:
	await _new_game()
	_disable_bolt()
	_check(game.aura.level == 0 and not game.aura.visible, "sem aura no começo da partida")
	var inside := _spawn_still(1.8, 1000.0)
	var outside := _spawn_still(4.0, 1000.0)
	game.apply_offer(WeaponCatalog.AURA)
	await _frames(180)  # 3 s
	var pulses: int = game.aura.pulses
	_check(pulses >= 4 and pulses <= 6, "~5 pulsos em 3 s com intervalo 0,6 s (foram %d)" % pulses)
	var lost: float = 1000.0 - game.enemies.hp_of(inside)
	_check(_near(lost, pulses * 6.0), "cada pulso tira 6 (perdeu %.1f em %d)" % [lost, pulses])
	_check(_near(game.enemies.hp_of(outside), 1000.0), "fora do alcance não leva dano")
	_check(_near(game.stats.damage_of(WeaponCatalog.AURA), lost), "dano contado para a aura")
	game.upgrades.apply(Upgrades.DAMAGE, game.player, game.weapon)
	_check(_near(game.aura.effective_damage(), 7.2), "Poder arcano vale para a aura")
	game.upgrades.apply(Upgrades.RANGE, game.player, game.weapon)
	_check(_near(game.aura.effective_radius(), 2.2 * 1.1), "Campo de ruptura amplia a aura em 10%")
	game.upgrades.apply(Upgrades.FIRE_RATE, game.player, game.weapon)
	_check(_near(game.aura.effective_interval(), 0.6 / 1.15), "Cadência acelera os pulsos")


func test_aura_contra_horda() -> void:
	await _new_game()
	_disable_bolt()
	game.player.invulnerable = true
	game.enemies.separation_strength = 0.0
	var center: Vector3 = game.player.global_position
	for k in 80:
		var angle := TAU * float(k) / 80.0
		var r := 0.6 + 1.4 * float(k % 5) / 4.0
		var i: int = game.enemies.spawn_at(center + Vector3(cos(angle), 0, sin(angle)) * r, 5.0)
		game.enemies._speed[i] = 0.0
	game.apply_offer(WeaponCatalog.AURA)
	await _frames(30)  # primeiro pulso em 0,3 s
	_check(game.enemies.count == 0, "um pulso deveria eliminar a horda (restam %d)" % game.enemies.count)
	_check(game.stats.kills_of(WeaponCatalog.AURA) == 80, "80 abates contados para a aura")
	_check(game.aura.pulses == 1, "um pulso só (foram %d)" % game.aura.pulses)


func _blade_hits_in(seconds: float, distance: float) -> int:
	var target := _spawn_still(distance, 1.0e6)
	var id: int = game.enemies.id_of(target)
	var start: int = game.blades.hits
	await _frames(int(seconds * 60.0))
	var hits: int = game.blades.hits - start
	var lost: float = 1.0e6 - game.enemies.hp_of(_index_of_id(id))
	_check(_near(lost, hits * game.blades.effective_damage(), 0.5), "dano = cortes x dano da lâmina")
	return hits


func test_lamina_orbital() -> void:
	await _new_game()
	_disable_bolt()
	game.player.invulnerable = true
	game.apply_offer(WeaponCatalog.BLADE)
	var blades: OrbitBlades = game.blades
	_check(blades.blade_count() == 1 and blades.visible, "uma lâmina no nível 1")
	var positions := blades.blade_positions()
	var distance: float = positions[0].distance_to(game.player.global_position)
	_check(_near(distance, 1.9, 0.01), "a lâmina orbita a 1,9 m (está a %.2f)" % distance)
	var a0 := blades._angle
	await _frames(30)
	var turned := wrapf(blades._angle - a0, 0.0, TAU)
	_check(_near(turned, 1.6, 0.06), "a lâmina gira 3,2 rad/s (girou %.2f em 0,5 s)" % turned)
	var one := await _blade_hits_in(4.0, 1.9)
	_check(one >= 1 and one <= 3, "1 lâmina, ~2 voltas em 4 s: 1 a 3 cortes (foram %d)" % one)
	_clear_enemies()
	for i in 4:
		game.apply_offer(WeaponCatalog.BLADE)
	_check(blades.level == 5 and blades.blade_count() == 4, "4 lâminas no nível 5")
	_check(_near(blades.orbit_radius(), 2.5) and _near(blades.effective_damage(), 24.0), "nível 5")
	var four := await _blade_hits_in(4.0, 2.5)
	_check(four >= one * 3, "4 lâminas deveriam cortar bem mais (%d contra %d)" % [four, one])
	var limit := int(4.0 / OrbitBlades.HIT_COOLDOWN) + 1
	_check(four <= limit, "a recarga limita os cortes por inimigo (%d de no máximo %d)" % [four, limit])


func test_niveis_e_limites_das_armas() -> void:
	await _new_game()
	for level in range(1, 6):
		_check(game.apply_offer(WeaponCatalog.AURA), "a aura deveria chegar ao nível %d" % level)
		var expected: Dictionary = WeaponCatalog.stats(WeaponCatalog.AURA, level)
		_check(game.aura.level == level, "nível da aura")
		_check(_near(game.aura.effective_damage(), expected.damage), "dano no nível %d" % level)
		_check(_near(game.aura.effective_radius(), expected.radius), "alcance no nível %d" % level)
	_check(not game.apply_offer(WeaponCatalog.AURA), "o 6º nível deveria ser recusado")
	_check(not game.offers.valid_ids().has(WeaponCatalog.AURA), "aura no máximo sai das ofertas")
	_check(game.hud.weapons_text().contains("Aura de brasas 5"), "o HUD mostra a aura no nível 5")


# ---------------------------------------------------------------- ofertas do level-up


func _fresh_offers() -> LevelUpOffers:
	return LevelUpOffers.new(Upgrades.new(), Arsenal.new())


func test_ofertas_validas_e_distintas() -> void:
	var offers := _fresh_offers()
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var seen := {}
	for i in 400:
		var choices := offers.roll(3, rng)
		_check(choices.size() == 3, "deveria haver 3 opções")
		var unique := {}
		for id in choices:
			unique[id] = true
			seen[id] = true
			_check(offers.is_valid(id), "opção inválida: %s" % id)
		_check(unique.size() == 3, "opções repetidas: %s" % [choices])
	_check(seen.size() == 8, "6 melhorias e 2 armas novas deveriam aparecer (%d)" % seen.size())
	_check(not seen.has(WeaponCatalog.BOLT), "a arma inicial nunca é oferecida")
	_check(offers.kind_of(WeaponCatalog.AURA) == LevelUpOffers.KIND_NEW_WEAPON, "aura = arma nova")
	offers.arsenal.acquire(WeaponCatalog.AURA)
	_check(offers.kind_of(WeaponCatalog.AURA) == LevelUpOffers.KIND_WEAPON_UP, "aura = evolução")
	_check(offers.tag_of(WeaponCatalog.AURA).contains("1 » 2"), "o cartão mostra o nível")
	while offers.arsenal.level_up(WeaponCatalog.AURA):
		pass
	for i in 200:
		_check(not offers.roll(3, rng).has(WeaponCatalog.AURA), "arma no máximo não volta")
	# Menos de 3 válidas: mostra só as que existem, sem repetir nem inventar.
	offers.arsenal.acquire(WeaponCatalog.BLADE)
	while offers.arsenal.level_up(WeaponCatalog.BLADE):
		pass
	for id in Upgrades.all_ids():
		if id != Upgrades.DAMAGE and id != Upgrades.SPEED:
			offers.upgrades._stacks[id] = int(Upgrades.definition(id).max)
	var two := offers.roll(3, rng)
	_check(two.size() == 2 and two[0] != two[1], "só 2 válidas: 2 opções distintas (%s)" % [two])
	offers.upgrades._stacks[Upgrades.DAMAGE] = 10
	offers.upgrades._stacks[Upgrades.SPEED] = 5
	_check(offers.roll(3, rng).is_empty(), "nada válido: nenhuma opção")


func test_ofertas_preservam_a_progressao() -> void:
	await _new_game()
	game.progression.add_xp(Progression.requirement(1) + 2)
	await _frames(2)
	_check(game.level_up_panel.is_open(), "a escolha deveria abrir")
	var xp_before: int = game.progression.xp
	var choices: Array[StringName] = game.level_up_panel.choice_ids()
	await _choose(choices[0])
	_check(game.progression.level == 2 and game.progression.xp == xp_before, "a XP não muda")
	_check(game.progression.pending_level_ups == 0, "a escolha consome o nível")
	var applied: bool = (
		game.arsenal.level(choices[0]) == 1
		if WeaponCatalog.is_weapon(choices[0])
		else game.upgrades.stacks(choices[0]) == 1
	)
	_check(applied, "a opção escolhida (%s) deveria ter sido aplicada" % choices[0])


func test_troca_de_opcoes() -> void:
	var offers := _fresh_offers()
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	_check(offers.rerolls_left == 2, "2 trocas por partida")
	var first := offers.roll(3, rng)
	var second := offers.reroll(first, rng)
	_check(second.size() == 3 and offers.rerolls_left == 1, "a troca gasta 1 e traz 3 opções")
	for id in second:
		_check(not first.has(id), "com 8 opções, a troca não repete as anteriores")
	offers.reroll(second, rng)
	var last := offers.roll(3, rng)
	_check(offers.reroll(last, rng) == last, "sem trocas, as opções não mudam")
	_check(offers.rerolls_left == 0 and offers.banishes_left == 2, "trocar não gasta bloqueio")
	# Na tela, pelo mesmo caminho do botão.
	await _new_game()
	_grant_level()
	await _frames(2)
	var panel: LevelUpPanel = game.level_up_panel
	while panel.is_locked():
		await process_frame
	var before := panel.choice_ids()
	panel.reroll_button().pressed.emit()
	await _frames(1)
	var after := panel.choice_ids()
	_check(after != before and after.size() == 3, "o botão deveria trocar as opções")
	_check(game.offers.rerolls_left == 1, "a troca deveria ser contada")
	_check(panel.reroll_button().text.contains("(1)"), "o botão mostra as trocas restantes")
	_check(panel.is_open() and paused, "a troca não fecha a escolha nem tira a pausa")
	_check(game.progression.pending_level_ups == 1, "a troca não consome o nível")


func test_bloqueio_de_opcoes() -> void:
	var offers := _fresh_offers()
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var current: Array[StringName] = [Upgrades.DAMAGE, Upgrades.SPEED, WeaponCatalog.AURA]
	var replacement := offers.banish(Upgrades.DAMAGE, current, rng)
	_check(replacement != &"" and not current.has(replacement), "o bloqueio traz outra opção")
	_check(offers.is_valid(replacement), "a substituta é válida")
	_check(offers.is_banished(Upgrades.DAMAGE) and offers.banishes_left == 1, "bloqueio contado")
	_check(offers.rerolls_left == 2, "bloquear não gasta troca")
	for i in 300:
		_check(not offers.roll(3, rng).has(Upgrades.DAMAGE), "bloqueada não volta a aparecer")
	_check(offers.banish(Upgrades.DAMAGE, current, rng) == &"", "não bloqueia duas vezes")
	offers.banish(Upgrades.SPEED, current, rng)
	_check(not offers.can_banish(Upgrades.VITALITY), "sem bloqueios restantes")
	# Nunca bloqueia a última opção válida.
	var lone := _fresh_offers()
	lone.arsenal.max_slots = 1
	for id in Upgrades.all_ids():
		if id != Upgrades.RANGE:
			lone.upgrades._stacks[id] = int(Upgrades.definition(id).max)
	_check(lone.valid_ids() == [Upgrades.RANGE], "só 1 opção válida")
	_check(not lone.can_banish(Upgrades.RANGE), "a última opção válida não pode ser bloqueada")
	# Na tela: o botão do cartão troca só aquele cartão.
	await _new_game()
	_grant_level()
	await _frames(2)
	var panel: LevelUpPanel = game.level_up_panel
	while panel.is_locked():
		await process_frame
	var before := panel.choice_ids()
	panel.lock_buttons()[0].pressed.emit()
	await _frames(1)
	var after := panel.choice_ids()
	_check(after.size() == 3 and after[0] != before[0], "o cartão bloqueado é substituído")
	_check(after[1] == before[1] and after[2] == before[2], "os outros cartões ficam")
	_check(game.offers.is_banished(before[0]), "a opção fica bloqueada na partida")
	# Partida nova: bloqueios e trocas voltam ao início.
	await _new_game()
	_check(game.offers.banished_ids().is_empty(), "bloqueios não passam para a próxima partida")
	_check(game.offers.banishes_left == 2 and game.offers.rerolls_left == 2, "limites renovados")


# ---------------------------------------------------------------- inimigos


func test_mistura_de_inimigos_por_tempo() -> void:
	var w0 := EnemyTypes.spawn_weights(0.0)
	for kind in range(1, EnemyTypes.COUNT):
		_check(w0[kind] == 0.0, "no começo só aparece o comum (tipo %d)" % kind)
	var w60 := EnemyTypes.spawn_weights(60.0)
	_check(w60[EnemyTypes.RAPIDO] > 0.0, "o Espreitador aparece depois de 45 s")
	_check(w60[EnemyTypes.RESISTENTE] == 0.0 and w60[EnemyTypes.EXPLOSIVO] == 0.0, "ainda não")
	var w400 := EnemyTypes.spawn_weights(400.0)
	for kind in [EnemyTypes.RAPIDO, EnemyTypes.RESISTENTE, EnemyTypes.ATIRADOR, EnemyTypes.EXPLOSIVO]:
		_check(w400[kind] > 0.0, "aos 400 s o tipo %d aparece" % kind)
	_check(w400[EnemyTypes.CHEFE] == 0.0, "o chefe nunca é sorteado")
	# Na partida, com hordas de verdade.
	await _new_game(true)
	game.player.invulnerable = true
	game.enemies.elapsed = 400.0
	await _frames(300)
	for kind in [EnemyTypes.RAPIDO, EnemyTypes.RESISTENTE, EnemyTypes.ATIRADOR, EnemyTypes.EXPLOSIVO]:
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
		var index: int = game.enemies.spawn_at(game.player.global_position + dirs[k] * 9.0, 1.0e6, kinds[k])
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
	_check(taken >= 10.0, "o projétil do Lançador deveria acertar o jogador parado (%.1f)" % taken)
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
	_check(_near(hp_before - game.player.hp, 26.0), "a explosão tira 26 (tirou %.1f)" % (hp_before - game.player.hp))
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
	_check(_near(game.enemies.spawn_rate_multiplier, 0.5), "as hordas desaceleram no encontro")


func test_chefe_ataques_com_aviso() -> void:
	await _new_game()
	_disable_bolt()
	game.player.invulnerable = true
	game.start_encounter()
	var warned_before := {}
	for f in 60 * 20:
		await process_frame
		var state: int = game.boss.state
		if state in [BossController.State.PREPARAR_INVESTIDA, BossController.State.PREPARAR_ERUPCAO]:
			if game.effects.count > 0:
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
	game.enemies.damage(game.enemies.boss_index(), 3600.0, &"teste")
	await _frames(2)
	_check(game.boss.phase == 2, "abaixo de 50% o chefe entra na fase 2")
	_check(game.enemies.count >= 7, "a fase 2 traz reforços (%d inimigos)" % game.enemies.count)
	_check(_near(game.hud.boss_bar_ratio(), 3400.0 / 7000.0, 0.01), "a barra acompanha o dano")
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
			"intervalo de %d quadros: %d esquiva(s), esperado %d" % [gap, game.player.dodges_used, expected]
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
	_check(_near(data.damage_dealt, 45.0, 0.01), "dano causado = vida tirada (%.1f)" % data.damage_dealt)
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
	_check(game.stats.total_damage() == 0.0 and game.stats.bosses_defeated == 0, "estatísticas zeradas")
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
	_check(again.level_of(MetaProgress.RENEWAL) == 2 and again.cost_of(MetaProgress.RENEWAL) == -1, "máximo")
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
