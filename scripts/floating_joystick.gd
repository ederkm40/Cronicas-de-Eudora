class_name FloatingJoystick
extends Control
## Joystick flutuante: nasce onde o dedo toca e some quando o dedo solta.
## Ocupa a tela toda, mas não bloqueia botões (usa _input, não _gui_input).
## A saída fica em `output`: um Vector2 com x para a direita e y para baixo da tela.

@export var radius := 90.0 ## Raio máximo do joystick, em unidades da tela base (720 de largura).
@export_range(0.0, 0.5) var dead_zone := 0.12 ## Fração do raio que é ignorada (evita tremidas).
@export var follow_finger := true ## Se o dedo passa do raio, o centro é arrastado junto.
@export var analog := false ## false = velocidade fixa fora da zona morta; true = proporcional.
@export var base_color := Color(1, 1, 1, 0.14)
@export var ring_color := Color(1, 1, 1, 0.35)
@export var knob_color := Color(1, 1, 1, 0.5)

var output := Vector2.ZERO
var enabled := true

var _touch_index := -1
var _center := Vector2.ZERO
var _knob := Vector2.ZERO


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_enabled(value: bool) -> void:
	enabled = value
	if not enabled:
		_release()


func is_active() -> bool:
	return _touch_index != -1


func _input(event: InputEvent) -> void:
	if not enabled:
		return
	if event is InputEventScreenTouch:
		var touch := make_input_local(event) as InputEventScreenTouch
		if touch.pressed and _touch_index == -1:
			_touch_index = touch.index
			_center = touch.position
			_update(touch.position)
		elif not touch.pressed and touch.index == _touch_index:
			_release()
	elif event is InputEventScreenDrag:
		var drag := make_input_local(event) as InputEventScreenDrag
		if drag.index == _touch_index:
			_update(drag.position)


func _update(finger: Vector2) -> void:
	var offset := finger - _center
	var length := offset.length()
	if length > radius:
		if follow_finger:
			_center = finger - offset / length * radius
		offset = offset / length * radius
		length = radius
	_knob = _center + offset

	var t := length / radius
	if t < dead_zone or length == 0.0:
		output = Vector2.ZERO
	elif analog:
		output = offset / length * inverse_lerp(dead_zone, 1.0, t)
	else:
		output = offset / length
	queue_redraw()


func _release() -> void:
	_touch_index = -1
	output = Vector2.ZERO
	queue_redraw()


func _draw() -> void:
	if _touch_index == -1:
		return
	draw_circle(_center, radius, base_color)
	draw_arc(_center, radius, 0.0, TAU, 48, ring_color, 3.0, true)
	draw_circle(_knob, radius * 0.42, knob_color)
