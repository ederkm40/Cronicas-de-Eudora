class_name BlobShadow
extends RefCounted
## Sombra simples: um disco escuro e transparente no chão.
## Bem mais barata que sombra em tempo real, o que importa no celular.

static var _material: StandardMaterial3D


static func create(radius: float) -> MeshInstance3D:
	if _material == null:
		_material = StandardMaterial3D.new()
		_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_material.albedo_color = Color(0.0, 0.0, 0.0, 0.35)
	var disc := CylinderMesh.new()
	disc.top_radius = radius
	disc.bottom_radius = radius
	disc.height = 0.01
	disc.radial_segments = 24
	disc.rings = 1
	var shadow := MeshInstance3D.new()
	shadow.mesh = disc
	shadow.material_override = _material
	shadow.position.y = 0.01
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return shadow
