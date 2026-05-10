extends PanelContainer
## Panel de selección de sala.
## Migrado desde GameUI.gd (_build_room_select / show_room_selector / _add_room_button).
## Se comunica hacia el exterior solo mediante señales.

signal room_selected(room_id: String)
signal open_profile_requested()

const HUD_TEXT_MAIN: Color    = Color(0.96, 0.96, 0.92)
const HUD_TEXT_SECONDARY: Color = Color(0.62, 0.72, 0.86)
const HUD_BORDER: Color       = Color(0.48, 0.60, 0.78, 0.28)
const HUD_ACCENT: Color       = Color(1.00, 0.66, 0.28, 0.98)

var _cards_vbox: VBoxContainer


func _ready() -> void:
	name = "RoomSelectPanel"
	anchor_left = 0.0; anchor_top = 0.0
	anchor_right = 1.0; anchor_bottom = 1.0
	offset_left = 0.0; offset_top = 0.0
	offset_right = 0.0; offset_bottom = 0.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_theme_stylebox_override("panel", _premium_panel_style(Color(0.01, 0.015, 0.05, 0.66), 0))

	var center := PanelContainer.new()
	center.name = "RoomSelectCard"
	center.anchor_left = 0.5; center.anchor_top = 0.5
	center.anchor_right = 0.5; center.anchor_bottom = 0.5
	center.offset_left = -270.0; center.offset_top = -230.0
	center.offset_right = 270.0; center.offset_bottom = 230.0
	center.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_theme_stylebox_override("panel", _premium_panel_style(Color(0.045, 0.058, 0.130, 0.96), 16))
	add_child(center)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 26)
	center.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Seleccionar sala"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", HUD_TEXT_MAIN)
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Elige donde quieres entrar"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", HUD_TEXT_SECONDARY)
	vbox.add_child(subtitle)

	_cards_vbox = VBoxContainer.new()
	_cards_vbox.add_theme_constant_override("separation", 9)
	_cards_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(_cards_vbox)

	# Salas por defecto (reemplazadas en populate_rooms)
	_add_room_btn("lobby",      "Lobby")
	_add_room_btn("room_small", "Sala pequeña")
	_add_room_btn("room_large", "Sala grande")

	var profile_btn := Button.new()
	profile_btn.text = "Editar Perfil"
	profile_btn.custom_minimum_size = Vector2(0.0, 38.0)
	profile_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	profile_btn.add_theme_font_size_override("font_size", 13)
	profile_btn.add_theme_color_override("font_color", HUD_TEXT_MAIN)
	profile_btn.add_theme_stylebox_override("normal",  _premium_btn_style(Color(0.09, 0.12, 0.24, 0.88)))
	profile_btn.add_theme_stylebox_override("hover",   _premium_btn_style(Color(0.14, 0.18, 0.34, 0.94)))
	profile_btn.add_theme_stylebox_override("pressed", _premium_btn_style(Color(0.18, 0.22, 0.38, 1.0)))
	profile_btn.pressed.connect(func(): open_profile_requested.emit())
	vbox.add_child(profile_btn)


# --- API pública ---

func populate_rooms(rooms: Array) -> void:
	for child: Node in _cards_vbox.get_children():
		_cards_vbox.remove_child(child)
		child.queue_free()
	for r in rooms:
		var room_id := ""
		var r_label := ""
		if r is Dictionary and r.has("id") and r.has("label"):
			room_id = r["id"]
			r_label = r["label"]
		elif r is RefCounted:
			room_id = r.id
			r_label = r.display_name
		if room_id != "" and r_label != "":
			_add_room_btn(room_id, r_label)


# --- Helpers internos ---

func _add_room_btn(room_id: String, label_text: String) -> void:
	var btn := Button.new()
	btn.text = _card_text(room_id, label_text)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.custom_minimum_size = Vector2(0.0, 70.0)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color",         HUD_TEXT_MAIN)
	btn.add_theme_color_override("font_hover_color",   HUD_TEXT_MAIN)
	btn.add_theme_color_override("font_pressed_color", Color(0.10, 0.07, 0.04))
	btn.add_theme_stylebox_override("normal",  _room_card_style(Color(0.075, 0.095, 0.190, 0.98), HUD_BORDER))
	btn.add_theme_stylebox_override("hover",   _room_card_style(Color(0.110, 0.145, 0.270, 1.0),  Color(1.0, 0.72, 0.36, 0.55)))
	btn.add_theme_stylebox_override("pressed", _room_card_style(HUD_ACCENT,                        Color(1.0, 0.88, 0.54, 0.90)))
	btn.pressed.connect(func(): room_selected.emit(room_id))
	_cards_vbox.add_child(btn)


func _card_text(room_id: String, label_text: String) -> String:
	var description := "Sala decorable"
	var badge := ""
	match room_id:
		"lobby":       description = "Sala principal";   badge = "Bot Guia disponible"
		"room_small":  description = "Espacio compacto"
		"room_large":  description = "Mas espacio para decorar"
	if badge != "":
		return label_text + "\n" + description + "  |  " + badge
	return label_text + "\n" + description


func _premium_panel_style(bg: Color, radius: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = radius; s.corner_radius_top_right = radius
	s.corner_radius_bottom_right = radius; s.corner_radius_bottom_left = radius
	s.border_color = Color(1.0, 1.0, 1.0, 0.08)
	s.border_width_left = 1; s.border_width_top = 1
	s.border_width_right = 1; s.border_width_bottom = 1
	return s


func _premium_btn_style(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = 8; s.corner_radius_top_right = 8
	s.corner_radius_bottom_right = 8; s.corner_radius_bottom_left = 8
	s.border_color = Color(1.0, 1.0, 1.0, 0.12)
	s.border_width_left = 1; s.border_width_top = 1
	s.border_width_right = 1; s.border_width_bottom = 1
	return s


func _room_card_style(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = 10; s.corner_radius_top_right = 10
	s.corner_radius_bottom_right = 10; s.corner_radius_bottom_left = 10
	s.border_color = border
	s.border_width_left = 1; s.border_width_top = 1
	s.border_width_right = 1; s.border_width_bottom = 1
	return s
