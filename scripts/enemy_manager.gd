class_name EnemyManager
extends Node3D
## Controla todos os inimigos de uma vez, sem um nó por inimigo.
## Os dados ficam em arrays paralelos e o desenho sai de um MultiMesh por tipo de inimigo.
## Assim dá para ter centenas de inimigos na tela no celular.
##
## Tipos (ver EnemyTypes): Errante (comum), Espreitador (rápido), Couraçado (resistente),
## Lançador (atirador), Volátil (explosivo) e o chefe, Sentinela do Eco. O comportamento
## de cada tipo fica em _move(). O chefe só é movido pelo BossController.
##
## Índices mudam quando um inimigo morre (o último ocupa o lugar dele). Por isso nenhum
## sistema guarda índices de um quadro para o outro: quem precisa de memória por inimigo
## usa os arrays daqui (como a recarga da lâmina) ou o id estável (`id_of`).

signal enemy_killed(position: Vector3, kind: int, xp: int)
signal enemy_exploded(position: Vector3)
signal boss_died(position: Vector3)

const CELL := 1.5
const INDEX_BITS := 16
const INDEX_MASK := (1 << INDEX_BITS) - 1
const CELL_OFFSET := 1 << 20  ## Deixa as coordenadas de célula sempre positivas.
const FLOATS := 16  ## 12 da matriz + 4 da cor, por instância.
const FLASH_TIME := 0.1
const BOSS_CAPACITY := 2
## Raio do inimigo comum: o alcance dos acertos é medido a partir dele.
const BASE_BODY_RADIUS := 0.32
const NORMAL := 0
const ACTIVE := 1  ## Lançador preparando o disparo ou Volátil com o pavio aceso.

@export var max_enemies := 300
@export var base_speed := 2.2  ## Velocidade do comum. Os outros tipos escalam a partir dela.
@export var base_hp := 20.0
@export var hp_growth_per_minute := 0.35  ## +35% de vida por minuto de partida.
@export var contact_radius := 0.8  ## Para o inimigo comum; tipos maiores alcançam um pouco mais.
@export var max_contact_hitters := 5  ## No máximo 5 inimigos causam dano ao mesmo tempo.
@export var separation_radius := 0.75
@export var separation_strength := 4.0
@export var spawn_interval_start := 1.0
@export var spawn_interval_min := 0.12
@export var spawn_margin := 2.5  ## Distância extra fora da tela onde os inimigos nascem.
@export var batch_growth_seconds := 30.0  ## A cada N segundos, +1 inimigo por leva.
@export_group("Lançador")
@export var shooter_min_distance := 6.0
@export var shooter_max_distance := 8.5
@export var shooter_interval := 3.2
@export var shooter_windup := 0.55  ## Tempo parado e brilhando antes de disparar (aviso).
@export var shooter_projectile_speed := 6.5
@export var shooter_projectile_damage := 8.0
@export_group("Volátil")
@export var exploder_trigger_distance := 1.9
@export var exploder_fuse := 0.85  ## Tempo entre o aviso e a explosão.
@export var exploder_radius := 2.4
@export var exploder_damage := 26.0

var player: Player
var camera_rig: CameraRig
var projectiles: EnemyProjectiles
var effects: GroundEffects
var stats: RunStats
var elapsed := 0.0
var spawning_enabled := true  ## Desligado pelos testes para controlar os inimigos um a um.
var spawn_rate_multiplier := 1.0  ## Menor que 1 = hordas mais lentas (usado no encontro final).
var boss_tint := Color(0, 0, 0, 0)  ## Brilho do chefe nos avisos de ataque (a = intensidade).
var count: int:
	get:
		return _positions.size()

var _positions := PackedVector3Array()
var _hp := PackedFloat32Array()
var _max_hp := PackedFloat32Array()
var _speed := PackedFloat32Array()
var _push := PackedVector3Array()  ## Empurrão de separação calculado no último quadro.
var _kind := PackedByteArray()
var _state := PackedByteArray()
var _timer := PackedFloat32Array()  ## Lançador: recarga ou preparo. Volátil: pavio.
var _blade_cd := PackedFloat32Array()  ## Tempo até a lâmina orbital poder acertar de novo.
var _flash := PackedFloat32Array()
var _fx := PackedInt32Array()  ## Aviso no chão ligado ao inimigo (0 = nenhum).
var _ids := PackedInt32Array()
var _next_id := 1
var _boss_index := -1
var _spawn_timer := 0.0
var _frame := 0
var _last_player_pos := Vector3.ZERO
var _player_velocity := Vector3.ZERO
var _meshes: Array[MultiMesh] = []
var _buffers: Array[PackedFloat32Array] = []
var _drawn := PackedInt32Array()
## (célula << 16) | índice, ordenado: inimigos agrupados por célula.
var _sorted := PackedInt64Array()
var _cell_start := {}  ## célula -> posição em _sorted onde ela começa.


func _ready() -> void:
	_drawn.resize(EnemyTypes.COUNT)
	for kind in EnemyTypes.COUNT:
		var capacity := BOSS_CAPACITY if kind == EnemyTypes.CHEFE else max_enemies
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.use_colors = true
		multimesh.mesh = _make_mesh(kind)
		multimesh.instance_count = capacity
		multimesh.visible_instance_count = 0
		var buffer := PackedFloat32Array()
		buffer.resize(capacity * FLOATS)
		for i in capacity:
			buffer[i * FLOATS + 0] = 1.0
			buffer[i * FLOATS + 5] = 1.0
			buffer[i * FLOATS + 10] = 1.0
		_meshes.append(multimesh)
		_buffers.append(buffer)
		var instance := MultiMeshInstance3D.new()
		instance.multimesh = multimesh
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.custom_aabb = AABB(Vector3(-5000, -10, -5000), Vector3(10000, 20, 10000))
		add_child(instance)
	if player:
		_last_player_pos = player.global_position


## Formas provisórias, uma por tipo, para cada inimigo ser reconhecido de longe.
func _make_mesh(kind: int) -> Mesh:
	var mesh: PrimitiveMesh
	match kind:
		EnemyTypes.RAPIDO:
			var capsule := CapsuleMesh.new()
			capsule.radius = 0.26
			capsule.height = 0.84
			capsule.radial_segments = 10
			capsule.rings = 2
			mesh = capsule
		EnemyTypes.RESISTENTE:
			var box := BoxMesh.new()
			box.size = Vector3(0.95, 1.1, 0.95)
			mesh = box
		EnemyTypes.ATIRADOR:
			var prism := PrismMesh.new()
			prism.size = Vector3(0.7, 1.2, 0.7)
			mesh = prism
		EnemyTypes.EXPLOSIVO:
			var sphere := SphereMesh.new()
			sphere.radius = 0.42
			sphere.height = 0.84
			sphere.radial_segments = 12
			sphere.rings = 6
			mesh = sphere
		EnemyTypes.CHEFE:
			var body := CylinderMesh.new()
			body.top_radius = 0.55
			body.bottom_radius = 1.0
			body.height = 2.4
			body.radial_segments = 16
			mesh = body
		_:
			var capsule := CapsuleMesh.new()
			capsule.radius = 0.32
			capsule.height = 1.1
			capsule.radial_segments = 12
			capsule.rings = 3
			mesh = capsule
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	mesh.material = material
	return mesh


func _process(delta: float) -> void:
	if player == null or not player.alive:
		return
	elapsed += delta
	if spawning_enabled:
		_spawn(delta)
	_move(delta)
	_draw_instances()


# ---------------------------------------------------------------- nascimento


func time_hp_multiplier() -> float:
	return 1.0 + hp_growth_per_minute * elapsed / 60.0


func _speed_for(kind: int) -> float:
	return float(EnemyTypes.STATS[kind].speed) * base_speed / 2.2


func _spawn(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer > 0.0:
		return
	var interval := maxf(spawn_interval_min, spawn_interval_start - elapsed * 0.012)
	_spawn_timer = interval / maxf(spawn_rate_multiplier, 0.05)
	var batch := 1 + int(elapsed / batch_growth_seconds)
	for i in batch:
		if count >= max_enemies:
			return
		var kind := EnemyTypes.pick(elapsed, randf())
		var hp := base_hp * float(EnemyTypes.STATS[kind].hp) * time_hp_multiplier()
		_append(_random_spawn_point(), kind, hp, _speed_for(kind) * randf_range(0.85, 1.15))


## Cria um inimigo num ponto exato. Usado pelos testes e pelos eventos (chefe, reforços).
## Sem `hp`, usa a vida base do tipo (sem o crescimento por tempo).
func spawn_at(point: Vector3, hp: float = -1.0, kind: int = EnemyTypes.COMUM) -> int:
	if count >= max_enemies and kind != EnemyTypes.CHEFE:
		return -1
	if hp <= 0.0:
		hp = base_hp * float(EnemyTypes.STATS[kind].hp)
	return _append(point, kind, hp, _speed_for(kind))


func _append(point: Vector3, kind: int, hp: float, speed: float) -> int:
	_positions.append(Vector3(point.x, 0.0, point.z))
	_hp.append(hp)
	_max_hp.append(hp)
	_speed.append(speed)
	_push.append(Vector3.ZERO)
	_kind.append(kind)
	_state.append(NORMAL)
	_timer.append(shooter_interval * randf_range(0.4, 1.0) if kind == EnemyTypes.ATIRADOR else 0.0)
	_blade_cd.append(0.0)
	_flash.append(0.0)
	_fx.append(0)
	_ids.append(_next_id)
	_next_id += 1
	if kind == EnemyTypes.CHEFE:
		_boss_index = count - 1
	return count - 1


## Um ponto numa elipse logo fora da área visível, ao redor do jogador.
func _random_spawn_point() -> Vector3:
	var half := camera_rig.visible_ground_half_extent()
	var angle := randf() * TAU
	var point := (
		player.global_position
		+ camera_rig.ground_right() * cos(angle) * (half.x + spawn_margin)
		+ camera_rig.ground_forward() * sin(angle) * (half.y + spawn_margin)
	)
	point.y = 0.0
	return point


# ---------------------------------------------------------------- movimento e ataques


func _move(delta: float) -> void:
	_frame += 1
	_build_grid()
	var target := player.global_position
	if delta > 0.0:
		_player_velocity = (target - _last_player_pos) / delta
		if _player_velocity.length() > 30.0:  # teleporte ou reinício: ignora
			_player_velocity = Vector3.ZERO
	_last_player_pos = target
	var half := camera_rig.visible_ground_half_extent()
	var too_far := (half.y + spawn_margin) * 2.0
	var sep_sq := separation_radius * separation_radius
	var hitters := 0
	var contact_dps := 0.0

	# De trás para a frente: se um Volátil explodir (e sair da lista), o último inimigo
	# ocupa o lugar dele, e esse já foi processado neste quadro.
	var i := count - 1
	while i >= 0:
		var kind := _kind[i]
		if _flash[i] > 0.0:
			_flash[i] -= delta
		if _blade_cd[i] > 0.0:
			_blade_cd[i] -= delta
		var pos := _positions[i]
		var to_player := Vector3(target.x - pos.x, 0.0, target.z - pos.z)
		var dist := to_player.length()
		if dist < _contact_reach(i) and hitters < max_contact_hitters:
			hitters += 1
			contact_dps += float(EnemyTypes.STATS[kind].contact_dps)
		if kind == EnemyTypes.CHEFE:
			i -= 1
			continue
		if dist > too_far:
			_reposition(i)
			i -= 1
			continue

		# A separação é recalculada para metade dos inimigos a cada quadro (alternando).
		# A outra metade reaproveita o empurrão anterior: quase não se nota e corta o custo.
		if (i + _frame) % 2 == 0:
			_push[i] = _separation(i, pos, sep_sq)
		var weight := 0.3 if kind == EnemyTypes.RESISTENTE else 1.0
		var velocity := _push[i] * separation_strength * weight
		var dir := to_player / dist if dist > 0.05 else Vector3.ZERO
		match kind:
			EnemyTypes.RAPIDO:
				velocity += _rapid_velocity(i, pos, target, dist)
			EnemyTypes.ATIRADOR:
				velocity += _shooter_velocity(i, pos, dir, dist, half, delta)
			EnemyTypes.EXPLOSIVO:
				if _exploder_tick(i, pos, dist, delta):
					i -= 1
					continue
				if _state[i] == NORMAL:
					velocity += dir * _speed[i]
				else:
					velocity = Vector3.ZERO  # pavio aceso: para e incha
			_:
				velocity += dir * _speed[i]
		_positions[i] = pos + velocity * delta
		i -= 1

	if hitters > 0:
		player.take_damage(contact_dps * delta, "Contato")


func _reposition(i: int) -> void:
	_positions[i] = _random_spawn_point()
	_state[i] = NORMAL
	if _fx[i] != 0 and effects:
		effects.cancel(_fx[i])
	_fx[i] = 0
	if _kind[i] == EnemyTypes.ATIRADOR:
		_timer[i] = shooter_interval * randf_range(0.4, 1.0)


## Espreitador: mira um pouco à frente do jogador e acelera quando chega perto.
func _rapid_velocity(i: int, pos: Vector3, target: Vector3, dist: float) -> Vector3:
	var lead := minf(dist / maxf(_speed[i], 0.1), 0.6)
	var aim := target + _player_velocity * lead - pos
	aim.y = 0.0
	if aim.length_squared() < 0.0025:
		return Vector3.ZERO
	var boost := 1.3 if dist < 4.0 else 1.0
	return aim.normalized() * _speed[i] * boost


## Lançador: fica entre 6 e 8,5 m, anda de lado e para para atirar (com aviso).
## Só atira dentro da tela, para nunca acertar o jogador de um lugar que ele não vê.
func _shooter_velocity(
	i: int, pos: Vector3, dir: Vector3, dist: float, half: Vector2, delta: float
) -> Vector3:
	if _state[i] == ACTIVE:
		_timer[i] -= delta
		if _timer[i] <= 0.0:
			_state[i] = NORMAL
			_timer[i] = shooter_interval * randf_range(0.85, 1.15)
			if projectiles:
				projectiles.fire(
					pos,
					dir,
					shooter_projectile_speed,
					shooter_projectile_damage,
					3.5,
					EnemyTypes.ATIRADOR
				)
		return Vector3.ZERO
	var on_screen := is_on_screen(pos, half, 0.6)
	if on_screen and dist < shooter_max_distance + 2.5:
		_timer[i] -= delta
		if _timer[i] <= 0.0:
			_state[i] = ACTIVE
			_timer[i] = shooter_windup
			return Vector3.ZERO
	if dist > shooter_max_distance or not on_screen:
		return dir * _speed[i]
	if dist < shooter_min_distance:
		return -dir * _speed[i]
	var side := 1.0 if _ids[i] % 2 == 0 else -1.0
	return Vector3(-dir.z, 0.0, dir.x) * side * _speed[i] * 0.5


## Se o ponto está dentro da área visível ao redor do jogador (com uma margem em metros).
func is_on_screen(pos: Vector3, half: Vector2, margin: float) -> bool:
	var rel := pos - player.global_position
	var sx := rel.dot(camera_rig.ground_right())
	var sz := rel.dot(camera_rig.ground_forward())
	return absf(sx) < half.x - margin and absf(sz) < half.y - margin


## Volátil: acende o pavio perto do jogador e explode depois do aviso.
## Retorna true se explodiu (e saiu da lista).
func _exploder_tick(i: int, pos: Vector3, dist: float, delta: float) -> bool:
	if _state[i] == NORMAL:
		if dist < exploder_trigger_distance:
			_state[i] = ACTIVE
			_timer[i] = exploder_fuse
			if effects:
				var warn := Color(1.0, 0.35, 0.1, 0.42)
				_fx[i] = effects.warn_disc(pos, exploder_radius, exploder_fuse, warn)
		return false
	_timer[i] -= delta
	if _timer[i] > 0.0:
		return false
	if dist <= exploder_radius:
		player.take_damage(exploder_damage, "Volátil")
	if effects:
		effects.burst(pos, 0.4, exploder_radius, 0.35, Color(1.0, 0.65, 0.2, 0.9))
	if stats:
		stats.explosions += 1
	_fx[i] = 0
	_remove(i)
	enemy_exploded.emit(pos)
	return true


func _separation(i: int, pos: Vector3, sep_sq: float) -> Vector3:
	var push := Vector3.ZERO
	var cx := floori(pos.x / CELL)
	var cz := floori(pos.z / CELL)
	for x in range(cx - 1, cx + 2):
		for z in range(cz - 1, cz + 2):
			var cell := _cell_key(x, z)
			var k: int = _cell_start.get(cell, -1)
			if k == -1:
				continue
			while k < _sorted.size() and (_sorted[k] >> INDEX_BITS) == cell:
				var j := _sorted[k] & INDEX_MASK
				k += 1
				if j == i or j >= count:
					continue
				var other := _positions[j]
				var away := Vector3(pos.x - other.x, 0.0, pos.z - other.z)
				var d_sq := away.length_squared()
				if d_sq < sep_sq and d_sq > 0.0001:
					var d := sqrt(d_sq)
					push += away / d * (separation_radius - d)
	return push


## Agrupa os inimigos por célula com uma ordenação nativa (rápida), sem criar arrays por célula.
func _build_grid() -> void:
	_sorted.resize(count)
	for i in count:
		var pos := _positions[i]
		_sorted[i] = (_cell_key(floori(pos.x / CELL), floori(pos.z / CELL)) << INDEX_BITS) | i
	_sorted.sort()
	_cell_start.clear()
	var previous := -1
	for k in _sorted.size():
		var cell := _sorted[k] >> INDEX_BITS
		if cell != previous:
			_cell_start[cell] = k
			previous = cell


static func _cell_key(x: int, z: int) -> int:
	return ((x + CELL_OFFSET) << 21) | (z + CELL_OFFSET)


# ---------------------------------------------------------------- desenho


func _draw_instances() -> void:
	var counts := PackedInt32Array()
	counts.resize(EnemyTypes.COUNT)
	for i in count:
		var kind := _kind[i]
		var b := counts[kind] * FLOATS
		var buffer := _buffers[kind]
		if b >= buffer.size():
			continue
		var pos := _positions[i]
		var color := _color_of(i, kind)
		buffer[b + 3] = pos.x
		buffer[b + 7] = pos.y + float(EnemyTypes.STATS[kind].height)
		buffer[b + 11] = pos.z
		buffer[b + 12] = color.r
		buffer[b + 13] = color.g
		buffer[b + 14] = color.b
		buffer[b + 15] = 1.0
		counts[kind] += 1
	for kind in EnemyTypes.COUNT:
		if counts[kind] == 0 and _drawn[kind] == 0:
			continue
		_meshes[kind].buffer = _buffers[kind]
		_meshes[kind].visible_instance_count = counts[kind]
		_drawn[kind] = counts[kind]


## Cor de cada inimigo neste quadro: pisca branco ao levar dano e brilha nos avisos.
func _color_of(i: int, kind: int) -> Color:
	var color: Color = EnemyTypes.STATS[kind].color
	if kind == EnemyTypes.ATIRADOR and _state[i] == ACTIVE:
		color = color.lerp(Color(1.0, 0.85, 1.0), 0.75)
	elif kind == EnemyTypes.EXPLOSIVO and _state[i] == ACTIVE:
		var progress := 1.0 - _timer[i] / exploder_fuse
		var blink := 0.5 + 0.5 * sin(elapsed * lerpf(18.0, 50.0, progress))
		color = color.lerp(Color(1.0, 1.0, 0.85), blink)
	elif kind == EnemyTypes.CHEFE and boss_tint.a > 0.0:
		color = color.lerp(Color(boss_tint.r, boss_tint.g, boss_tint.b), boss_tint.a)
	if _flash[i] > 0.0:
		color = color.lerp(Color.WHITE, 0.7)
	return color


# ---------------------------------------------------------------- consultas e dano


## Índice do inimigo mais próximo dentro do alcance, ou -1.
func nearest(from: Vector3, max_range: float) -> int:
	var best := -1
	var best_sq := max_range * max_range
	for i in count:
		var d_sq := Vector2(_positions[i].x - from.x, _positions[i].z - from.z).length_squared()
		if d_sq < best_sq:
			best_sq = d_sq
			best = i
	return best


## Primeiro inimigo tocando um ponto (para projéteis), ou -1. `radius` vale para o inimigo
## comum; tipos maiores são acertados de um pouco mais longe. Usa a grade do quadro.
func hit_at(point: Vector3, radius: float) -> int:
	if _boss_index != -1:
		var reach := radius + body_radius(_boss_index) - BASE_BODY_RADIUS
		var boss := _positions[_boss_index]
		if Vector2(boss.x - point.x, boss.z - point.z).length_squared() < reach * reach:
			return _boss_index
	var cx := floori(point.x / CELL)
	var cz := floori(point.z / CELL)
	for x in range(cx - 1, cx + 2):
		for z in range(cz - 1, cz + 2):
			var cell := _cell_key(x, z)
			var k: int = _cell_start.get(cell, -1)
			if k == -1:
				continue
			while k < _sorted.size() and (_sorted[k] >> INDEX_BITS) == cell:
				var j := _sorted[k] & INDEX_MASK
				k += 1
				if j >= count or j == _boss_index:
					continue
				var reach := radius + body_radius(j) - BASE_BODY_RADIUS
				var p := _positions[j]
				if Vector2(p.x - point.x, p.z - point.z).length_squared() < reach * reach:
					return j
	return -1


## Todos os inimigos cujo corpo toca o círculo (centro, raio), do maior índice para o menor.
## Nessa ordem dá para aplicar dano em todos: quem morre só troca de lugar com índices maiores.
func indices_in_radius(center: Vector3, radius: float) -> PackedInt32Array:
	var found := PackedInt32Array()
	for i in range(count - 1, -1, -1):
		var reach := radius + body_radius(i)
		var p := _positions[i]
		if Vector2(p.x - center.x, p.z - center.z).length_squared() < reach * reach:
			found.append(i)
	return found


func body_radius(index: int) -> float:
	return float(EnemyTypes.STATS[_kind[index]].radius)


## Distância em que o inimigo encosta no jogador e causa dano de contato.
func _contact_reach(index: int) -> float:
	return contact_radius + body_radius(index) - BASE_BODY_RADIUS


func position_of(index: int) -> Vector3:
	return _positions[index]


func set_position_of(index: int, point: Vector3) -> void:
	_positions[index] = Vector3(point.x, 0.0, point.z)


func hp_of(index: int) -> float:
	return _hp[index]


func max_hp_of(index: int) -> float:
	return _max_hp[index]


func kind_of(index: int) -> int:
	return _kind[index]


func id_of(index: int) -> int:
	return _ids[index]


func state_of(index: int) -> int:
	return _state[index]


func boss_index() -> int:
	return _boss_index


func count_of_kind(kind: int) -> int:
	var total := 0
	for k in _kind:
		if k == kind:
			total += 1
	return total


## A lâmina orbital acerta cada inimigo no máximo uma vez a cada `cooldown` segundos.
## Retorna true (e começa a recarga) se o inimigo pode ser cortado agora.
func try_blade_hit(index: int, cooldown: float) -> bool:
	if _blade_cd[index] > 0.0:
		return false
	_blade_cd[index] = cooldown
	return true


## Aplica dano (já descontada a resistência do tipo). Retorna true se o inimigo morreu.
## `source` é o id da arma, para as estatísticas da partida.
func damage(index: int, amount: float, source: StringName = &"") -> bool:
	if index < 0 or index >= count or amount <= 0.0:
		return false
	var kind := _kind[index]
	var dealt := amount * (1.0 - float(EnemyTypes.STATS[kind].armor))
	if stats:
		stats.record_damage(source, minf(dealt, maxf(_hp[index], 0.0)), kind)
	_hp[index] -= dealt
	_flash[index] = FLASH_TIME
	if _hp[index] > 0.0:
		return false
	var where := _positions[index]
	var xp := int(EnemyTypes.STATS[kind].xp)
	_remove(index)
	if stats:
		stats.record_kill(source, kind)
	if kind == EnemyTypes.CHEFE:
		boss_died.emit(where)
	enemy_killed.emit(where, kind, xp)
	return true


## Remove um inimigo: o último ocupa o lugar dele em todos os arrays.
func _remove(index: int) -> void:
	if _fx[index] != 0 and effects:
		effects.cancel(_fx[index])
	var last := count - 1
	if index == _boss_index:
		_boss_index = -1
	if last == _boss_index:
		_boss_index = index
	_positions[index] = _positions[last]
	_hp[index] = _hp[last]
	_max_hp[index] = _max_hp[last]
	_speed[index] = _speed[last]
	_push[index] = _push[last]
	_kind[index] = _kind[last]
	_state[index] = _state[last]
	_timer[index] = _timer[last]
	_blade_cd[index] = _blade_cd[last]
	_flash[index] = _flash[last]
	_fx[index] = _fx[last]
	_ids[index] = _ids[last]
	_positions.resize(last)
	_hp.resize(last)
	_max_hp.resize(last)
	_speed.resize(last)
	_push.resize(last)
	_kind.resize(last)
	_state.resize(last)
	_timer.resize(last)
	_blade_cd.resize(last)
	_flash.resize(last)
	_fx.resize(last)
	_ids.resize(last)
