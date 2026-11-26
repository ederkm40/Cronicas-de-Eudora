class_name BossController
extends Node3D
## Sentinela do Eco: o chefe do encontro final (aos 10 minutos).
##
## O corpo do chefe vive no EnemyManager (assim todas as armas o acertam do mesmo jeito);
## este nó só decide o que ele faz, com uma máquina de estados simples:
##
##   PERSEGUIR -> (investida | erupção | rajada, em rodízio) -> RECUPERAR -> PERSEGUIR
##
## Todo ataque perigoso tem aviso antes: faixa no chão (investida), círculos no chão (erupção)
## ou o chefe brilhando (rajada). Com metade da vida, entra na fase 2: avisos mais curtos,
## mais erupções, rajada dupla e um grupo de reforços.

signal phase_changed(phase: int)

enum State {
	INATIVO,
	PERSEGUIR,
	PREPARAR_INVESTIDA,
	INVESTIDA,
	PREPARAR_ERUPCAO,
	PREPARAR_RAJADA,
	RECUPERAR,
}

const ATTACKS := [State.PREPARAR_INVESTIDA, State.PREPARAR_ERUPCAO, State.PREPARAR_RAJADA]
const DANGER := Color(1.0, 0.2, 0.25, 0.45)

@export var max_hp := 7000.0
@export var chase_speed := 2.4
@export var chase_time := 2.2  ## Segundos perseguindo entre um ataque e outro.
@export var charge_windup := 1.0
@export var charge_speed := 16.0
@export var charge_length := 9.0
@export var charge_width := 1.8
@export var charge_damage := 28.0
@export var eruption_windup := 1.1
@export var eruption_radius := 2.0
@export var eruption_damage := 30.0
@export var volley_windup := 0.7
@export var volley_count := 14
@export var volley_speed := 6.0
@export var volley_damage := 12.0
@export var recover_time := 1.1  ## Janela em que o chefe fica parado e vulnerável.
@export var phase_two_ratio := 0.5
@export var reinforcements := 6

var enemies: EnemyManager
var player: Player
var effects: GroundEffects
var projectiles: EnemyProjectiles
var state := State.INATIVO
var phase := 1
var attack_counts := {}  ## Nome do ataque -> vezes que foi usado (testes e telemetria).

var _time := 0.0
var _cycle := 0
var _charge_direction := Vector3.ZERO
var _charge_travelled := 0.0
var _charge_hit := false
var _eruptions := PackedVector3Array()
var _telegraphs: Array[int] = []
var _second_ring := -1.0  ## Tempo até a segunda rajada da fase 2 (-1 = nenhuma).
var _last_player_pos := Vector3.ZERO
var _crown: MeshInstance3D


func _ready() -> void:
	var ring := TorusMesh.new()
	ring.inner_radius = 0.75
	ring.outer_radius = 0.95
	ring.rings = 24
	ring.ring_segments = 6
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 0.55, 0.9)
	ring.material = material
	_crown = MeshInstance3D.new()
	_crown.mesh = ring
	_crown.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_crown.visible = false
	add_child(_crown)


## Cria o chefe em `at` e começa o combate. Retorna o índice dele no EnemyManager.
func spawn(at: Vector3) -> int:
	var index := enemies.spawn_at(at, max_hp, EnemyTypes.CHEFE)
	phase = 1
	_cycle = 0
	_enter(State.PERSEGUIR)
	_crown.visible = true
	_last_player_pos = player.global_position
	if effects:
		effects.burst(at, 0.5, 4.0, 0.8, Color(1.0, 0.4, 0.85, 0.9))
	return index


func is_active() -> bool:
	return state != State.INATIVO


func state_name() -> String:
	return State.keys()[state]


func _process(delta: float) -> void:
	if state == State.INATIVO:
		return
	var index := enemies.boss_index()
	if index == -1:
		stop()
		return
	if player == null or not player.alive:
		return
	var pos := enemies.position_of(index)
	var target := player.global_position
	var player_velocity := (target - _last_player_pos) / maxf(delta, 0.0001)
	_last_player_pos = target
	_crown.global_position = Vector3(pos.x, 2.9, pos.z)
	_crown.rotate_y(delta * (2.0 if phase == 1 else 4.0))
	if phase == 1 and enemies.hp_of(index) <= enemies.max_hp_of(index) * phase_two_ratio:
		_enter_phase_two(pos)
	if _second_ring >= 0.0:
		_second_ring -= delta
		if _second_ring < 0.0:
			_fire_ring(enemies.position_of(index), PI / float(volley_count))
	_time += delta
	var to_player := Vector3(target.x - pos.x, 0.0, target.z - pos.z)
	match state:
		State.PERSEGUIR:
			if to_player.length() > 1.2:
				_move(index, pos, to_player.normalized() * chase_speed * delta)
			if _time >= chase_time * _speed_up():
				_enter(ATTACKS[_cycle % ATTACKS.size()])
				_cycle += 1
		State.PREPARAR_INVESTIDA:
			_tint(Color(1.0, 0.3, 0.3), _time / _windup(charge_windup))
			if _time >= _windup(charge_windup):
				_enter(State.INVESTIDA)
		State.INVESTIDA:
			_update_charge(index, pos, delta)
		State.PREPARAR_ERUPCAO:
			_tint(Color(1.0, 0.55, 0.2), _time / _windup(eruption_windup))
			if _time >= _windup(eruption_windup):
				_erupt()
				_enter(State.RECUPERAR)
		State.PREPARAR_RAJADA:
			_tint(Color(0.9, 0.5, 1.0), _time / _windup(volley_windup))
			if _time >= _windup(volley_windup):
				_fire_ring(pos, 0.0)
				if phase == 2:
					_second_ring = 0.35
				_count_attack("rajada")
				_enter(State.RECUPERAR)
		State.RECUPERAR:
			_tint(Color.WHITE, 0.0)
			if _time >= recover_time * _speed_up():
				_enter(State.PERSEGUIR)
	if state == State.PREPARAR_ERUPCAO and _eruptions.is_empty():
		_plan_eruptions(target, player_velocity)


func _enter(next: State) -> void:
	state = next
	_time = 0.0
	if effects:
		var active := _telegraphs.filter(func(id: int) -> bool: return effects.is_active(id))
		_telegraphs.assign(active)
	var index := enemies.boss_index()
	if index == -1:
		return
	var pos := enemies.position_of(index)
	match next:
		State.PREPARAR_INVESTIDA:
			var to_player := player.global_position - pos
			to_player.y = 0.0
			_charge_direction = to_player.normalized() if to_player.length() > 0.1 else Vector3.FORWARD
			if effects:
				_telegraphs.append(
					effects.warn_strip(
						pos,
						_charge_direction,
						charge_length + 1.0,
						charge_width,
						_windup(charge_windup),
						DANGER
					)
				)
		State.INVESTIDA:
			_charge_travelled = 0.0
			_charge_hit = false
			_count_attack("investida")
		State.PREPARAR_ERUPCAO:
			_eruptions.clear()


func _update_charge(index: int, pos: Vector3, delta: float) -> void:
	var step := minf(charge_speed * delta, charge_length - _charge_travelled)
	_move(index, pos, _charge_direction * step)
	_charge_travelled += step
	var now := enemies.position_of(index)
	var reach := enemies.body_radius(index) + 0.5
	var p := player.global_position
	if not _charge_hit and Vector2(p.x - now.x, p.z - now.z).length() < reach:
		if not player.is_invulnerable():
			_charge_hit = true
			player.take_damage(charge_damage, EnemyTypes.display_name(EnemyTypes.CHEFE))
	if _charge_travelled >= charge_length - 0.001:
		_enter(State.RECUPERAR)


## Erupções: uma onde o jogador está, uma onde ele vai estar e outras ao redor.
func _plan_eruptions(target: Vector3, player_velocity: Vector3) -> void:
	_eruptions.append(target)
	var ahead := player_velocity
	ahead.y = 0.0
	if ahead.length() > 0.5:
		_eruptions.append(target + ahead.normalized() * 2.6)
	var extra := 2 if phase == 1 else 4
	for k in extra:
		var angle := TAU * float(k) / float(extra) + randf() * 0.6
		_eruptions.append(target + Vector3(cos(angle), 0.0, sin(angle)) * 3.4)
	if effects:
		for point in _eruptions:
			_telegraphs.append(
				effects.warn_disc(point, eruption_radius, _windup(eruption_windup), DANGER)
			)


func _erupt() -> void:
	_count_attack("erupção")
	var p := player.global_position
	var hit := false
	for point in _eruptions:
		if effects:
			effects.burst(point, 0.3, eruption_radius, 0.3, Color(1.0, 0.55, 0.2, 0.9))
		if not hit and Vector2(p.x - point.x, p.z - point.z).length() <= eruption_radius:
			hit = true
	if hit:
		player.take_damage(eruption_damage, EnemyTypes.display_name(EnemyTypes.CHEFE))
	_eruptions.clear()


func _fire_ring(center: Vector3, offset: float) -> void:
	if projectiles == null:
		return
	for k in volley_count:
		var angle := offset + TAU * float(k) / float(volley_count)
		projectiles.fire(
			center,
			Vector3(cos(angle), 0.0, sin(angle)),
			volley_speed,
			volley_damage,
			4.0,
			EnemyTypes.CHEFE
		)


func _enter_phase_two(pos: Vector3) -> void:
	phase = 2
	phase_changed.emit(2)
	if effects:
		effects.burst(pos, 0.5, 5.0, 0.7, Color(1.0, 0.3, 0.6, 0.9))
	for k in reinforcements:
		var angle := TAU * float(k) / float(reinforcements)
		var kind := EnemyTypes.EXPLOSIVO if k % 2 == 0 else EnemyTypes.RAPIDO
		var hp := (
			enemies.base_hp * float(EnemyTypes.STATS[kind].hp) * enemies.time_hp_multiplier()
		)
		enemies.spawn_at(pos + Vector3(cos(angle), 0.0, sin(angle)) * 3.0, hp, kind)


func _move(index: int, pos: Vector3, step: Vector3) -> void:
	enemies.set_position_of(index, pos + step)


func _tint(color: Color, strength: float) -> void:
	enemies.boss_tint = Color(color.r, color.g, color.b, clampf(strength, 0.0, 1.0) * 0.8)


## Na fase 2 os avisos e as pausas ficam 25% mais curtos.
func _windup(seconds: float) -> float:
	return seconds * _speed_up()


func _speed_up() -> float:
	return 0.75 if phase == 2 else 1.0


func _count_attack(attack: String) -> void:
	attack_counts[attack] = attack_counts.get(attack, 0) + 1


## Encerra o comportamento do chefe (morte ou fim da partida).
func stop() -> void:
	state = State.INATIVO
	_crown.visible = false
	enemies.boss_tint = Color(0, 0, 0, 0)
	_second_ring = -1.0
	if effects:
		for id in _telegraphs:
			effects.cancel(id)
	_telegraphs.clear()
