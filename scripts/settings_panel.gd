class_name SettingsPanel
extends VBoxContainer
## Lista de configurações (GameSettings), usada na pausa e no menu. Cada botão troca o valor
## ao ser tocado, salva na hora e emite `settings_changed`. Como as duas telas leem e gravam
## o mesmo arquivo, o que muda num lugar vale no outro.

signal settings_changed

const LABELS := {
	"mao": "Mão",
	"joystick_modo": "Joystick",
	"joystick_tamanho": "Tamanho do joystick",
	"joystick_altura": "Altura do joystick fixo",
	"som": "Som",
	"tremor": "Tremor de tela",
	"numeros_dano": "Números de dano",
}
const VALUE_NAMES := {
	"destro": "Destro",
	"canhoto": "Canhoto",
	"flutuante": "Flutuante",
	"fixo": "Fixo",
	"pequeno": "Pequeno",
	"medio": "Médio",
	"grande": "Grande",
	"baixa": "Baixa",
	"media": "Média",
	"alta": "Alta",
}

var settings: GameSettings:
	set(value):
		settings = value
		refresh()
var _buttons := {}  ## chave -> botão


func _ready() -> void:
	add_theme_constant_override("separation", 12)
	for key in LABELS:
		var row := HBoxContainer.new()
		var name_label := UiStyle.label(26)
		name_label.text = LABELS[key]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		var button := UiStyle.button("", 26, 72)
		button.custom_minimum_size.x = 210
		button.pressed.connect(_toggle.bind(key))
		row.add_child(button)
		add_child(row)
		_buttons[key] = button
	refresh()


func option_button(key: String) -> Button:
	return _buttons.get(key)


## Mostra os valores atuais (chame depois de outra tela mudar o arquivo).
func refresh() -> void:
	if settings == null or _buttons.is_empty():
		return
	for key in _buttons:
		var value: Variant = settings.values[key]
		var text := str(VALUE_NAMES.get(value, str(value)))
		if value is bool:
			text = "Ligado" if value else "Desligado"
		_buttons[key].text = text
	var fixed: bool = settings.values.joystick_modo == "fixo"
	_buttons["joystick_altura"].disabled = not fixed


func _toggle(key: String) -> void:
	if settings == null:
		return
	settings.cycle(key)
	settings.save()
	refresh()
	settings_changed.emit()
