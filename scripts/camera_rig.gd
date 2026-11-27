class_name CameraRig
extends Node3D
## Câmera isométrica fixa (ortográfica) que segue um alvo.
## O giro e a inclinação ficam no próprio rig; a câmera fica afastada no eixo Z local.

@export var yaw_degrees := 45.0  ## Giro horizontal (45 = isométrico clássico).
## Inclinação para baixo. Em retrato, um pouco acima de 35 mostra menos "profundidade".
@export var pitch_degrees := 40.0
@export var view_width := 14.0  ## Largura visível do mundo, em metros. Menor = mais zoom.
@export var distance := 30.0
@export var follow_speed := 10.0
## Na tela deitada, a câmera passa a manter a altura visível (em metros de tela), para não
## mostrar só uma faixa fina do mapa. Em pé, mantém a largura (`view_width`).
@export var landscape_view_height := 11.0

var target: Node3D
var camera: Camera3D
var shake_enabled := true  ## Configuração "Tremor de tela".

var _shake := 0.0
var _shake_strength := 0.0


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
	_fit_aspect()
	if target:
		var weight := 1.0 - exp(-follow_speed * delta)
		global_position = global_position.lerp(target.global_position, weight)
	if _shake > 0.0:
		_shake -= delta
		var amount := _shake_strength * clampf(_shake / 0.3, 0.0, 1.0)
		camera.h_offset = randf_range(-amount, amount)
		camera.v_offset = randf_range(-amount, amount)
	elif camera.h_offset != 0.0 or camera.v_offset != 0.0:
		camera.h_offset = 0.0
		camera.v_offset = 0.0


## Tremor curto de câmera (impactos fortes). Desligável nas configurações.
func shake(strength: float, seconds: float) -> void:
	if not shake_enabled:
		return
	if _shake <= 0.0:
		_shake_strength = 0.0
	_shake_strength = maxf(_shake_strength, strength)
	_shake = maxf(_shake, seconds)


func is_landscape() -> bool:
	var size := get_viewport().get_visible_rect().size
	return size.x > size.y


func _fit_aspect() -> void:
	if camera == null:
		return
	if is_landscape():
		camera.keep_aspect = Camera3D.KEEP_HEIGHT
		camera.size = landscape_view_height
	else:
		camera.keep_aspect = Camera3D.KEEP_WIDTH
		camera.size = view_width


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


## Se `pos` está dentro da área visível ao redor de `center` (com uma margem em metros).
## `half` vem de `visible_ground_half_extent()`.
func is_on_screen(pos: Vector3, center: Vector3, half: Vector2, margin: float) -> bool:
	var rel := pos - center
	var sx := rel.dot(ground_right())
	var sz := rel.dot(ground_forward())
	return absf(sx) < half.x - margin and absf(sz) < half.y - margin


## Metade da área visível do chão: x = largura, y = profundidade (em metros).
func visible_ground_half_extent() -> Vector2:
	var viewport_size := get_viewport().get_visible_rect().size
	var width := view_width
	var view_height := view_width * viewport_size.y / maxf(viewport_size.x, 1.0)
	if viewport_size.x > viewport_size.y:
		view_height = landscape_view_height
		width = landscape_view_height * viewport_size.x / maxf(viewport_size.y, 1.0)
	var depth := view_height / maxf(sin(deg_to_rad(pitch_degrees)), 0.1)
	return Vector2(width * 0.5, depth * 0.5)
