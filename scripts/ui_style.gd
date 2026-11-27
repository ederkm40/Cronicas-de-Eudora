class_name UiStyle
extends RefCounted
## Visual comum dos botões e textos das telas (menu, pausa, resultados e o botão de pausa do
## HUD). Botões com fundo, borda e cantos arredondados, para não se confundirem com o cenário.
## Tudo em código, sem arquivos de tema.

enum Kind { NORMAL, PRIMARY, QUIET }

const TEXT := Color(0.96, 0.94, 1.0)
const MUTED := Color(1, 1, 1, 0.72)
const ACCENT := Color(0.55, 0.95, 1.0)  ## Ecos e destaques.
const GOLD := Color(1.0, 0.85, 0.45)
const BACKDROP := Color(0.02, 0.01, 0.04, 0.86)

## Cor de fundo e de borda por tipo: [fundo, fundo ao tocar, borda, texto].
const COLORS := {
	Kind.NORMAL:
	[Color(0.2, 0.17, 0.28, 0.96), Color(0.3, 0.25, 0.42), Color(0.55, 0.5, 0.75), TEXT],
	Kind.PRIMARY:
	[Color(0.85, 0.6, 0.2), Color(1.0, 0.75, 0.3), Color(1.0, 0.9, 0.6), Color(0.12, 0.07, 0.02)],
	Kind.QUIET: [Color(0.12, 0.1, 0.16, 0.9), Color(0.2, 0.17, 0.26), Color(0.4, 0.36, 0.5), TEXT],
}


static func button(text: String, font_size: int, height: int, kind := Kind.NORMAL) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, height)
	b.focus_mode = Control.FOCUS_NONE
	style_button(b, font_size, kind)
	return b


## Aplica o visual a um botão já criado.
static func style_button(b: Button, font_size: int, kind := Kind.NORMAL) -> void:
	var colors: Array = COLORS[kind]
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_stylebox_override("normal", box(colors[0], colors[2], 2))
	b.add_theme_stylebox_override("hover", box(colors[1], colors[2], 2))
	b.add_theme_stylebox_override("pressed", box(colors[1], Color.WHITE, 3))
	var off := Color(colors[0], 0.35)
	b.add_theme_stylebox_override("disabled", box(off, Color(colors[2], 0.35), 2))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(state, colors[3])
	b.add_theme_color_override("font_disabled_color", Color(colors[3], 0.4))


static func box(color: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(14)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style


static func label(font_size: int, color: Color = TEXT) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 6)
	return l


## Fundo escuro que cobre a tela inteira (atrás das telas que abrem por cima da partida).
static func backdrop(alpha: float = BACKDROP.a) -> ColorRect:
	var shade := ColorRect.new()
	shade.color = Color(BACKDROP, alpha)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return shade
