class_name FloatingJoystick
extends Control
## Joystick flutuante: nasce onde o dedo toca e some quando o dedo solta.
## Ocupa a tela toda, mas não bloqueia botões (usa _input, não _gui_input).
## A saída fica em `output`: um Vector2 com x para a direita e y para baixo da tela.
##
## Esquiva por duplo toque: um toque curto (tocar e soltar rápido, quase sem arrastar) seguido,
## logo depois e perto dele, de um segundo toque. A direção sai do próprio gesto:
## - se o segundo toque arrasta rápido (um "peteleco"), a esquiva vai para onde ele arrastou;
## - se o segundo toque também é curto, a esquiva vai para onde o personagem está indo.
## Segurar e girar o joystick nunca conta como toque: só toques curtos armam a esquiva.
## Os tempos usam o relógio do jogo (não o do sistema), então valem igual nos testes.
##
## Pausa (level-up): o joystick fica desligado (sem movimento e sem gestos), mas continua
## acompanhando o dedo que já estava nele (process_mode = ALWAYS). Ao religar, se esse dedo
## ainda está na tela, o controle volta na hora, a partir da posição atual do dedo; se ele
## foi levantado durante a pausa, o joystick volta neutro. Toques que começam durante a
## pausa (como o toque no cartão) nunca viram joystick nem esquiva.

signal dodge_requested(screen_direction: Vector2)

@export var radius := 90.0  ## Raio máximo do joystick, em unidades da tela base (720 de largura).
@export_range(0.0, 0.5) var dead_zone := 0.12  ## Fração do raio que é ignorada (evita tremidas).
@export var follow_finger := true  ## Se o dedo passa do raio, o centro é arrastado junto.
@export var analog := false  ## false = velocidade fixa fora da zona morta; true = proporcional.
@export var base_color := Color(1, 1, 1, 0.14)
@export var ring_color := Color(1, 1, 1, 0.35)
@export var knob_color := Color(1, 1, 1, 0.5)
@export_group("Duplo toque (esquiva)")
@export var tap_max_time := 0.22  ## Segundos: um toque mais longo que isso é movimento.
@export var tap_max_move := 28.0  ## Arrasto máximo (unidades da tela) para ainda ser um toque.
@export var double_tap_window := 0.32  ## Segundos entre soltar o 1º toque e tocar o 2º.
@export var double_tap_max_gap := 140.0  ## Distância máxima entre os dois toques.
@export var flick_distance := 40.0  ## Arrasto do 2º toque que define a direção.
@export var flick_time := 0.3  ## Segundos que o 2º toque tem para arrastar.

var output := Vector2.ZERO
var enabled := true
var dodge_gestures := 0  ## Duplos toques reconhecidos (usado pelos testes).

var _touch_index := -1
var _center := Vector2.ZERO
var _knob := Vector2.ZERO
var _clock := 0.0
var _press_time := 0.0
var _press_pos := Vector2.ZERO
var _max_move := 0.0
var _last_tap_end := -100.0
var _last_tap_pos := Vector2.ZERO
var _armed := false  ## Segundo toque de um duplo toque, esperando a direção.
var _finger := Vector2.ZERO  ## Última posição conhecida do dedo do joystick.


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # acompanha o dedo também durante a pausa
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_clock += delta


## Desligar não esquece o dedo que está no joystick: só zera a saída e os gestos.
## Religar retoma esse dedo (se ainda estiver na tela) sem precisar tocar de novo.
func set_enabled(value: bool) -> void:
	enabled = value
	_reset_gestures()
	if enabled and _touch_index != -1:
		_update(_finger)
	else:
		output = Vector2.ZERO
	queue_redraw()


## O toque em andamento deixa de contar como toque curto: soltá-lo não arma esquiva.
func _reset_gestures() -> void:
	_armed = false
	_last_tap_end = -100.0
	_press_time = -100.0


func is_active() -> bool:
	return _touch_index != -1


func _input(event: InputEvent) -> void:
	if not enabled:
		_track_while_disabled(event)
		return
	if event is InputEventScreenTouch:
		var touch := make_input_local(event) as InputEventScreenTouch
		if touch.pressed and _touch_index == -1:
			_touch_index = touch.index
			_center = touch.position
			_finger = touch.position
			_begin_gesture(touch.position)
			_update(touch.position)
		elif not touch.pressed and touch.index == _touch_index:
			_end_gesture()
			_release()
	elif event is InputEventScreenDrag:
		var drag := make_input_local(event) as InputEventScreenDrag
		if drag.index == _touch_index:
			_finger = drag.position
			_track_gesture(drag.position)
			_update(drag.position)


## Desligado: só acompanha o dedo que já estava no joystick (onde está e se foi solto).
func _track_while_disabled(event: InputEvent) -> void:
	if _touch_index == -1:
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if not touch.pressed and touch.index == _touch_index:
			_release()
	elif event is InputEventScreenDrag:
		var drag := make_input_local(event) as InputEventScreenDrag
		if drag.index == _touch_index:
			_finger = drag.position


func _begin_gesture(where: Vector2) -> void:
	_armed = (
		_clock - _last_tap_end <= double_tap_window
		and where.distance_to(_last_tap_pos) <= double_tap_max_gap
	)
	_last_tap_end = -100.0  # um toque só arma uma esquiva
	_press_time = _clock
	_press_pos = where
	_max_move = 0.0


func _track_gesture(where: Vector2) -> void:
	var offset := where - _press_pos
	_max_move = maxf(_max_move, offset.length())
	if not _armed:
		return
	if _clock - _press_time > flick_time:
		_armed = false  # arrastou devagar: é só movimento
	elif offset.length() >= flick_distance:
		_armed = false
		_emit_dodge(offset.normalized())


func _end_gesture() -> void:
	var short := _clock - _press_time <= tap_max_time and _max_move < tap_max_move
	if _armed and short:
		_emit_dodge(Vector2.ZERO)
	elif short and not _armed:
		_last_tap_end = _clock
		_last_tap_pos = _press_pos
	_armed = false


func _emit_dodge(direction: Vector2) -> void:
	dodge_gestures += 1
	dodge_requested.emit(direction)


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
	if _touch_index == -1 or not enabled:
		return
	draw_circle(_center, radius, base_color)
	draw_arc(_center, radius, 0.0, TAU, 48, ring_color, 3.0, true)
	draw_circle(_knob, radius * 0.42, knob_color)
