class_name RunStats
extends RefCounted
## Estatísticas reais da partida: tudo aqui é contado no momento em que acontece.
## Usadas na tela de resultados, na recompensa permanente e nas simulações de balanceamento.
##
## "Dano causado" é a vida que o inimigo realmente perdeu (o excesso do golpe final
## e a parte bloqueada pela resistência não contam).

var damage_by_weapon := {}  ## id da arma -> dano causado
var kills_by_weapon := {}  ## id da arma -> abates
var kills_by_kind := {}  ## tipo de inimigo -> abates
var damage_by_kind := {}  ## tipo de inimigo -> dano causado nele
var damage_taken := 0.0
var damage_taken_by_source := {}  ## "Contato", "Lançador", "Volátil", "Sentinela do Eco"...
var hits_taken := 0
var dodges := 0
var explosions := 0  ## Voláteis que chegaram a explodir.
var boss_spawned_at := -1.0  ## Segundos de partida em que o chefe apareceu (-1 = não apareceu).
var boss_defeated_at := -1.0
var bosses_defeated := 0
var boss_damage_taken := 0.0  ## Dano que o jogador recebeu dos ataques do chefe.
var boss_damage_dealt := 0.0
var orbs_xp := 0


func record_damage(source: StringName, amount: float, kind: int) -> void:
	if amount <= 0.0:
		return
	var key := source if source != &"" else &"outro"
	damage_by_weapon[key] = damage_by_weapon.get(key, 0.0) + amount
	damage_by_kind[kind] = damage_by_kind.get(kind, 0.0) + amount
	if kind == EnemyTypes.CHEFE:
		boss_damage_dealt += amount


func record_kill(source: StringName, kind: int) -> void:
	var key := source if source != &"" else &"outro"
	kills_by_weapon[key] = kills_by_weapon.get(key, 0) + 1
	kills_by_kind[kind] = kills_by_kind.get(kind, 0) + 1


func record_damage_taken(amount: float, source: String) -> void:
	if amount <= 0.0:
		return
	damage_taken += amount
	damage_taken_by_source[source] = damage_taken_by_source.get(source, 0.0) + amount
	if source == EnemyTypes.display_name(EnemyTypes.CHEFE):
		boss_damage_taken += amount


func total_damage() -> float:
	var total := 0.0
	for value in damage_by_weapon.values():
		total += value
	return total


func total_kills() -> int:
	var total := 0
	for value in kills_by_kind.values():
		total += value
	return total


func damage_of(weapon_id: StringName) -> float:
	return damage_by_weapon.get(weapon_id, 0.0)


func kills_of(weapon_id: StringName) -> int:
	return kills_by_weapon.get(weapon_id, 0)


## Tempo que o chefe levou para cair (-1 se não caiu).
func boss_fight_seconds() -> float:
	if boss_defeated_at < 0.0 or boss_spawned_at < 0.0:
		return -1.0
	return boss_defeated_at - boss_spawned_at
