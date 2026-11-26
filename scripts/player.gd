class_name Player
extends Node3D
## Personagem controlado pelo joystick flutuante (ou WASD/setas no computador).
## Arte provisória: cápsula azul com um "nariz" mostrando para onde olha.
##
## Esquiva: um impulso curto e rápido, com um instante de invulnerabilidade e recarga.
## No celular sai do duplo toque no joystick (FloatingJoystick); no computador, da tecla Espaço.

signal died
signal damaged(amount: float, source: String)
signal dodged(direction: Vector3)

const BODY_COLOR := Color(0.35, 0.65, 1.0)
const FLASH_COLOR := Color(1.0, 1.0, 1.0)
const DODGE_COLOR := Color(0.55, 1.0, 1.0, 0.55)

@export var move_speed := 5.0  ## Metros por segundo, sem melhorias.
@export var base_max_hp := 100.0  ## Vida máxima sem melhorias.
@export var hit_flash_time := 0.12
@export_group("Esquiva")
@export var dodge_distance := 4.0  ## Metros percorridos no impulso.
@export var dodge_duration := 0.18  ## Segundos do impulso.
@export var dodge_invulnerability := 0.32  ## Segundos sem levar dano, a partir do início.
@export var dodge_cooldown := 1.4  ## Segundos até poder esquivar de novo.

var max_hp := 100.0  ## Vida máxima atual (base x melhorias).
var hp := 100.0
var alive := true
var speed_multiplier := 1.0  ## Alterado pela melhoria "Passos ligeiros".
var invulnerable := false  ## Só para testes e simulações longas.
var scripted_input := Vector2.ZERO  ## Movimento comandado por testes e simulações (tem prioridade).
var controls_enabled := true  ## Desligado no fim da partida.
var dodges_used := 0
var joystick: FloatingJoystick
var camera_rig: CameraRig
var effects: GroundEffects

var _material: StandardMaterial3D
var _flash := 0.0
var _dodge_time := 0.0  ## Tempo restante do impulso.
var _dodge_direction := Vector3.ZERO
var _iframes := 0.0
var _dodge_cooldown_left := 0.0


func _ready() -> void:
	max_hp = base_max_hp
	hp = max_hp
	_material = StandardMaterial3D.new()
	_material.albedo_color = BODY_COLOR
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.35
	capsule.height = 1.3
	body.mesh = capsule
	body.material_override = _material
	body.position.y = 0.65
	add_child(body)

	var nose := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.18, 0.18, 0.4)
	nose.mesh = box
	nose.material_override = _material
	nose.position = Vector3(0.0, 0.9, -0.4)
	add_child(nose)

	add_child(BlobShadow.create(0.5))


func _process(delta: float) -> void:
	if _dodge_cooldown_left > 0.0:
		_dodge_cooldown_left -= delta
	if _iframes > 0.0:
		_iframes -= delta
		if _iframes <= 0.0:
			_material.albedo_color = BODY_COLOR
	if _flash > 0.0:
		_flash -= delta
		if _flash <= 0.0:
			_material.albedo_color = DODGE_COLOR if _iframes > 0.0 else BODY_COLOR
	if not alive:
		return

	if _dodge_time > 0.0:
		var step := minf(_dodge_time, delta)
		_dodge_time -= delta
		global_position += _dodge_direction * (dodge_distance / dodge_duration) * step
		return
	if not controls_enabled:
		return
	var input := _read_input()
	if input == Vector2.ZERO or camera_rig == null:
		return
	var direction := camera_rig.screen_to_ground(input)
	global_position += direction * effective_speed() * delta
	look_at(global_position + direction.normalized(), Vector3.UP)


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and not key.echo and key.physical_keycode == KEY_SPACE:
		dodge_toward_input()


## Esquiva para onde o jogador está indo; parado, para a frente do personagem.
func dodge_toward_input() -> bool:
	var input := _read_input()
	if input != Vector2.ZERO and camera_rig:
		return request_dodge(camera_rig.screen_to_ground(input))
	return request_dodge(facing())


## Esquiva numa direção da tela (vinda do gesto). Vector2.ZERO = direção atual.
func dodge_from_screen(screen_direction: Vector2) -> bool:
	if screen_direction == Vector2.ZERO or camera_rig == null:
		return dodge_toward_input()
	return request_dodge(camera_rig.screen_to_ground(screen_direction))


## Começa uma esquiva. Retorna false se não for possível agora (recarga, morto, fim de partida).
func request_dodge(direction: Vector3) -> bool:
	direction.y = 0.0
	if not alive or not controls_enabled or not dodge_ready() or direction.length() < 0.01:
		return false
	_dodge_direction = direction.normalized()
	_dodge_time = dodge_duration
	_iframes = dodge_invulnerability
	_dodge_cooldown_left = dodge_cooldown
	dodges_used += 1
	_material.albedo_color = DODGE_COLOR
	look_at(global_position + _dodge_direction, Vector3.UP)
	if effects:
		effects.burst(global_position, 0.3, 1.3, 0.3, Color(0.5, 1.0, 1.0, 0.8))
	dodged.emit(_dodge_direction)
	return true


func dodge_ready() -> bool:
	return _dodge_cooldown_left <= 0.0


## 1 = pronta; 0 = acabou de ser usada.
func dodge_charge() -> float:
	return 1.0 - clampf(_dodge_cooldown_left / dodge_cooldown, 0.0, 1.0)


func is_dodging() -> bool:
	return _dodge_time > 0.0


## Sem levar dano: durante a esquiva ou pelo gancho de testes.
func is_invulnerable() -> bool:
	return invulnerable or _iframes > 0.0


func facing() -> Vector3:
	var forward := -global_transform.basis.z
	forward.y = 0.0
	return forward.normalized() if forward.length() > 0.01 else Vector3.FORWARD


func effective_speed() -> float:
	return move_speed * speed_multiplier


## Muda a vida máxima sem mexer na vida atual (a cura vem separada, quando houver).
func set_max_hp_multiplier(multiplier: float) -> void:
	max_hp = base_max_hp * multiplier
	hp = minf(hp, max_hp)


func heal(amount: float) -> void:
	if alive and amount > 0.0:
		hp = minf(hp + amount, max_hp)


func _read_input() -> Vector2:
	if scripted_input != Vector2.ZERO:
		return scripted_input.limit_length(1.0)
	var keys := Vector2(
		(
			float(_pressed(KEY_D) or _pressed(KEY_RIGHT))
			- float(_pressed(KEY_A) or _pressed(KEY_LEFT))
		),
		float(_pressed(KEY_S) or _pressed(KEY_DOWN)) - float(_pressed(KEY_W) or _pressed(KEY_UP))
	)
	if keys != Vector2.ZERO:
		return keys.normalized()
	if joystick:
		return joystick.output
	return Vector2.ZERO


func _pressed(key: Key) -> bool:
	return Input.is_physical_key_pressed(key)


func take_damage(amount: float, source: String = "") -> void:
	if not alive or is_invulnerable() or amount <= 0.0:
		return
	var dealt := minf(amount, hp)
	hp = maxf(hp - amount, 0.0)
	damaged.emit(dealt, source)
	_flash = hit_flash_time
	_material.albedo_color = FLASH_COLOR
	if hp <= 0.0:
		alive = false
		died.emit()
