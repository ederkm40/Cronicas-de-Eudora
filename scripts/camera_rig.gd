class_name CameraRig
extends Node3D
## Câmera isométrica fixa (ortográfica) que segue um alvo.
## O giro e a inclinação ficam no próprio rig; a câmera fica afastada no eixo Z local.

@export var yaw_degrees := 45.0 ## Giro horizontal (45 = isométrico clássico).
## Inclinação para baixo. Em retrato, um pouco acima de 35 mostra menos "profundidade".
@export var pitch_degrees := 40.0
@export var view_width := 14.0 ## Largura visível do mundo, em metros. Menor = mais zoom.
@export var distance := 30.0
@export var follow_speed := 10.0

var target: Node3D
var camera: Camera3D


func _ready() -> void:
	rotation_degrees = Vector3(-pitch_degrees, yaw_degrees, 0.0)
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	camera.size = view_width
	camera.near = 0.1
	camera.far = 150.0
	camera.position = Vector3(0.0, 0.0, distance)
	add_child(camera)
	camera.current = true


func snap_to_target() -> void:
	if target:
		global_position = target.global_position


func _process(delta: float) -> void:
	if target:
		var weight := 1.0 - exp(-follow_speed * delta)
		global_position = global_position.lerp(target.global_position, weight)


## Direção "direita da tela" projetada no chão.
func ground_right() -> Vector3:
	var right := global_transform.basis.x
	right.y = 0.0
	return right.normalized()


## Direção "cima da tela" projetada no chão.
func ground_forward() -> Vector3:
	var forward := -global_transform.basis.z
	forward.y = 0.0
	return forward.normalized()


## Converte um vetor da tela (x direita, y para baixo) numa direção no chão.
func screen_to_ground(screen_dir: Vector2) -> Vector3:
	return ground_right() * screen_dir.x + ground_forward() * -screen_dir.y


## Metade da área visível do chão: x = largura, y = profundidade (em metros).
func visible_ground_half_extent() -> Vector2:
	var viewport_size := get_viewport().get_visible_rect().size
	var view_height := view_width * viewport_size.y / maxf(viewport_size.x, 1.0)
	var depth := view_height / maxf(sin(deg_to_rad(pitch_degrees)), 0.1)
	return Vector2(view_width * 0.5, depth * 0.5)
