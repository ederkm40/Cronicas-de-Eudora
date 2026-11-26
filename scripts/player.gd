class_name Player
extends Node3D
## Personagem controlado pelo joystick flutuante (ou WASD/setas no computador).
## Arte provisória: cápsula azul com um "nariz" mostrando para onde olha.

signal died

@export var move_speed := 5.0
@export var max_hp := 100.0
@export var hit_flash_time := 0.12

var hp := 100.0
var alive := true
var joystick: FloatingJoystick
var camera_rig: CameraRig

var _material: StandardMaterial3D
var _flash := 0.0
const BODY_COLOR := Color(0.35, 0.65, 1.0)
const FLASH_COLOR := Color(1.0, 1.0, 1.0)


func _ready() -> void:
	hp = max_hp
	_material = StandardMaterial3D.new()
	_material.albedo_color = BODY_COLOR

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
	if _flash > 0.0:
		_flash -= delta
		if _flash <= 0.0:
			_material.albedo_color = BODY_COLOR
	if not alive:
		return

	var input := _read_input()
	if input == Vector2.ZERO or camera_rig == null:
		return
	var direction := camera_rig.screen_to_ground(input)
	global_position += direction * move_speed * delta
	look_at(global_position + direction.normalized(), Vector3.UP)


func _read_input() -> Vector2:
	var keys := Vector2(
		float(_pressed(KEY_D) or _pressed(KEY_RIGHT)) - float(_pressed(KEY_A) or _pressed(KEY_LEFT)),
		float(_pressed(KEY_S) or _pressed(KEY_DOWN)) - float(_pressed(KEY_W) or _pressed(KEY_UP))
	)
	if keys != Vector2.ZERO:
		return keys.normalized()
	if joystick:
		return joystick.output
	return Vector2.ZERO


func _pressed(key: Key) -> bool:
	return Input.is_physical_key_pressed(key)


func take_damage(amount: float) -> void:
	if not alive or amount <= 0.0:
		return
	hp = maxf(hp - amount, 0.0)
	_flash = hit_flash_time
	_material.albedo_color = FLASH_COLOR
	if hp <= 0.0:
		alive = false
		died.emit()
