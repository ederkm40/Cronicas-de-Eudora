class_name LevelUpOffers
extends RefCounted
## Monta as ofertas do level-up: armas novas, evoluções das armas que o jogador tem
## e melhorias passivas. Também controla a troca de opções e o bloqueio.
##
## Regras:
## - Só entram ofertas válidas: arma com espaço livre, arma abaixo do nível máximo,
##   melhoria abaixo do limite, e nada que o jogador tenha bloqueado nesta partida.
## - As opções de uma tela são sempre diferentes entre si. Se houver menos de 3 válidas,
##   a tela mostra só as que existem (nunca inventa opção).
## - O sorteio é ponderado pelo estado da partida (ver `weight_of`), sem ser previsível.
## - Trocar (reroll) e bloquear são independentes e têm limites por partida.

const OFFERS_PER_LEVEL := 3
const BASE_REROLLS := 2
const BASE_BANISHES := 2
const KIND_NEW_WEAPON := "nova_arma"
const KIND_WEAPON_UP := "evolucao"
const KIND_PASSIVE := "melhoria"

var upgrades: Upgrades
var arsenal: Arsenal
var player: Player  ## Opcional: usado para pesar a melhoria de vida quando a vida está baixa.
var rerolls_left := BASE_REROLLS
var banishes_left := BASE_BANISHES
var level_ups_seen := 0  ## Telas de level-up já abertas na partida.

var _banished := {}


func _init(p_upgrades: Upgrades, p_arsenal: Arsenal, p_player: Player = null) -> void:
	upgrades = p_upgrades
	arsenal = p_arsenal
	player = p_player


## Tipo da oferta: arma nova, evolução de arma ou melhoria passiva.
func kind_of(id: StringName) -> String:
	if WeaponCatalog.is_weapon(id):
		return KIND_WEAPON_UP if arsenal.owns(id) else KIND_NEW_WEAPON
	return KIND_PASSIVE


func is_banished(id: StringName) -> bool:
	return _banished.has(id)


func banished_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for id in _banished:
		ids.append(id)
	return ids


func is_valid(id: StringName) -> bool:
	if is_banished(id):
		return false
	if WeaponCatalog.is_weapon(id):
		return arsenal.can_offer(id)
	return upgrades.stacks(id) < int(Upgrades.definition(id).get("max", 0))


## Todas as ofertas válidas agora (armas primeiro, na ordem do catálogo).
func valid_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for id in WeaponCatalog.all_ids():
		if is_valid(id):
			ids.append(id)
	for id in Upgrades.all_ids():
		if is_valid(id):
			ids.append(id)
	return ids


## Peso no sorteio. Armas novas aparecem bastante no começo (para o jogador montar o arsenal),
## evoluções de armas que ele já escolheu valem um pouco mais, e a vida pesa mais quando
## a vida está baixa.
func weight_of(id: StringName) -> float:
	match kind_of(id):
		KIND_NEW_WEAPON:
			return 2.2 if level_ups_seen < 6 else 1.4
		KIND_WEAPON_UP:
			return 1.4
	if id == Upgrades.VITALITY and player and player.hp < player.max_hp * 0.5:
		return 2.0
	return 1.0


## Sorteia até `amount` ofertas diferentes e válidas, sem as de `exclude` quando possível.
func roll(
	amount: int = OFFERS_PER_LEVEL,
	rng: RandomNumberGenerator = null,
	exclude: Array[StringName] = []
) -> Array[StringName]:
	var pool := valid_ids()
	var preferred: Array[StringName] = []
	for id in pool:
		if not exclude.has(id):
			preferred.append(id)
	# Se excluir deixaria a tela com menos opções do que existem, completa com as excluídas.
	var picked := _weighted_pick(preferred, amount, rng)
	if picked.size() < amount:
		var rest: Array[StringName] = []
		for id in pool:
			if not picked.has(id):
				rest.append(id)
		picked.append_array(_weighted_pick(rest, amount - picked.size(), rng))
	return picked


func _weighted_pick(
	pool: Array[StringName], amount: int, rng: RandomNumberGenerator
) -> Array[StringName]:
	var candidates := pool.duplicate()
	var picked: Array[StringName] = []
	while picked.size() < amount and not candidates.is_empty():
		var total := 0.0
		for id in candidates:
			total += weight_of(id)
		var target := (rng.randf() if rng else randf()) * total
		var chosen := candidates.size() - 1
		for k in candidates.size():
			target -= weight_of(candidates[k])
			if target < 0.0:
				chosen = k
				break
		picked.append(candidates[chosen])
		candidates.remove_at(chosen)
	return picked


## Opções da próxima tela de level-up.
func roll_for_level_up(rng: RandomNumberGenerator = null) -> Array[StringName]:
	var choices := roll(OFFERS_PER_LEVEL, rng)
	if not choices.is_empty():
		level_ups_seen += 1
	return choices


func can_reroll() -> bool:
	return rerolls_left > 0 and valid_ids().size() > 0


## Troca todas as opções (gasta 1 troca). Evita repetir as atuais quando há alternativas.
## Retorna as opções atuais sem mudança se não houver troca disponível.
func reroll(current: Array[StringName], rng: RandomNumberGenerator = null) -> Array[StringName]:
	if not can_reroll():
		return current
	rerolls_left -= 1
	return roll(maxi(current.size(), OFFERS_PER_LEVEL), rng, current)


## Bloquear só é permitido se sobrar pelo menos outra oferta válida na partida.
func can_banish(id: StringName) -> bool:
	return banishes_left > 0 and is_valid(id) and valid_ids().size() > 1


## Bloqueia a oferta pelo resto da partida e devolve uma substituta que não esteja na tela
## (ou &"" se não houver). Retorna &"" e não faz nada se o bloqueio não for permitido.
func banish(
	id: StringName, current: Array[StringName], rng: RandomNumberGenerator = null
) -> StringName:
	if not can_banish(id):
		return &""
	banishes_left -= 1
	_banished[id] = true
	var others: Array[StringName] = []
	for candidate in valid_ids():
		if not current.has(candidate):
			others.append(candidate)
	var replacement := _weighted_pick(others, 1, rng)
	return replacement[0] if not replacement.is_empty() else &""


## Aplica a oferta escolhida. Retorna false se ela não era válida.
func apply(id: StringName, p_player: Player, bolt: AutoWeapon) -> bool:
	if not is_valid(id):
		return false
	if WeaponCatalog.is_weapon(id):
		return arsenal.advance(id)
	return upgrades.apply(id, p_player, bolt)


## Título curto do tipo de oferta, para o cartão.
func tag_of(id: StringName) -> String:
	match kind_of(id):
		KIND_NEW_WEAPON:
			return "NOVA ARMA"
		KIND_WEAPON_UP:
			return "ARMA · Nv. %d » %d" % [arsenal.level(id), arsenal.level(id) + 1]
	return "MELHORIA · %d/%d" % [upgrades.stacks(id), int(Upgrades.definition(id).max)]


func name_of(id: StringName) -> String:
	if WeaponCatalog.is_weapon(id):
		return WeaponCatalog.definition(id).name
	return Upgrades.definition(id).name


func description_of(id: StringName) -> String:
	if WeaponCatalog.is_weapon(id):
		return WeaponCatalog.definition(id).description
	return Upgrades.definition(id).description


func detail_of(id: StringName) -> String:
	if WeaponCatalog.is_weapon(id):
		return WeaponCatalog.describe_change(id, arsenal.level(id))
	return upgrades.describe_next(id)
