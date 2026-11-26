extends "res://tests/suites/base.gd"
## Armas (Raio, Aura, Lâmina), espaços, níveis e as ofertas do level-up (troca e bloqueio).

const TESTS := [
	"test_arsenal_espacos_independentes",
	"test_aura_pulso_alcance_e_dano",
	"test_aura_contra_horda",
	"test_lamina_orbital",
	"test_niveis_e_limites_das_armas",
	"test_ofertas_validas_e_distintas",
	"test_ofertas_preservam_a_progressao",
	"test_troca_de_opcoes",
	"test_bloqueio_de_opcoes",
]

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
	var top: Dictionary = WeaponCatalog.stats(WeaponCatalog.AURA, 5)
	_check(_near(top.damage, 14.0), "dano da aura no nível 5")
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
	var left: int = game.enemies.count
	_check(left == 0, "um pulso deveria eliminar a horda (restam %d)" % left)
	_check(game.stats.kills_of(WeaponCatalog.AURA) == 80, "80 abates contados para a aura")
	_check(game.aura.pulses == 1, "um pulso só (foram %d)" % game.aura.pulses)


func _blade_hits_in(seconds: float, distance: float) -> int:
	var target := _spawn_still(distance, 1.0e6)
	var id: int = game.enemies.id_of(target)
	var start: int = game.blades.hits
	await _frames(int(seconds * 60.0))
	var hits: int = game.blades.hits - start
	var lost: float = 1.0e6 - game.enemies.hp_of(_index_of_id(id))
	var expected: float = hits * game.blades.effective_damage()
	_check(_near(lost, expected, 0.5), "dano = cortes x dano da lâmina")
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
	var top: Dictionary = WeaponCatalog.stats(WeaponCatalog.BLADE, 5)
	_check(_near(blades.orbit_radius(), top.radius), "alcance do nível 5")
	_check(_near(blades.effective_damage(), top.damage), "dano do nível 5")
	var four := await _blade_hits_in(4.0, 2.5)
	_check(four >= one * 3, "4 lâminas deveriam cortar bem mais (%d contra %d)" % [four, one])
	var limit := int(4.0 / OrbitBlades.HIT_COOLDOWN) + 1
	_check(four <= limit, "a recarga limita os cortes (%d de no máximo %d)" % [four, limit])


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
