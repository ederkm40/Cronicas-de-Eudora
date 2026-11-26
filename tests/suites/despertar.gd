extends "res://tests/suites/base.gd"
## O Despertar de Eudora (0.4-alpha): evoluções de armas, Pacto do eco, elites, Tecelão,
## Semeador, chefe atordoado e Prisão de ecos, eventos da partida, configurações, pausa,
## som e números de dano.

const TESTS := [
	"test_evolucao_exige_requisitos_e_e_unica",
	"test_evolucao_raio_em_cadeia",
	"test_evolucao_coroa_de_cinzas_queima",
	"test_evolucao_vendaval_de_laminas",
	"test_pacto_do_eco",
	"test_elite_blindado",
	"test_elite_gerador_invoca",
	"test_tecelao_protege_aliados",
	"test_semeador_deixa_pocas",
	"test_chefe_atordoado_apos_investida",
	"test_chefe_prisao_com_saida",
	"test_fenda_do_eco_completa_e_falha",
	"test_mare_e_calmaria",
	"test_eventos_param_no_encontro_final",
	"test_configuracoes_salvam_e_validam",
	"test_canhoto_e_joystick_fixo",
	"test_pausa_e_configuracoes",
	"test_toque_no_botao_de_pausa_nao_move",
	"test_sons_procedurais",
	"test_numeros_de_dano_e_estouros",
]


func _set_stacks(stacks: Dictionary) -> void:
	for id in stacks:
		game.upgrades._stacks[id] = stacks[id]
	game.upgrades.refresh(game.player, game.weapon)


func _max_weapon(id: StringName) -> void:
	game.arsenal.acquire(id)
	while game.arsenal.level_up(id):
		pass
	game._sync_weapons()


func _still_enemy(distance: float, hp: float = 1.0e6, kind: int = EnemyTypes.COMUM) -> int:
	var index: int = game.enemies.spawn_at(_enemy_point(distance), hp, kind)
	game.enemies._speed[index] = 0.0
	return index


## Converte um ponto da tela do jogo (coordenadas da interface) para a janela, onde os
## toques chegam. Na janela pequena do modo headless as duas escalas são diferentes.
func _window_point(local: Vector2) -> Vector2:
	var joystick: FloatingJoystick = game.joystick
	var viewport := joystick.get_viewport()
	return viewport.get_final_transform() * (joystick.get_global_transform_with_canvas() * local)


# ---------------------------------------------------------------- evoluções


func test_evolucao_exige_requisitos_e_e_unica() -> void:
	await _new_game()
	var offers: LevelUpOffers = game.offers
	_check(not offers.is_valid(WeaponCatalog.EVO_BOLT), "sem requisitos, nada de evolução")
	_set_stacks({Upgrades.PROJECTILE: 2})
	_check(not offers.is_valid(WeaponCatalog.EVO_BOLT), "faltando Poder arcano 3")
	_set_stacks({Upgrades.DAMAGE: 3})
	_check(offers.is_valid(WeaponCatalog.EVO_BOLT), "requisitos cumpridos: aparece")
	_check(offers.valid_ids().has(WeaponCatalog.EVO_BOLT), "entra no sorteio")
	_check(offers.tag_of(WeaponCatalog.EVO_BOLT).begins_with("EVOLUÇÃO"), "a carta mostra EVOLUÇÃO")
	_check(game.apply_offer(WeaponCatalog.EVO_BOLT), "evolui")
	_check(game.stats.evolutions == 1, "a evolução é contada")
	_check(not offers.is_valid(WeaponCatalog.EVO_BOLT), "uma arma evolui uma vez só")
	_check(not game.apply_offer(WeaponCatalog.EVO_BOLT), "não aplica duas vezes")
	_check(game.stats.evolutions == 1, "continua 1")
	_check(not offers.is_valid(WeaponCatalog.EVO_AURA), "a Aura precisa estar no nível 5")


func test_evolucao_raio_em_cadeia() -> void:
	await _new_game()
	_set_stacks({Upgrades.PROJECTILE: 2, Upgrades.DAMAGE: 3})
	game.apply_offer(WeaponCatalog.EVO_BOLT)
	_check(game.weapon.chain_enabled, "o raio passa a saltar")
	_check(game.hud.weapons_text().contains("Raio em cadeia"), "o HUD mostra a evolução")
	for k in 3:
		_still_enemy(4.0 + k * 1.2)
	await _frames(120)
	_check(game.weapon.chain_hits > 0, "o raio saltou para vizinhos (%d)" % game.weapon.chain_hits)


func test_evolucao_coroa_de_cinzas_queima() -> void:
	await _new_game()
	_max_weapon(WeaponCatalog.AURA)
	_set_stacks({Upgrades.FIRE_RATE: 2})
	var radius: float = game.aura.effective_radius()
	_check(game.apply_offer(WeaponCatalog.EVO_AURA), "Aura 5 + Cadência 2 evolui")
	_check(game.aura.evolved, "a aura vira Coroa de cinzas")
	_check(game.aura.effective_radius() > radius, "a coroa cobre mais área")
	game.weapon.projectile_damage = 0.0
	var index := _still_enemy(1.0)
	var burned := false
	for i in 180:
		await process_frame
		if game.enemies.status_of(index) & EnemyManager.STATUS_BURN:
			burned = true
			break
	_check(burned, "quem leva o pulso fica em chamas")
	var hp: float = game.enemies.hp_of(index)
	game.aura.level = 0  # sem novos pulsos: só a queimadura
	await _frames(30)
	_check(game.enemies.hp_of(index) < hp, "a queimadura continua ferindo")


func test_evolucao_vendaval_de_laminas() -> void:
	await _new_game()
	_max_weapon(WeaponCatalog.BLADE)
	_set_stacks({Upgrades.SPEED: 2})
	var before: int = game.blades.blade_count()
	_check(game.apply_offer(WeaponCatalog.EVO_BLADE), "Lâminas 5 + Passos 2 evolui")
	_check(game.blades.blade_count() == before + 2, "duas lâminas a mais")
	var radii := {}
	for i in 60:
		await process_frame
		radii[snappedf(game.blades.orbit_radius(), 0.1)] = true
	_check(radii.size() > 3, "o raio das lâminas respira (vai e volta)")
	game.weapon.projectile_damage = 0.0
	var index := _still_enemy(2.0)
	var slowed := false
	for i in 240:
		await process_frame
		if index < game.enemies.count and game.enemies.status_of(index) & EnemyManager.STATUS_SLOW:
			slowed = true
			break
	_check(slowed, "o corte deixa o inimigo lento")


func test_pacto_do_eco() -> void:
	await _new_game()
	var base_damage: float = game.weapon.effective_damage()
	game.upgrades.apply(Upgrades.PACT, game.player, game.weapon)
	_check(_near(game.weapon.effective_damage(), base_damage * 1.25), "+25% de dano")
	_check(_near(game.upgrades.xp_multiplier, 1.15), "+15% de experiência")
	_check(_near(game.player.damage_taken_multiplier, 1.2), "+20% de dano recebido")
	var hp: float = game.player.hp
	game.player.take_damage(10.0, "teste")
	_check(_near(hp - game.player.hp, 12.0), "10 de dano viram 12")
	var xp: int = game.progression.total_xp
	for i in 20:
		game._on_xp_collected(1)
	_check(game.progression.total_xp - xp == 23, "20 de XP viram 23 (as frações somam)")
	for i in 5:
		game.upgrades.apply(Upgrades.PACT, game.player, game.weapon)
	_check(game.upgrades.stacks(Upgrades.PACT) == 3, "o pacto para em 3")


# ---------------------------------------------------------------- inimigos


func test_elite_blindado() -> void:
	await _new_game()
	var normal: int = game.enemies.spawn_at(_enemy_point(5.0), 100.0)
	var elite: int = game.enemies.spawn_at(
		_enemy_point(5.0) + Vector3(0, 0, 2), 100.0, EnemyTypes.COMUM, EnemyTypes.BLINDADO
	)
	var elite_hp := 100.0 * EnemyTypes.ELITE_HP
	_check(_near(game.enemies.max_hp_of(elite), elite_hp), "elite com a vida multiplicada")
	_check(game.enemies.status_of(elite) & EnemyManager.STATUS_ELITE, "marcado como elite")
	game.enemies.damage(normal, 10.0)
	game.enemies.damage(elite, 10.0)
	var lost_normal: float = 100.0 - game.enemies.hp_of(normal)
	var lost_elite: float = elite_hp - game.enemies.hp_of(elite)
	_check(lost_elite < lost_normal * 0.8, "o Blindado reduz o dano")
	var hp_before: float = game.player.hp - 30.0
	game.player.hp = hp_before
	var kills: int = game.stats.elites_killed
	game.enemies.damage(elite, 1.0e6)
	await _frames(2)
	_check(game.stats.elites_killed == kills + 1, "o abate do elite é contado")
	_check(game.player.hp > hp_before, "derrotar um elite cura")
	_check(game.orbs.count > 0, "e deixa um orbe grande")


func test_elite_gerador_invoca() -> void:
	await _new_game()
	game.weapon.projectile_damage = 0.0
	var elite: int = game.enemies.spawn_at(
		_enemy_point(7.0), 1.0e6, EnemyTypes.COMUM, EnemyTypes.GERADOR
	)
	game.enemies._speed[elite] = 0.0
	var before: int = game.enemies.count
	await _frames(int(game.enemies.elite_spawner_interval * 60.0) + 30)
	_check(game.enemies.count >= before + 2, "o Gerador chama Errantes (%d)" % game.enemies.count)


func test_tecelao_protege_aliados() -> void:
	await _new_game()
	game.weapon.projectile_damage = 0.0
	var ally := _still_enemy(6.0, 100.0)
	var lone: int = game.enemies.spawn_at(game.player.global_position + Vector3(0, 0, -9), 100.0)
	game.enemies._speed[lone] = 0.0
	var weaver: int = game.enemies.spawn_at(_enemy_point(7.0), 1.0e6, EnemyTypes.TECELAO)
	game.enemies._speed[weaver] = 0.0
	await _frames(3)
	_check(game.enemies.status_of(ally) & EnemyManager.STATUS_SHIELD, "o vizinho ganha escudo")
	_check(not (game.enemies.status_of(lone) & EnemyManager.STATUS_SHIELD), "o distante não")
	_check(not (game.enemies.status_of(weaver) & EnemyManager.STATUS_SHIELD), "nem o próprio")
	game.enemies.damage(ally, 10.0)
	game.enemies.damage(lone, 10.0)
	_check(_near(100.0 - game.enemies.hp_of(ally), 6.0), "o escudo tira 40% do dano")
	_check(_near(100.0 - game.enemies.hp_of(lone), 10.0), "sem escudo, dano cheio")


func test_semeador_deixa_pocas() -> void:
	await _new_game()
	game.weapon.projectile_damage = 0.0
	game.enemies.spawn_at(_enemy_point(6.0), 1.0e6, EnemyTypes.SEMEADOR)
	await _frames(int(game.enemies.sower_interval * 60.0) + 30)
	var hazards: HazardZones = game.hazards
	_check(hazards.count > 0, "o Semeador deixa poças de cinzas")
	hazards.add(game.player.global_position)
	_check(not hazards.is_dangerous(game.player.global_position), "a poça avisa antes de ferir")
	var hp: float = game.player.hp
	await _frames(int(hazards.arm_time * 60.0) + 30)
	_check(game.player.hp < hp, "parado na poça ativa, o jogador se fere")
	await _frames(int(hazards.duration * 60.0) + 10)
	_check(not hazards.is_dangerous(game.player.global_position), "a poça some depois de um tempo")


func test_chefe_atordoado_apos_investida() -> void:
	await _new_game()
	game.weapon.projectile_damage = 0.0
	game.player.invulnerable = true
	var index: int = game.boss.spawn(_enemy_point(8.0))
	game.boss._enter(BossController.State.PREPARAR_INVESTIDA)
	var stunned := false
	for i in 240:
		await process_frame
		if game.boss.state == BossController.State.ATORDOADO:
			stunned = true
			break
	_check(stunned, "depois da investida o chefe fica atordoado")
	_check(game.enemies.boss_vulnerable, "e exposto")
	index = game.enemies.boss_index()
	var hp: float = game.enemies.hp_of(index)
	game.enemies.damage(index, 100.0)
	_check(_near(hp - game.enemies.hp_of(index), 150.0), "exposto, leva +50% de dano")
	await _frames(int(game.boss.stun_time * 60.0) + 5)
	_check(game.boss.state == BossController.State.PERSEGUIR, "depois volta a perseguir")
	_check(not game.enemies.boss_vulnerable, "e o ponto fraco fecha")


func test_chefe_prisao_com_saida() -> void:
	await _new_game()
	game.weapon.projectile_damage = 0.0
	game.boss.spawn(_enemy_point(9.0))
	var warned := [0]
	game.boss.attack_warned.connect(func() -> void: warned[0] += 1)
	game.boss._enter(BossController.State.PREPARAR_PRISAO)
	await _frames(2)
	_check(warned[0] == 1, "o ataque é avisado (som de alerta)")
	var cells: int = game.boss._eruptions.size()
	_check(cells == game.boss.prison_cells - 2, "o anel tem uma saída de 2 círculos (%d)" % cells)
	var hp: float = game.player.hp
	await _frames(int(game.boss.prison_windup * 60.0) + 5)
	_check(game.boss.attack_counts.get("prisão", 0) == 1, "a prisão fecha")
	_check(_near(game.player.hp, hp), "quem fica no centro não é atingido")
	# Parado em cima de um círculo, o jogador é atingido.
	game.boss._enter(BossController.State.PREPARAR_PRISAO)
	await _frames(2)
	game.player.global_position = game.boss._eruptions[0]
	await _frames(int(game.boss.prison_windup * 60.0) + 5)
	_check(game.player.hp < hp, "em cima de um círculo, leva dano")


# ---------------------------------------------------------------- eventos


func test_fenda_do_eco_completa_e_falha() -> void:
	await _new_game()
	var director: EventDirector = game.director
	director.start_rift()
	_check(director.rift_active, "a fenda abre")
	game.player.global_position = director.rift_position
	await _frames(30)
	_check(game.hud.event_text().begins_with("Fenda do Eco"), "o HUD mostra o progresso")
	await _frames(int(director.rift_channel * 60.0))
	_check(not director.rift_active and game.stats.rifts_completed == 1, "fenda completada")
	_check(game.level_up_panel.is_open(), "completar dá uma escolha extra")
	await _choose(game.level_up_panel.choice_ids()[0])
	director.rift_window = 1.0
	director.start_rift()
	game.player.global_position = director.rift_position + Vector3(20, 0, 0)
	await _frames(75)
	_check(not director.rift_active and game.stats.rifts_failed == 1, "fora dela, a fenda falha")


func test_mare_e_calmaria() -> void:
	await _new_game()
	var director: EventDirector = game.director
	director.tide_duration = 0.5
	director.calm_duration = 0.5
	director.start_tide()
	await _frames(2)
	_check(_near(game.enemies.spawn_rate_multiplier, 2.5), "a maré acelera as hordas")
	_check(game.hud.event_text() == "Maré da horda", "o HUD avisa a maré")
	await _frames(35)
	_check(director.tide == EventDirector.Tide.CALMARIA, "depois vem a calmaria")
	_check(_near(game.enemies.spawn_rate_multiplier, 0.25), "a calmaria segura as hordas")
	await _frames(35)
	_check(director.tide == EventDirector.Tide.NORMAL, "e tudo volta ao normal")
	_check(_near(game.enemies.spawn_rate_multiplier, 1.0), "ritmo normal")
	_check(game.stats.tides == 1, "a maré é contada")


func test_eventos_param_no_encontro_final() -> void:
	await _new_game()
	var director: EventDirector = game.director
	director.start_rift()
	director.start_tide()
	game.start_encounter()
	await _frames(2)
	_check(director.stopped and not director.rift_active, "o encontro final cancela a fenda")
	_check(director.tide == EventDirector.Tide.NORMAL, "e a maré")
	_check(
		_near(game.enemies.spawn_rate_multiplier, game.encounter_spawn_rate),
		"o ritmo do encontro final é mantido"
	)


# ---------------------------------------------------------------- celular e configurações


func test_configuracoes_salvam_e_validam() -> void:
	var file := "user://teste_config_suite.json"
	for suffix in ["", ".corrompido"]:
		if FileAccess.file_exists(file + suffix):
			DirAccess.remove_absolute(file + suffix)
	var settings := GameSettings.load_from(file)
	_check(settings.values.mao == "destro", "padrão: destro")
	_check(settings.values.joystick_modo == "flutuante", "padrão: joystick flutuante")
	settings.cycle("mao")
	settings.cycle("joystick_tamanho")
	settings.cycle("som")
	_check(not settings.set_value("joystick_tamanho", "gigante"), "valor inválido recusado")
	_check(settings.save(), "salva")
	var again := GameSettings.load_from(file)
	_check(again.values.mao == "canhoto", "a mão escolhida é lembrada")
	_check(again.values.joystick_tamanho == "grande", "o tamanho é lembrado")
	_check(again.values.som == false, "o som desligado é lembrado")
	var bad := FileAccess.open(file, FileAccess.WRITE)
	bad.store_string('{"mao": "polvo", "som": 3, "tremor": false}')
	bad.close()
	var fixed := GameSettings.load_from(file)
	_check(fixed.values.mao == "destro" and fixed.values.som == true, "inválidos voltam ao padrão")
	_check(fixed.values.tremor == false, "os válidos são mantidos")
	bad = FileAccess.open(file, FileAccess.WRITE)
	bad.store_string("{ quebrado")
	bad.close()
	var broken := GameSettings.load_from(file)
	_check(broken.values == GameSettings.DEFAULTS, "arquivo quebrado: padrões")
	_check(FileAccess.file_exists(file + ".corrompido"), "e uma cópia do arquivo quebrado")


func test_canhoto_e_joystick_fixo() -> void:
	await _new_game()
	var joystick: FloatingJoystick = game.joystick
	game.settings.values.mao = "canhoto"
	game.settings.values.joystick_modo = "fixo"
	game.settings.values.joystick_tamanho = "grande"
	var right_handed_rect: Rect2 = game.hud.pause_button().get_global_rect()
	game._apply_settings()
	await _frames(3)
	_check(joystick.fixed_mode and _near(joystick.size_scale, 1.25), "fixo e grande")
	_check(joystick.fixed_center().x < joystick.size.x * 0.5, "canhoto: joystick à esquerda")
	var pause_rect: Rect2 = game.hud.pause_button().get_global_rect()
	_check(pause_rect.position.x > right_handed_rect.position.x, "canhoto: pausa espelhada")
	var center := joystick.fixed_center()
	# O toque começa em qualquer lugar, mas o centro fica parado no lugar fixo.
	_touch(true, _window_point(center + Vector2(0, -60)))
	await _frames(2)
	_check(joystick._center.is_equal_approx(center), "o centro é o lugar fixo")
	_drag(_window_point(center + Vector2(80, 0)))
	await _frames(15)
	_check(joystick.output.x > 0.9, "puxar para a direita a partir do centro fixo")
	_touch(false, _window_point(center + Vector2(80, 0)))
	await _frames(2)
	_check(joystick.output == Vector2.ZERO, "soltar para")
	game.settings.values.mao = "destro"
	game._apply_settings()
	await _frames(2)
	_check(joystick.fixed_center().x > joystick.size.x * 0.5, "destro: joystick à direita")


func test_pausa_e_configuracoes() -> void:
	await _new_game()
	game.hud.pause_button().pressed.emit()
	await _frames(2)
	_check(paused and game.pause_menu.is_open(), "o botão II pausa e abre as configurações")
	_check(not game.joystick.enabled, "o joystick desliga na pausa")
	game.pause_menu.option_button("som").pressed.emit()
	game.pause_menu.option_button("numeros_dano").pressed.emit()
	await _frames(1)
	_check(not game.sounds.enabled and not game.feedback.enabled, "som e números desligados")
	_check(not GameSettings.load_from().values.som, "a escolha fica salva para a próxima partida")
	_check(game.pause_menu.option_button("joystick_altura").disabled, "altura só no modo fixo")
	game.pause_menu.resume_button().pressed.emit()
	await _frames(2)
	_check(not paused and game.joystick.enabled, "continuar retoma a partida")
	_key(KEY_ESCAPE, true)
	await _frames(2)
	_key(KEY_ESCAPE, false)
	_check(paused and game.pause_menu.is_open(), "Esc também pausa")
	_key(KEY_ESCAPE, true)
	await _frames(2)
	_key(KEY_ESCAPE, false)
	await _frames(1)
	_check(not paused, "e Esc de novo retoma")
	_grant_level()
	await _frames(2)
	game.open_pause()
	_check(not game.pause_menu.is_open(), "não abre a pausa por cima do level-up")


func test_toque_no_botao_de_pausa_nao_move() -> void:
	await _new_game()
	await _frames(2)
	var rect: Rect2 = game.hud.pause_button().get_global_rect()
	_check(rect.size.x >= 64 and rect.size.y >= 64, "botão de pausa grande o bastante para o dedo")
	_touch(true, _window_point(rect.get_center()))
	await _frames(2)
	_check(not game.joystick.is_active(), "tocar na pausa não liga o joystick")
	_touch(false, _window_point(rect.get_center()))
	await _frames(2)
	_check(paused and game.pause_menu.is_open(), "o toque no botão pausa o jogo")
	game.pause_menu.close()
	await _frames(2)
	_touch(true, _window_point(rect.get_center() + Vector2(0, 400)))
	await _frames(2)
	_check(game.joystick.is_active(), "fora do botão o joystick liga normalmente")
	_touch(false, _window_point(rect.get_center() + Vector2(0, 400)))
	await _frames(2)


# ---------------------------------------------------------------- som e imagem


func test_sons_procedurais() -> void:
	await _new_game()
	var sounds: SoundBank = game.sounds
	for sound: StringName in SoundBank.LENGTHS:
		var stream := sounds.stream_of(sound)
		_check(stream != null and stream.data.size() > 100, "som gerado: %s" % sound)
	_check(sounds.play(&"golpe"), "toca")
	_check(not sounds.play(&"golpe"), "o mesmo som não repete no mesmo instante")
	_check(not sounds.play(&"inexistente"), "som desconhecido é ignorado")
	sounds.enabled = false
	_check(not sounds.play(&"nivel"), "som desligado não toca")
	sounds.enabled = true
	var index := _still_enemy(3.0, 1.0)
	game.enemies.damage(index, 10.0)
	await _frames(2)
	_check(sounds.played.get(&"abate", 0) >= 1, "o abate tem som")


func test_numeros_de_dano_e_estouros() -> void:
	await _new_game()
	game.weapon.projectile_damage = 0.0
	var pops: int = game.feel.pops
	for k in 3:
		game.enemies.damage(_still_enemy(3.0 + k, 1.0), 10.0)
	await _frames(2)
	_check(game.feel.pops == pops + 3, "cada abate tem um estouro no chão")
	var elite: int = game.enemies.spawn_at(
		_enemy_point(5.0), 1.0e6, EnemyTypes.COMUM, EnemyTypes.VELOZ
	)
	game.enemies.damage(elite, 40.0)
	await _frames(2)
	_check(game.feedback.shown >= 1, "golpe em elite mostra o número de dano")
	_check(game.feedback.active_count() >= 1, "o número fica visível um instante")
	var shown: int = game.feedback.shown
	game.enemies.damage(_still_enemy(4.0, 1.0e6), 40.0)
	_check(game.feedback.shown == shown, "inimigo comum não enche a tela de números")
	game.feedback.enabled = false
	game.enemies.damage(elite, 40.0)
	_check(game.feedback.shown == shown, "números desligados nas configurações")
	await _frames(int(CombatFeedback.LIFETIME * 60.0) + 5)
	_check(game.feedback.active_count() == 0, "os números somem")
