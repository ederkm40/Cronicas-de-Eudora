class_name EnemyRenderer
extends Node3D
## Desenha todos os inimigos: um MultiMesh por tipo, com cor e tamanho por instância.
## Só cuida do visual. Quem decide posição, tamanho e cor de cada inimigo é o EnemyManager,
## que entrega os arrays prontos uma vez por quadro em `draw()`.

const FLOATS := 16  ## 12 da matriz + 4 da cor, por instância.

var _meshes: Array[MultiMesh] = []
var _buffers: Array[PackedFloat32Array] = []
var _drawn := PackedInt32Array()


## Cria um MultiMesh por tipo. O chefe tem capacidade própria (poucos ao mesmo tempo).
func setup(max_enemies: int, boss_capacity: int) -> void:
	_drawn.resize(EnemyTypes.COUNT)
	for kind in EnemyTypes.COUNT:
		var capacity := boss_capacity if kind == EnemyTypes.CHEFE else max_enemies
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.use_colors = true
		multimesh.mesh = make_mesh(kind)
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


## Escreve os `count` primeiros inimigos nos buffers do seu tipo. Elites (`elite` != 0)
## ficam maiores. Os arrays são só lidos, então não são copiados.
func draw(
	count: int,
	positions: PackedVector3Array,
	kinds: PackedByteArray,
	elite: PackedByteArray,
	colors: PackedColorArray
) -> void:
	var counts := PackedInt32Array()
	counts.resize(EnemyTypes.COUNT)
	for i in count:
		var kind := kinds[i]
		var b := counts[kind] * FLOATS
		var buffer := _buffers[kind]
		if b >= buffer.size():
			continue
		var pos := positions[i]
		var color := colors[i]
		var size := EnemyTypes.ELITE_SCALE if elite[i] != 0 else 1.0
		buffer[b + 0] = size
		buffer[b + 5] = size
		buffer[b + 10] = size
		buffer[b + 3] = pos.x
		buffer[b + 7] = pos.y + float(EnemyTypes.STATS[kind].height) * size
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


## Quantas instâncias de um tipo foram desenhadas no último quadro.
func drawn_of_kind(kind: int) -> int:
	return _drawn[kind]


## Formas provisórias, uma por tipo, para cada inimigo ser reconhecido de longe.
static func make_mesh(kind: int) -> Mesh:
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
		EnemyTypes.TECELAO:
			var pillar := CylinderMesh.new()
			pillar.top_radius = 0.12
			pillar.bottom_radius = 0.38
			pillar.height = 1.5
			pillar.radial_segments = 8
			mesh = pillar
		EnemyTypes.SEMEADOR:
			var mound := SphereMesh.new()
			mound.radius = 0.5
			mound.height = 0.6
			mound.radial_segments = 10
			mound.rings = 4
			mesh = mound
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
