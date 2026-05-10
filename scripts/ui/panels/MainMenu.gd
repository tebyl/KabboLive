extends PanelContainer
## Menú principal del juego.
## Migrado desde GameUI.gd (_build_main_menu).
## Se comunica hacia el exterior solo mediante señales.

signal enter_hotel_requested()
signal open_profile_requested()
signal open_settings_requested()
signal open_about_requested()

const GAME_TITLE: String = "Kabbo Hotel"
const GAME_VERSION: String = "v0.1.0-demo"


func _ready() -> void:
	name = "MainMenuPanel"
	anchor_left = 0.5; anchor_top = 0.5
	anchor_right = 0.5; anchor_bottom = 0.5
	offset_left = -180.0; offset_top = -130.0
	offset_right = 180.0; offset_bottom = 130.0

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	var title := Label.new()
	title.text = GAME_TITLE
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)

	var version_lbl := Label.new()
	version_lbl.text = GAME_VERSION
	version_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(version_lbl)

	var enter_btn := Button.new()
	enter_btn.text = "Entrar al hotel"
	enter_btn.pressed.connect(func(): enter_hotel_requested.emit())
	vbox.add_child(enter_btn)

	var profile_btn := Button.new()
	profile_btn.text = "Perfil"
	profile_btn.pressed.connect(func(): open_profile_requested.emit())
	vbox.add_child(profile_btn)

	var cfg_btn := Button.new()
	cfg_btn.text = "Configuración"
	cfg_btn.pressed.connect(func(): open_settings_requested.emit())
	vbox.add_child(cfg_btn)

	var about_btn := Button.new()
	about_btn.text = "Acerca de"
	about_btn.pressed.connect(func(): open_about_requested.emit())
	vbox.add_child(about_btn)
