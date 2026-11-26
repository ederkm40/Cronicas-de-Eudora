class_name SoundBank
extends Node
## Efeitos sonoros gerados por código (sem arquivos de áudio externos): cada som é uma onda
## curta sintetizada uma vez ao abrir o jogo e guardada como AudioStreamWAV (16 bits, mono).
## Uma fila pequena de players toca os sons; cada som tem um intervalo mínimo entre repetições,
## para uma horda inteira morrendo não virar ruído. Funciona também na pausa (sons de menu).
##
## No navegador, o áudio só começa depois do primeiro toque ou clique (regra dos navegadores).

const RATE := 22050
const VOICES := 10
## Intervalo mínimo (s) entre duas vezes o mesmo som.
const MIN_GAP := {
	&"golpe": 0.07,
	&"abate": 0.06,
	&"orbe": 0.06,
	&"dano": 0.25,
	&"explosao": 0.12,
}
const VOLUME_DB := {
	&"golpe": -16.0,
	&"abate": -14.0,
	&"orbe": -20.0,
	&"dano": -9.0,
	&"explosao": -8.0,
	&"esquiva": -11.0,
	&"nivel": -8.0,
	&"alerta": -9.0,
	&"evolucao": -6.0,
	&"fenda": -9.0,
	&"chefe": -5.0,
	&"vitoria": -6.0,
}

var enabled := true  ## Configuração "Som".
var played := {}  ## Som -> vezes tocado (usado pelos testes).

var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _next := 0
var _last := {}
var _clock := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	for i in VOICES:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)


func _process(delta: float) -> void:
	_clock += delta


## Toca um som pelo nome. Retorna false se o som não existe, está desligado ou repetiu cedo.
func play(sound: StringName, pitch: float = 1.0) -> bool:
	if not enabled or not _streams.has(sound):
		return false
	var gap: float = MIN_GAP.get(sound, 0.0)
	if _clock - float(_last.get(sound, -100.0)) < gap:
		return false
	_last[sound] = _clock
	played[sound] = int(played.get(sound, 0)) + 1
	var player := _players[_next]
	_next = (_next + 1) % _players.size()
	player.stream = _streams[sound]
	player.volume_db = VOLUME_DB.get(sound, -10.0)
	player.pitch_scale = pitch
	player.play()
	return true


func has_sound(sound: StringName) -> bool:
	return _streams.has(sound)


func stream_of(sound: StringName) -> AudioStreamWAV:
	return _streams.get(sound)


# ---------------------------------------------------------------- síntese


## Duração de cada som (s). A forma da onda vem da função `_wave_<nome>`.
const LENGTHS := {
	&"golpe": 0.05,
	&"abate": 0.09,
	&"orbe": 0.05,
	&"dano": 0.14,
	&"explosao": 0.4,
	&"esquiva": 0.16,
	&"nivel": 0.36,
	&"alerta": 0.26,
	&"evolucao": 0.6,
	&"fenda": 0.45,
	&"chefe": 0.8,
	&"vitoria": 0.7,
}


func _build() -> void:
	for sound: StringName in LENGTHS:
		_streams[sound] = _make(LENGTHS[sound], Callable(self, "_wave_" + String(sound)))


func _wave_golpe(t: float, n: float) -> float:
	return n * _decay(t, 0.05)


func _wave_abate(t: float, _n: float) -> float:
	return _sine(t, lerpf(760.0, 300.0, t / 0.09)) * _decay(t, 0.09) * 0.8


func _wave_orbe(t: float, _n: float) -> float:
	return _sine(t, 1320.0 + 600.0 * t / 0.05) * _decay(t, 0.05) * 0.5


func _wave_dano(t: float, n: float) -> float:
	return (_sine(t, 140.0) * 0.7 + n * 0.3) * _decay(t, 0.14)


func _wave_explosao(t: float, n: float) -> float:
	return (n * 0.8 + _sine(t, 60.0) * 0.5) * pow(1.0 - t / 0.4, 2.0)


func _wave_esquiva(t: float, n: float) -> float:
	return n * sin(PI * t / 0.16) * 0.55


func _wave_nivel(t: float, _n: float) -> float:
	var note := 523.25 if t < 0.12 else (659.25 if t < 0.24 else 783.99)
	return _sine(t, note) * _decay(fmod(t, 0.12) + 0.02, 0.2) * 0.7


func _wave_alerta(t: float, _n: float) -> float:
	var tone := 220.0 if t < 0.13 else 330.0
	return signf(_sine(t, tone)) * 0.25 * _decay(fmod(t, 0.13), 0.2)


func _wave_evolucao(t: float, _n: float) -> float:
	var chord := _sine(t, 392.0) + _sine(t, 493.88) + _sine(t, 587.33 + 40.0 * t)
	return chord * 0.28 * _decay(t, 0.6)


func _wave_fenda(t: float, _n: float) -> float:
	return (_sine(t, 440.0 + 30.0 * sin(t * 40.0)) + _sine(t, 660.0)) * 0.3 * _decay(t, 0.45)


func _wave_chefe(t: float, _n: float) -> float:
	var tone := _sine(t, 70.0) + _sine(t, 140.5) * 0.5 + _sine(t, 211.0) * 0.25
	return tone * 0.45 * _decay(t, 0.8)


func _wave_vitoria(t: float, _n: float) -> float:
	var note := 523.25 if t < 0.18 else (659.25 if t < 0.36 else 1046.5)
	return _sine(t, note) * 0.6 * _decay(fmod(t, 0.18) + 0.02, 0.3)


## Gera `seconds` de áudio a partir de f(tempo, ruído) -> amostra em -1..1.
func _make(seconds: float, f: Callable) -> AudioStreamWAV:
	var frames := int(seconds * RATE)
	var data := PackedByteArray()
	data.resize(frames * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = frames  # sempre o mesmo som
	for i in frames:
		var t := float(i) / RATE
		var sample := clampf(float(f.call(t, rng.randf_range(-1.0, 1.0))), -1.0, 1.0)
		data.encode_s16(i * 2, int(sample * 32000.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.data = data
	return stream


static func _sine(t: float, frequency: float) -> float:
	return sin(TAU * frequency * t)


static func _decay(t: float, length: float) -> float:
	return clampf(1.0 - t / length, 0.0, 1.0) * clampf(t / 0.004, 0.0, 1.0)
