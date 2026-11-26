class_name AuraWeapon
extends Node3D
## Aura de brasas: um círculo ao redor do jogador que queima todos os inimigos dentro dele
## a cada pulso (não a cada quadro). Cada pulso é uma onda de brasas que sai do centro
## até a borda, para o jogador ver quando e onde o dano acontece.
## Atributos por nível em WeaponCatalog. As melhorias mexem só nos multiplicadores.

const SHADER_CODE := """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;
uniform vec4 tint : source_color = vec4(1.0, 0.45, 0.12, 1.0);
uniform float pulse = 0.0;
uniform float crown = 0.0;

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float r = length(p);
	if (r > 1.0) {
		discard;
	}
	float angle = atan(p.y, p.x);
	float edge = smoothstep(0.84, 0.95, r) * (1.0 - smoothstep(0.97, 1.0, r));
	float embers = 0.5 + 0.5 * sin(angle * 9.0 + TIME * 2.4) * sin(r * 13.0 - TIME * 3.0);
	float fill = (0.06 + 0.07 * embers) * r;
	float front = 1.0 - pulse;
	float wave = smoothstep(0.14, 0.0, abs(r - front)) * pulse;
	float flames = crown * smoothstep(0.7, 1.0, r) * (0.5 + 0.5 * sin(angle * 14.0 - TIME * 6.0));
	ALBEDO = mix(mix(tint.rgb, vec3(1.0, 0.9, 0.6), wave), vec3(1.0, 0.3, 0.05), flames);
	ALPHA = clamp(edge * 0.7 + fill + wave * 0.65 + flames * 0.35, 0.0, 1.0);
}
"""
const PULSE_SECONDS := 0.3
const EVOLVED_AREA := 1.15
const BURN_SECONDS := 3.0
const BURN_SHARE := 0.4  ## Dano por segundo da queimadura, como fração do dano do pulso.

var player: Player
var enemies: EnemyManager
var level := 0
var damage_multiplier := 1.0
var rate_multiplier := 1.0
var area_multiplier := 1.0
var pulses := 0  ## Pulsos de dano na partida (usado pelos testes).
var evolved := false  ## Coroa de cinzas: pulsos põem fogo e a área cresce 15%.

var _timer := 0.0
var _pulse := 0.0
var _material: ShaderMaterial


func _ready() -> void:
	var shader := Shader.new()
	shader.code = SHADER_CODE
	_material = ShaderMaterial.new()
	_material.shader = shader
	var plane := PlaneMesh.new()
	plane.size = Vector2(2.0, 2.0)
	var mesh := MeshInstance3D.new()
	mesh.mesh = plane
	mesh.material_override = _material
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh)
	visible = level > 0


func set_level(value: int) -> void:
	var was_active := level > 0
	level = clampi(value, 0, WeaponCatalog.max_level(WeaponCatalog.AURA))
	visible = level > 0
	if level > 0 and not was_active:
		_timer = effective_interval() * 0.5


func _base(key: String) -> float:
	return float(WeaponCatalog.stats(WeaponCatalog.AURA, level).get(key, 0.0))


func effective_damage() -> float:
	return _base("damage") * damage_multiplier


func effective_radius() -> float:
	return _base("radius") * area_multiplier * (EVOLVED_AREA if evolved else 1.0)


func effective_interval() -> float:
	return _base("interval") / rate_multiplier


func _process(delta: float) -> void:
	if level == 0 or player == null or not player.alive:
		return
	var p := player.global_position
	global_position = Vector3(p.x, 0.04, p.z)
	var r := effective_radius()
	scale = Vector3(r, 1.0, r)
	_pulse = maxf(_pulse - delta / PULSE_SECONDS, 0.0)
	_material.set_shader_parameter("pulse", _pulse)
	_material.set_shader_parameter("crown", 1.0 if evolved else 0.0)
	_timer -= delta
	if _timer <= 0.0:
		_timer = maxf(_timer + effective_interval(), 0.05)
		_fire()


## Um pulso: dano em todos os inimigos dentro do círculo, de uma vez.
func _fire() -> void:
	pulses += 1
	_pulse = 1.0
	var amount := effective_damage()
	for index in enemies.indices_in_radius(global_position, effective_radius()):
		if evolved:
			enemies.apply_effects(index, amount * BURN_SHARE, BURN_SECONDS, 0.0, Vector3.ZERO)
		enemies.damage(index, amount, WeaponCatalog.AURA)
