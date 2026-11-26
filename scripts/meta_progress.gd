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
## - arquivo corrompido: guarda uma cópia (.corrompido) e começa do zero.
## O salvamento escreve num arquivo temporário e só então troca pelo definitivo.

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

## Caminho usado por main.gd. Os testes trocam para um arquivo próprio.
static var path := DEFAULT_PATH

var ecos := 0
var runs := 0
var victories := 0
var best_time := 0.0
var total_kills := 0
var read_only := false  ## true se o arquivo veio de uma versão mais nova do jogo.
var load_note := ""  ## O que aconteceu ao carregar (para a documentação e os testes).

var _levels := {}
var _path := DEFAULT_PATH


static func load_from(file_path: String = "") -> MetaProgress:
	var meta := MetaProgress.new()
	meta._path = file_path if file_path != "" else path
	if not FileAccess.file_exists(meta._path):
		meta.load_note = "novo"
		return meta
	var json := JSON.new()
	var parsed := json.parse(FileAccess.get_file_as_string(meta._path))
	var data: Variant = json.data if parsed == OK else null
	if not (data is Dictionary):
		DirAccess.copy_absolute(meta._path, meta._path + ".corrompido")
		meta.load_note = "corrompido"
		return meta
	var version := int(data.get("versao", 0))
	if version > VERSION:
		meta.read_only = true
		meta.load_note = "versão mais nova (%d)" % version
	else:
		data = migrate(data)
		meta.load_note = "migrado de %d" % version if version < VERSION else "carregado"
	meta._read(data)
	return meta


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


func _read(data: Dictionary) -> void:
	ecos = maxi(int(data.get("ecos", 0)), 0)
	var stats: Dictionary = data.get("estatisticas", {})
	runs = int(stats.get("partidas", 0))
	victories = int(stats.get("vitorias", 0))
	best_time = float(stats.get("melhor_tempo", 0.0))
	total_kills = int(stats.get("abates", 0))
	var saved: Dictionary = data.get("melhorias", {})
	for definition in UPGRADES:
		var key := String(definition.id)
		_levels[definition.id] = clampi(int(saved.get(key, 0)), 0, definition.costs.size())


func to_dict() -> Dictionary:
	var saved := {}
	for definition in UPGRADES:
		saved[String(definition.id)] = level_of(definition.id)
	return {
		"versao": VERSION,
		"ecos": ecos,
		"melhorias": saved,
		"estatisticas":
		{
			"partidas": runs,
			"vitorias": victories,
			"melhor_tempo": best_time,
			"abates": total_kills,
		},
	}


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
