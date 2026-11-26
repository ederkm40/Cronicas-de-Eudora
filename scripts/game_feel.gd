class_name GameFeel
extends Node
## Liga os acontecimentos do jogo às respostas de som e imagem, num lugar só:
## sons (SoundBank), tremor de câmera, números de dano (CombatFeedback) e o "estouro" no
## chão de cada abate. Não muda regras do jogo: só reage aos sinais dos outros sistemas.

const KILL_COLORS := {
	EnemyTypes.COMUM: Color(1.0, 0.45, 0.45, 0.7),
	EnemyTypes.RAPIDO: Color(0.85, 1.0, 0.4, 0.7),
	EnemyTypes.RESISTENTE: Color(0.75, 0.8, 1.0, 0.8),
	EnemyTypes.ATIRADOR: Color(0.8, 0.5, 1.0, 0.7),
	EnemyTypes.EXPLOSIVO: Color(1.0, 0.7, 0.3, 0.7),
	EnemyTypes.TECELAO: Color(0.5, 1.0, 0.95, 0.8),
	EnemyTypes.SEMEADOR: Color(0.7, 0.85, 0.4, 0.7),
}
const MAX_POPS_PER_FRAME := 6  ## Abates em massa não enchem a tela de anéis.

var sounds: SoundBank
var camera_rig: CameraRig
var feedback: CombatFeedback
var effects: GroundEffects
var pops := 0  ## Estouros de abate desenhados (usado pelos testes).

var _pops_this_frame := 0


func connect_to(main: Node) -> void:
	var enemies: EnemyManager = main.enemies
	enemies.enemy_killed.connect(_on_kill)
	enemies.important_hit.connect(_on_important_hit)
	enemies.enemy_exploded.connect(_on_explosion)
	main.player.damaged.connect(_on_player_hurt)
	main.player.dodged.connect(func(_d: Vector3) -> void: sounds.play(&"esquiva"))
	main.progression.leveled_up.connect(func(_l: int) -> void: sounds.play(&"nivel"))
	main.orbs.collected.connect(func(_a: int) -> void: sounds.play(&"orbe", randf_range(0.9, 1.2)))
	main.boss.attack_warned.connect(func() -> void: sounds.play(&"alerta"))
	main.boss.phase_changed.connect(_on_boss_phase)


func _process(_delta: float) -> void:
	_pops_this_frame = 0


func _on_kill(where: Vector3, kind: int, _xp: int) -> void:
	sounds.play(&"abate", randf_range(0.85, 1.25))
	if _pops_this_frame >= MAX_POPS_PER_FRAME or not effects:
		return
	_pops_this_frame += 1
	pops += 1
	var color: Color = KILL_COLORS.get(kind, Color(1, 1, 1, 0.7))
	effects.burst(where, 0.2, 0.9, 0.22, color)


func _on_important_hit(where: Vector3, amount: float, weak_point: bool) -> void:
	sounds.play(&"golpe", 1.4 if weak_point else 1.0)
	var color := Color(1.0, 0.95, 0.5) if weak_point else Color(1.0, 1.0, 1.0)
	feedback.number(where, amount, color, weak_point)


func _on_explosion(_where: Vector3) -> void:
	sounds.play(&"explosao")
	camera_rig.shake(0.22, 0.25)


func _on_player_hurt(amount: float, _source: String) -> void:
	if amount >= 6.0:
		sounds.play(&"dano")
		camera_rig.shake(0.12, 0.18)


func _on_boss_phase(_phase: int) -> void:
	sounds.play(&"chefe")
	camera_rig.shake(0.4, 0.6)
