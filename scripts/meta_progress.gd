class_name MetaProgress
extends RefCounted
## Progressão entre partidas: os Ecos (recurso que sobra de cada partida) e as melhorias
## permanentes compradas com eles. Fica salvo em `user://progresso.json`.
## No navegador, `user://` fica no armazenamento do próprio site (IndexedDB): sobrevive a
## recarregar a página, mas some se o jogador limpar os dados do site.
##
## Formato com versão ("versao"). Ao carregar:
## - sem arquivo: começa do zero;
## - arquivo antigo (versão menor): migra para a versão atual e mantém os dados;
## - arquivo de uma versão mais nova que este jogo: lê o que entende e NÃO salva por cima,
##   para não apagar dados de uma versão futura;
## - arquivo corrompido (JSON inválido, raiz que não é objeto, versão inválida, ou
##   "estatisticas"/"melhorias" que não são objetos): guarda uma cópia (.corrompido) e
##   começa do zero;
## - campo com valor inválido (tipo errado, negativo, fracionado, nível acima do limite):
##   guarda a cópia (.corrompido), troca só aquele campo por um valor seguro (0 ou o limite)
##   e mantém o resto.
## Os motivos ficam em `load_issues` e são avisados no console. O arquivo original só é
## substituído no próximo salvamento, depois que a cópia já existe. Campos desconhecidos são
## mantidos ao salvar. O salvamento escreve num arquivo temporário e só então troca pelo
## definitivo.

const VERSION := 1
const DEFAULT_PATH := "user://progresso.json"

const VIGOR := &"vigor_ancestral"
const FURY := &"furia_latente"
const MAGNET := &"atracao_do_eco"
const RENEWAL := &"renovacao"

## Melhorias permanentes: poucas, baratas no começo e com efeito moderado.
const UPGRADES := [
	{
		"id": VIGOR,
		"name": "Vigor ancestral",
		"description": "+8% de vida máxima por nível.",
		"costs": [15, 30, 50, 75, 110],
	},
	{
		"id": FURY,
		"name": "Fúria latente",
		"description": "+5% de dano de todas as armas por nível.",
		"costs": [20, 40, 65, 95, 130],
	},
	{
		"id": MAGNET,
		"name": "Atração do eco",
		"description": "+20% de raio de coleta dos orbes por nível.",
		"costs": [12, 25, 45],
	},
	{
		"id": RENEWAL,
		"name": "Renovação",
		"description": "+1 troca de opções no level-up por nível.",
		"costs": [40, 90],
	},
]
const VIGOR_PER_LEVEL := 0.08
const FURY_PER_LEVEL := 0.05
const MAGNET_PER_LEVEL := 0.2
const MAX_COUNT := 1000000000  ## Teto para números lidos do arquivo (evita estouro).

## Caminho usado por main.gd. Os testes trocam para um arquivo próprio.
static var path := DEFAULT_PATH

var ecos := 0
var runs := 0
var victories := 0
var best_time := 0.0
var total_kills := 0
var read_only := false  ## true se o arquivo veio de uma versão mais nova do jogo.
var load_note := ""  ## O que aconteceu ao carregar (para a documentação e os testes).
var load_issues: Array[String] = []  ## Problemas encontrados no arquivo (vazio = íntegro).

var _levels := {}
var _path := DEFAULT_PATH
var _raw := {}  ## Dados lidos, para manter campos desconhecidos ao salvar.


static func load_from(file_path: String = "") -> MetaProgress:
	var meta := MetaProgress.new()
	meta._path = file_path if file_path != "" else path
	if not FileAccess.file_exists(meta._path):
		meta.load_note = "novo"
		return meta
	var json := JSON.new()
	var parsed := json.parse(FileAccess.get_file_as_string(meta._path))
	if parsed != OK:
		return meta._start_over("JSON inválido (linha %d)" % json.get_error_line())
	var data: Variant = json.data
	if not (data is Dictionary):
		return meta._start_over("a raiz não é um objeto")
	var version_value: Variant = data.get("versao", 0)
	if not _is_number(version_value) or float(version_value) < 0.0:
		return meta._start_over("versão inválida")
	var version := int(version_value)
	if version > VERSION:
		# Versão futura: lê o que entende, sem validar a estrutura nova e sem nunca salvar.
		meta.read_only = true
		meta.load_note = "versão mais nova (%d)" % version
		meta._read(data, false)
		return meta
	for container in ["estatisticas", "melhorias"]:
		if data.has(container) and not (data[container] is Dictionary):
			return meta._start_over('"%s" não é um objeto' % container)
	data = migrate(data)
	meta._read(data, true)
	if version < VERSION:
		meta.load_note = "migrado de %d" % version
	elif not meta.load_issues.is_empty():
		meta.load_note = "ajustado"
	else:
		meta.load_note = "carregado"
	if not meta.load_issues.is_empty():
		meta._backup()
		push_warning("Progresso ajustado ao carregar: " + "; ".join(meta.load_issues))
	return meta


## Arquivo inutilizável: guarda uma cópia e começa do zero (sem apagar o original agora).
func _start_over(reason: String) -> MetaProgress:
	load_note = "corrompido"
	load_issues.append(reason)
	_backup()
	push_warning("Progresso corrompido (%s): cópia em %s.corrompido" % [reason, _path])
	return self


func _backup() -> void:
	DirAccess.copy_absolute(_path, _path + ".corrompido")


static func _is_number(value: Variant) -> bool:
	var kind := typeof(value)
	if kind == TYPE_INT:
		return true
	return kind == TYPE_FLOAT and not is_nan(value) and not is_inf(value)


## Converte dados de versões anteriores para a atual.
## Versão 0 = formato sem o campo "versao" (anterior à versão 1): só "ecos" e "melhorias".
static func migrate(data: Dictionary) -> Dictionary:
	var migrated := data.duplicate(true)
	var version := int(migrated.get("versao", 0))
	if version < 1:
		if not migrated.has("estatisticas"):
			migrated["estatisticas"] = {}
		if not migrated.has("melhorias"):
			migrated["melhorias"] = {}
		migrated["versao"] = 1
	return migrated


## Lê os campos conhecidos. Cada campo inválido vira um valor seguro e é anotado
## (`strict`); numa versão futura (`strict` = false) os problemas não são anotados.
func _read(data: Dictionary, strict: bool) -> void:
	_raw = data.duplicate(true)
	var stats := _object(data, "estatisticas")
	var saved := _object(data, "melhorias")
	ecos = _count(data, "ecos", "ecos", -1, strict)
	runs = _count(stats, "partidas", "estatisticas.partidas", -1, strict)
	victories = _count(stats, "vitorias", "estatisticas.vitorias", -1, strict)
	total_kills = _count(stats, "abates", "estatisticas.abates", -1, strict)
	best_time = _seconds(stats, "melhor_tempo", "estatisticas.melhor_tempo", strict)
	for definition in UPGRADES:
		var key := String(definition.id)
		var label := "melhorias." + key
		_levels[definition.id] = _count(saved, key, label, definition.costs.size(), strict)


## Número inteiro, de 0 até `limit` (-1 = sem limite além de MAX_COUNT). Ausente = 0.
func _count(source: Dictionary, key: String, label: String, limit: int, strict: bool) -> int:
	if not source.has(key):
		return 0
	var value: Variant = source[key]
	if not _is_number(value):
		_note(strict, "%s não é um número" % label)
		return 0
	var number := float(value)
	if number < 0.0:
		_note(strict, "%s negativo (%s)" % [label, value])
		return 0
	if number != floorf(number):
		_note(strict, "%s fracionado (%s)" % [label, value])
	var top := limit if limit >= 0 else MAX_COUNT
	if number > float(top):
		_note(strict, "%s acima do limite (%s > %d)" % [label, value, top])
		return top
	return int(number)


func _seconds(source: Dictionary, key: String, label: String, strict: bool) -> float:
	if not source.has(key):
		return 0.0
	var value: Variant = source[key]
	if not _is_number(value) or float(value) < 0.0:
		_note(strict, "%s inválido" % label)
		return 0.0
	return minf(float(value), float(MAX_COUNT))


## O objeto em `key`, ou um objeto vazio se não existir ou não for objeto.
static func _object(data: Dictionary, key: String) -> Dictionary:
	var value: Variant = data.get(key)
	return value if value is Dictionary else {}


func _note(strict: bool, issue: String) -> void:
	if strict:
		load_issues.append(issue)


## Dados para salvar. Campos desconhecidos lidos do arquivo são mantidos.
func to_dict() -> Dictionary:
	var data := _raw.duplicate(true)
	var saved := _object(data, "melhorias")
	for definition in UPGRADES:
		saved[String(definition.id)] = level_of(definition.id)
	var stats := _object(data, "estatisticas")
	stats["partidas"] = runs
	stats["vitorias"] = victories
	stats["melhor_tempo"] = best_time
	stats["abates"] = total_kills
	data["versao"] = VERSION
	data["ecos"] = ecos
	data["melhorias"] = saved
	data["estatisticas"] = stats
	return data


func save() -> bool:
	if read_only:
		return false
	var temp := _path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(to_dict(), "\t"))
	file.close()
	return DirAccess.rename_absolute(temp, _path) == OK


static func definition(id: StringName) -> Dictionary:
	for d in UPGRADES:
		if d.id == id:
			return d
	return {}


func level_of(id: StringName) -> int:
	return _levels.get(id, 0)


func max_level_of(id: StringName) -> int:
	return definition(id).get("costs", []).size()


## Preço do próximo nível (-1 se já está no máximo).
func cost_of(id: StringName) -> int:
	var costs: Array = definition(id).get("costs", [])
	var next := level_of(id)
	return int(costs[next]) if next < costs.size() else -1


func can_buy(id: StringName) -> bool:
	var cost := cost_of(id)
	return not read_only and cost >= 0 and ecos >= cost


func buy(id: StringName) -> bool:
	if not can_buy(id):
		return false
	ecos -= cost_of(id)
	_levels[id] = level_of(id) + 1
	return true


func hp_multiplier() -> float:
	return 1.0 + VIGOR_PER_LEVEL * level_of(VIGOR)


func damage_multiplier() -> float:
	return 1.0 + FURY_PER_LEVEL * level_of(FURY)


func magnet_multiplier() -> float:
	return 1.0 + MAGNET_PER_LEVEL * level_of(MAGNET)


func extra_rerolls() -> int:
	return level_of(RENEWAL)


## Ecos ganhos numa partida: 1 a cada 20 s, 1 a cada 15 abates e 40 por derrotar o chefe.
static func reward_for(seconds: float, kills: int, bosses: int) -> int:
	return int(seconds / 20.0) + int(kills / 15.0) + 40 * bosses


## Registra o fim de uma partida e soma a recompensa. Retorna os Ecos ganhos.
func record_run(seconds: float, kills: int, bosses: int, won: bool) -> int:
	var reward := reward_for(seconds, kills, bosses)
	ecos += reward
	runs += 1
	total_kills += kills
	best_time = maxf(best_time, seconds)
	if won:
		victories += 1
	return reward
