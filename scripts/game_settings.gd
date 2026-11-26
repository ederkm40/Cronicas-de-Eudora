class_name GameSettings
extends RefCounted
## Configurações do jogador, salvas em `user://configuracoes.json` (separado do progresso).
## Controles para um dedo: mão (destro/canhoto, espelha a interface e o joystick fixo),
## modo do joystick (flutuante ou fixo), tamanho e altura do joystick fixo dentro de limites
## seguros. Também som, tremor de tela e números de dano.
##
## O arquivo tem versão. Valores desconhecidos ou inválidos voltam ao padrão (o resto é
## mantido) e o motivo fica em `load_issues`; um JSON inválido é copiado como `.corrompido`.

const VERSION := 1
const DEFAULT_PATH := "user://configuracoes.json"
const HANDS := ["destro", "canhoto"]
const MODES := ["flutuante", "fixo"]
const SIZES := {"pequeno": 0.8, "medio": 1.0, "grande": 1.25}
const SIZE_ORDER := ["pequeno", "medio", "grande"]
## Altura do joystick fixo, em fração da tela (0 = topo). Limites seguros: longe das bordas.
const HEIGHTS := {"baixa": 0.84, "media": 0.76, "alta": 0.66}
const HEIGHT_ORDER := ["baixa", "media", "alta"]
const DEFAULTS := {
	"mao": "destro",
	"joystick_modo": "flutuante",
	"joystick_tamanho": "medio",
	"joystick_altura": "baixa",
	"som": true,
	"tremor": true,
	"numeros_dano": true,
}

static var path := DEFAULT_PATH

var values := DEFAULTS.duplicate()
var load_issues: Array[String] = []
var _path := DEFAULT_PATH


static func load_from(file_path: String = "") -> GameSettings:
	var settings := GameSettings.new()
	settings._path = file_path if file_path != "" else path
	if not FileAccess.file_exists(settings._path):
		return settings
	var json := JSON.new()
	var parsed := json.parse(FileAccess.get_file_as_string(settings._path))
	if parsed != OK or not (json.data is Dictionary):
		DirAccess.copy_absolute(settings._path, settings._path + ".corrompido")
		settings.load_issues.append("arquivo inválido: configurações padrão")
		return settings
	var data: Dictionary = json.data
	for key in DEFAULTS:
		if data.has(key):
			settings.set_value(key, data[key])
	return settings


## Muda um valor se ele for válido. Retorna false (e registra) se for inválido.
func set_value(key: String, value: Variant) -> bool:
	if not DEFAULTS.has(key) or not _is_valid(key, value):
		load_issues.append('valor inválido em "%s"' % key)
		return false
	values[key] = value
	return true


func _is_valid(key: String, value: Variant) -> bool:
	match key:
		"mao":
			return value is String and HANDS.has(value)
		"joystick_modo":
			return value is String and MODES.has(value)
		"joystick_tamanho":
			return value is String and SIZES.has(value)
		"joystick_altura":
			return value is String and HEIGHTS.has(value)
	return value is bool


## Passa para a próxima opção de uma lista (botões da tela de pausa).
func cycle(key: String) -> void:
	var options: Array = []
	match key:
		"mao":
			options = HANDS
		"joystick_modo":
			options = MODES
		"joystick_tamanho":
			options = SIZE_ORDER
		"joystick_altura":
			options = HEIGHT_ORDER
		_:
			values[key] = not bool(values[key])
			return
	values[key] = options[(options.find(values[key]) + 1) % options.size()]


func save() -> bool:
	var data := values.duplicate()
	data["versao"] = VERSION
	var temp := _path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return DirAccess.rename_absolute(temp, _path) == OK


func left_handed() -> bool:
	return values.mao == "canhoto"


func joystick_scale() -> float:
	return SIZES[values.joystick_tamanho]


## Centro do joystick fixo em frações da tela: do lado do polegar.
func fixed_anchor() -> Vector2:
	return Vector2(0.28 if left_handed() else 0.72, HEIGHTS[values.joystick_altura])
