class_name GroundEffects
extends Node3D
## Efeitos desenhados no chão: avisos de ataque (área que vai ser atingida) e anéis de impacto.
## Mesmo esquema dos inimigos: dados em arrays e um MultiMesh por forma (disco, anel e faixa).
## O número de efeitos tem limite: quando enche, o mais antigo é substituído.
##
## Formas:
## - DISCO: área cheia, usada nos avisos (fica mais forte até o golpe chegar).
## - ANEL: anel que cresce e some, usado em impactos, explosões e na esquiva.
## - FAIXA: retângulo no chão, usado no aviso da investida do chefe.

enum { DISCO, ANEL, FAIXA }

const SHAPES := 3
const FLOATS := 16  ## 12 da matriz + 4 da cor, por instância.

@export var max_effects := 160

var count: int:
	get:
		return _shape.size()

var _shape := PackedByteArray()
var _pos := PackedVector3Array()
var _size := PackedVector2Array()  ## DISCO/ANEL: (raio inicial, raio final). FAIXA: (comprimento, largura).
var _angle := PackedFloat32Array()
var _color := PackedColorArray()
var _time := PackedFloat32Array()
var _duration := PackedFloat32Array()
var _ids := PackedInt32Array()
var _next_id := 1
var _meshes: Array[MultiMesh] = []
var _buffers: Array[PackedFloat32Array] = []


func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.no_depth_test = false

	var disc := CylinderMesh.new()
	disc.top_radius = 1.0
	disc.bottom_radius = 1.0
	disc.height = 0.01
	disc.radial_segments = 32
	disc.rings = 1
	var ring := TorusMesh.new()
	ring.inner_radius = 0.86
	ring.outer_radius = 1.0
	ring.rings = 32
	ring.ring_segments = 3
	var strip := BoxMesh.new()
	strip.size = Vector3(1.0, 0.01, 1.0)
	for mesh: Mesh in [disc, ring, strip]:
		mesh.surface_set_material(0, material)
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.use_colors = true
		multimesh.mesh = mesh
		multimesh.instance_count = max_effects
		multimesh.visible_instance_count = 0
		var instance := MultiMeshInstance3D.new()
		instance.multimesh = multimesh
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		instance.custom_aabb = AABB(Vector3(-5000, -10, -5000), Vector3(10000, 20, 10000))
		add_child(instance)
		_meshes.append(multimesh)
		var buffer := PackedFloat32Array()
		buffer.resize(max_effects * FLOATS)
		_buffers.append(buffer)


## Aviso de área: disco que fica mais forte até `duration` acabar. Retorna um id para cancelar.
func warn_disc(center: Vector3, radius: float, duration: float, color: Color) -> int:
	return _add(DISCO, center, Vector2(radius, radius), 0.0, color, duration)


## Aviso em faixa: começa em `start`, aponta para `direction` e tem `length` metros.
func warn_strip(
	start: Vector3, direction: Vector3, length: float, width: float, duration: float, color: Color
) -> int:
	var center := start + direction.normalized() * length * 0.5
	var angle := atan2(direction.x, direction.z)
	return _add(FAIXA, center, Vector2(length, width), angle, color, duration)


## Anel que cresce de `from_radius` até `to_radius` e some.
func burst(center: Vector3, from_radius: float, to_radius: float, duration: float, color: Color) -> int:
	return _add(ANEL, center, Vector2(from_radius, to_radius), 0.0, color, duration)


func cancel(id: int) -> void:
	var index := _ids.find(id)
	if index != -1:
		_remove(index)


func is_active(id: int) -> bool:
	return _ids.has(id)


func clear() -> void:
	for array in [_shape, _pos, _size, _angle, _color, _time, _duration, _ids]:
		array.resize(0)


func _add(
	shape: int, center: Vector3, size: Vector2, angle: float, color: Color, duration: float
) -> int:
	if count >= max_effects:
		_remove(0)
	_shape.append(shape)
	_pos.append(Vector3(center.x, 0.03 + 0.005 * float(shape), center.z))
	_size.append(size)
	_angle.append(angle)
	_color.append(color)
	_time.append(0.0)
	_duration.append(maxf(duration, 0.01))
	_ids.append(_next_id)
	_next_id += 1
	return _next_id - 1


func _remove(index: int) -> void:
	var last := count - 1
	_shape[index] = _shape[last]
	_pos[index] = _pos[last]
	_size[index] = _size[last]
	_angle[index] = _angle[last]
	_color[index] = _color[last]
	_time[index] = _time[last]
	_duration[index] = _duration[last]
	_ids[index] = _ids[last]
	for array in [_shape, _pos, _size, _angle, _color, _time, _duration, _ids]:
		array.resize(last)


func _process(delta: float) -> void:
	var i := count - 1
	while i >= 0:
		_time[i] += delta
		if _time[i] >= _duration[i]:
			_remove(i)
		i -= 1
	_draw()


func _draw() -> void:
	for shape in SHAPES:
		# Tira o buffer do array antes de escrever: assim o Godot não copia o buffer inteiro.
		var buffer := _buffers[shape]
		_buffers[shape] = PackedFloat32Array()
		var n := 0
		for i in count:
			if _shape[i] == shape:
				_write(buffer, n * FLOATS, i)
				n += 1
		_buffers[shape] = buffer
		_meshes[shape].buffer = buffer
		_meshes[shape].visible_instance_count = n


func _write(buffer: PackedFloat32Array, b: int, i: int) -> void:
	var t := _time[i] / _duration[i]
	var color := _color[i]
	var basis := Basis.IDENTITY
	match _shape[i]:
		DISCO:
			# Fica mais forte perto do golpe.
			color.a *= lerpf(0.35, 1.0, t)
			basis = Basis.from_scale(Vector3(_size[i].x, 1.0, _size[i].x))
		ANEL:
			color.a *= 1.0 - t
			var r := lerpf(_size[i].x, _size[i].y, ease(t, 0.5))
			basis = Basis.from_scale(Vector3(r, 0.05, r))
		FAIXA:
			color.a *= lerpf(0.35, 1.0, t)
			var scale := Basis.from_scale(Vector3(_size[i].y, 1.0, _size[i].x))
			basis = Basis(Vector3.UP, _angle[i]) * scale
	var p := _pos[i]
	buffer[b + 0] = basis.x.x
	buffer[b + 1] = basis.y.x
	buffer[b + 2] = basis.z.x
	buffer[b + 3] = p.x
	buffer[b + 4] = basis.x.y
	buffer[b + 5] = basis.y.y
	buffer[b + 6] = basis.z.y
	buffer[b + 7] = p.y
	buffer[b + 8] = basis.x.z
	buffer[b + 9] = basis.y.z
	buffer[b + 10] = basis.z.z
	buffer[b + 11] = p.z
	buffer[b + 12] = color.r
	buffer[b + 13] = color.g
	buffer[b + 14] = color.b
	buffer[b + 15] = color.a
