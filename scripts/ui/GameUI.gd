extends RefCounted

const GAME_TITLE: String = "Kabbo Hotel"
const GAME_VERSION: String = "v0.1.0-demo"

const CHAT_HISTORY_LEFT_MARGIN = 24.0
const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const RoomDataScript = preload("res://scripts/room/RoomData.gd")
const IsoGridScript = preload("res://scripts/room/IsoGrid.gd")

const FurnitureData = FurnitureDataScript
const RoomData = RoomDataScript
const IsoGrid = IsoGridScript
const CHAT_HISTORY_BOTTOM_GAP = 150.0
const CHAT_HISTORY_WIDTH = 320.0
const CHAT_BUBBLE_MAX_WIDTH = 300.0
const CHAT_BUBBLE_MIN_WIDTH = 140.0
const HUD_BG: Color = Color(0.025, 0.035, 0.085, 0.82)
const HUD_PANEL: Color = Color(0.045, 0.060, 0.140, 0.78)
const HUD_PANEL_LIGHT: Color = Color(0.100, 0.135, 0.240, 0.88)
const HUD_BORDER: Color = Color(0.48, 0.60, 0.78, 0.28)
const HUD_ACCENT: Color = Color(1.00, 0.66, 0.28, 0.98)
const HUD_TEXT_MAIN: Color = Color(0.96, 0.96, 0.92)
const HUD_TEXT_SECONDARY: Color = Color(0.62, 0.72, 0.86)
const HUD_SUCCESS: Color = Color(0.54, 1.00, 0.74)
const HUD_WARNING: Color = Color(1.00, 0.84, 0.40)

var ui_layer: CanvasLayer
var room_label: Label
var status_label: Label
var controls_panel: PanelContainer
var main_menu_panel: PanelContainer
var room_select_panel: PanelContainer
var room_select_vbox: VBoxContainer
var _room_cards_vbox: VBoxContainer
var profile_panel: PanelContainer
var profile_name_edit: LineEdit
var profile_color_rect: ColorRect
var current_profile_color: Color = Color.BLUE
var _profile_shirt_color: Color = Color(0.14, 0.32, 0.72)
var _profile_pants_color: Color = Color(0.14, 0.16, 0.30)
var _profile_hair_color: Color = Color(0.18, 0.10, 0.06)
var _profile_skin_tone: Color = Color(0.84, 0.62, 0.44)
var _profile_hair_style: String = "short"
var _profile_shirt_btns: Array[Button] = []
var _profile_pants_btns: Array[Button] = []
var _profile_hair_color_btns: Array[Button] = []
var _profile_skin_btns: Array[Button] = []
var _profile_style_btns: Array[Button] = []
var _profile_preview_root: Control
var chat_history_panel: PanelContainer
var chat_history_label: Label
var chat_input_panel: PanelContainer
var chat_input: LineEdit
var chat_bubble_panel: PanelContainer
var chat_bubble_label: Label
var chat_bubble_timer: float = 0.0
var chat_bubble_visible: bool = false
var npc_bubble_panel: PanelContainer
var npc_bubble_label: Label
var npc_bubble_timer: float = 0.0
var npc_bubble_visible: bool = false
var inventory_panel: PanelContainer
var missions_panel: PanelContainer
var _missions_list_vbox: VBoxContainer
var credits_label: Label
var help_button: Button
var shop_button: Button
var _mode_button: Button
var shop_panel: PanelContainer
var _shop_items_vbox: VBoxContainer
var _shop_credits_label: Label
var toast_panel: PanelContainer
var toast_label: Label
var toast_tween: Tween
var tutorial_overlay: Control
var tutorial_panel: PanelContainer
var tutorial_title_label: Label
var tutorial_body_label: Label
var tutorial_counter_label: Label
var tutorial_prev_button: Button
var tutorial_next_button: Button
var tutorial_skip_button: Button
var tutorial_finish_button: Button
var tutorial_step_index: int = 0
var tutorial_is_manual: bool = false
var _on_tutorial_closed: Callable
var _on_tutorial_open_requested: Callable
var _on_shop_item_buy: Callable
var _on_shop_closed: Callable
var _on_mode_toggle: Callable
var settings_panel: PanelContainer
var _settings_autosave_toggle_btn: Button
var _settings_interval_btns: Array[Button] = []
var _settings_missions_btn: Button
var _settings_sfx_toggle_btn: Button
var _settings_sfx_volume_btns: Array[Button] = []
var _confirm_reset_panel: PanelContainer
var _settings_btn_in_room: Button
var _on_settings_autosave_enabled: Callable
var _on_settings_autosave_interval: Callable
var _on_settings_show_missions: Callable
var _on_settings_sfx_enabled: Callable
var _on_settings_sfx_volume: Callable
var _on_settings_tutorial_restart: Callable
var _on_settings_reset_data: Callable
var _on_settings_closed_cb: Callable
var _on_open_settings_cb: Callable
var _on_ui_sound: Callable
var _pause_overlay: Control
var _pause_menu_panel: PanelContainer
var _pause_exit_confirm_panel: PanelContainer
var _pause_menu_btn: Button
var _hint_label: Label
var _on_pause_continue: Callable
var _on_pause_save: Callable
var _on_pause_settings: Callable
var _on_pause_back_to_rooms: Callable
var _on_pause_exit_confirm: Callable
var _about_panel: PanelContainer
var _splash_panel: Control
var _on_about_closed_cb: Callable
var _tutorial_steps: Array[Dictionary] = [
	{"title": "Bienvenido a Kabbo Hotel", "body": "Camina haciendo click sobre un tile libre."},
	{"title": "Coloca muebles", "body": "Usa el catálogo de la derecha o las teclas 1, 2 y 3 para elegir muebles."},
	{"title": "Edita tu sala", "body": "Haz click en un mueble para inspeccionarlo. Puedes moverlo, rotarlo o eliminarlo."},
	{"title": "Capas y decoración", "body": "Las alfombras van en el piso y puedes colocar muebles encima."},
	{"title": "Chat y bot guía", "body": "Presiona Enter para chatear. Prueba escribir 'hola' o 'ayuda'."},
	{"title": "Guarda tu progreso", "body": "Presiona S para guardar y L para cargar tus salas."},
]

var catalog_panel: PanelContainer
var _catalog_tab_hbox: HBoxContainer
var _catalog_items_vbox: VBoxContainer
var _catalog_data: Dictionary = {}
var _catalog_categories: Array[String] = []
var _current_category: String = ""
var _catalog_selected_type: String = ""
var _catalog_tab_buttons: Array[Button] = []
var _catalog_item_buttons: Array[Button] = []
var _catalog_item_types: Array[String] = []
var furniture_inspector_panel: PanelContainer
var _inspector_name_label: Label
var _inspector_cell_label: Label
var _inspector_size_label: Label
var _inspector_state_label: Label
var _inspector_blocks_label: Label
var _inspector_layer_label: Label
var _on_inspector_move: Callable
var _on_inspector_rotate: Callable
var _on_inspector_delete: Callable
var _on_inspector_close: Callable

var overlap_selector_panel: PanelContainer
var _overlap_items_vbox: VBoxContainer
var _on_overlap_item_selected: Callable
var _on_overlap_selector_closed: Callable

var _on_enter_hotel: Callable
var _on_room_selected: Callable
var _on_back_to_rooms: Callable
var _on_save_profile: Callable
var _on_chat_submitted: Callable
var _on_catalog_selected: Callable
var _missions_display_enabled: bool = true

var premium_top_bar: PanelContainer
var _premium_room_name_label: Label
var _premium_people_label: Label
var _premium_rating_label: Label
var _premium_credits_label: Label
var premium_objective_panel: PanelContainer
var _premium_objective_title_label: Label
var _premium_objective_desc_label: Label
var _premium_objective_progress_label: Label
var _premium_objective_status_label: Label
var _premium_objective_reward_label: Label
var _premium_objective_summary_label: Label
var _premium_objective_progress_fill: ColorRect
var premium_side_panel: PanelContainer
var _premium_minimap_room_label: Label
var _premium_minimap_status_label: Label
var _premium_minimap_board: Control
var _premium_minimap_lobby_node: Button
var _premium_minimap_cafe_node: Button
var _premium_minimap_pool_node: Button
var _premium_map_lobby_btn: Button
var _premium_map_cafe_btn: Button
var _premium_map_pool_btn: Button
var _premium_map_more_btn: Button
var _premium_people_vbox: VBoxContainer
var _premium_map_badge_label: Label
var _premium_side_people_count_label: Label

var _social_person_clicked_cb = Callable()
var _on_minimap_room_requested: Callable = Callable()
var premium_bottom_bar: PanelContainer
var _premium_player_name_label: Label
var _premium_player_color: ColorRect
var _premium_bottom_hint_label: Label
var _premium_tab_room_btn: Button
var _premium_tab_decorate_btn: Button
var _premium_tab_shop_btn: Button
var _premium_tab_inventory_btn: Button
var _premium_tab_profile_btn: Button

var _on_top_change_room: Callable
var _on_top_open_shop: Callable
var _on_top_open_pause: Callable
var _on_top_open_help: Callable
var _on_side_map_lobby: Callable
var _on_side_map_small: Callable
var _on_side_map_large: Callable
var _on_side_map_more: Callable
var _on_bottom_explore: Callable
var _on_bottom_decorate: Callable
var _on_bottom_shop: Callable
var _on_bottom_inventory: Callable
var _on_bottom_profile: Callable
var _on_bottom_emotes: Callable
var _on_bottom_dance: Callable
var _on_bottom_music: Callable
var _on_bottom_photo: Callable
var _on_bottom_commands: Callable


func _init(root: Node, on_enter_hotel: Callable, on_room_selected: Callable, on_back_to_rooms: Callable, on_save_profile: Callable, on_chat_submitted: Callable = Callable(), on_catalog_selected: Callable = Callable()) -> void:
	_on_enter_hotel = on_enter_hotel
	_on_room_selected = on_room_selected
	_on_back_to_rooms = on_back_to_rooms
	_on_save_profile = on_save_profile
	_on_chat_submitted = on_chat_submitted
	_on_catalog_selected = on_catalog_selected
	setup_ui(root)


func setup_ui(root: Node) :
	var existing_ui: Node = root.get_node_or_null("UI")

	if existing_ui is CanvasLayer:
		ui_layer = existing_ui as CanvasLayer
	else:
		ui_layer = CanvasLayer.new()
		ui_layer.name = "UI"
		root.add_child(ui_layer)

	clear_children(ui_layer)

	_build_main_menu()
	_build_room_select()
	_build_profile_panel()
	_build_controls_panel()
	_build_inventory_panel()
	_build_chat_ui()
	_build_missions_panel()
	_build_furniture_inspector()
	_build_furniture_catalog()
	_build_overlap_selector()
	_build_shop_panel()
	_build_settings_panel()
	_build_pause_menu()
	_build_toast_panel()
	_build_tutorial_panel()
	_build_about_panel()
	build_premium_top_bar()
	build_premium_objective_panel()
	build_premium_side_panel()
	build_premium_bottom_bar()
	_build_splash_panel()


func _build_main_menu() :
	main_menu_panel = PanelContainer.new()
	main_menu_panel.name = "MainMenuPanel"
	main_menu_panel.anchor_left = 0.5
	main_menu_panel.anchor_top = 0.5
	main_menu_panel.anchor_right = 0.5
	main_menu_panel.anchor_bottom = 0.5
	main_menu_panel.offset_left = -180.0
	main_menu_panel.offset_top = -130.0
	main_menu_panel.offset_right = 180.0
	main_menu_panel.offset_bottom = 130.0
	ui_layer.add_child(main_menu_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	main_menu_panel.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	var title: Label = Label.new()
	title.text = GAME_TITLE
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)

	var version_label: Label = Label.new()
	version_label.text = GAME_VERSION
	version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(version_label)

	var enter_btn: Button = Button.new()
	enter_btn.text = "Entrar al hotel"
	enter_btn.pressed.connect(_on_enter_hotel_pressed)
	vbox.add_child(enter_btn)

	var profile_btn: Button = Button.new()
	profile_btn.text = "Perfil"
	profile_btn.pressed.connect(show_profile)
	vbox.add_child(profile_btn)

	var cfg_btn: Button = Button.new()
	cfg_btn.text = "Configuración"
	cfg_btn.pressed.connect(_on_main_menu_settings_pressed)
	vbox.add_child(cfg_btn)

	var about_btn: Button = Button.new()
	about_btn.text = "Acerca de"
	about_btn.pressed.connect(show_about_panel)
	vbox.add_child(about_btn)


func _build_room_select() :
	room_select_panel = PanelContainer.new()
	room_select_panel.name = "RoomSelectPanel"
	room_select_panel.anchor_left = 0.0
	room_select_panel.anchor_top = 0.0
	room_select_panel.anchor_right = 1.0
	room_select_panel.anchor_bottom = 1.0
	room_select_panel.offset_left = 0.0
	room_select_panel.offset_top = 0.0
	room_select_panel.offset_right = 0.0
	room_select_panel.offset_bottom = 0.0
	room_select_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	room_select_panel.add_theme_stylebox_override("panel", _make_premium_panel_style(Color(0.01, 0.015, 0.05, 0.66), 0))
	ui_layer.add_child(room_select_panel)

	var center_panel: PanelContainer = PanelContainer.new()
	center_panel.name = "RoomSelectCard"
	center_panel.anchor_left = 0.5
	center_panel.anchor_top = 0.5
	center_panel.anchor_right = 0.5
	center_panel.anchor_bottom = 0.5
	center_panel.offset_left = -270.0
	center_panel.offset_top = -230.0
	center_panel.offset_right = 270.0
	center_panel.offset_bottom = 230.0
	center_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	center_panel.add_theme_stylebox_override("panel", _make_premium_panel_style(Color(0.045, 0.058, 0.130, 0.96), 16))
	room_select_panel.add_child(center_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 26)
	center_panel.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Seleccionar sala"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", HUD_TEXT_MAIN)
	vbox.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = "Elige donde quieres entrar"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", HUD_TEXT_SECONDARY)
	vbox.add_child(subtitle)

	_room_cards_vbox = VBoxContainer.new()
	_room_cards_vbox.add_theme_constant_override("separation", 9)
	_room_cards_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(_room_cards_vbox)

	room_select_vbox = vbox

	# default buttons (kept for backward compatibility)
	_add_room_button(_room_cards_vbox, "lobby", "Lobby")
	_add_room_button(_room_cards_vbox, "room_small", "Sala pequeña")
	_add_room_button(_room_cards_vbox, "room_large", "Sala grande")

	var profile_btn: Button = Button.new()
	profile_btn.text = "Editar Perfil"
	profile_btn.custom_minimum_size = Vector2(0.0, 38.0)
	profile_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	profile_btn.add_theme_font_size_override("font_size", 13)
	profile_btn.add_theme_color_override("font_color", HUD_TEXT_MAIN)
	profile_btn.add_theme_stylebox_override("normal", _make_premium_button_style(Color(0.09, 0.12, 0.24, 0.88)))
	profile_btn.add_theme_stylebox_override("hover", _make_premium_button_style(Color(0.14, 0.18, 0.34, 0.94)))
	profile_btn.add_theme_stylebox_override("pressed", _make_premium_button_style(Color(0.18, 0.22, 0.38, 1.0)))
	profile_btn.pressed.connect(show_profile)
	vbox.add_child(profile_btn)


func _add_room_button(parent: VBoxContainer, room_id: String, label_text: String) :
	var btn: Button = Button.new()
	btn.text = _room_card_text(room_id, label_text)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.custom_minimum_size = Vector2(0.0, 70.0)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", HUD_TEXT_MAIN)
	btn.add_theme_color_override("font_hover_color", HUD_TEXT_MAIN)
	btn.add_theme_color_override("font_pressed_color", Color(0.10, 0.07, 0.04))
	btn.add_theme_stylebox_override("normal", _make_room_card_style(Color(0.075, 0.095, 0.190, 0.98), HUD_BORDER))
	btn.add_theme_stylebox_override("hover", _make_room_card_style(Color(0.110, 0.145, 0.270, 1.0), Color(1.0, 0.72, 0.36, 0.55)))
	btn.add_theme_stylebox_override("pressed", _make_room_card_style(HUD_ACCENT, Color(1.0, 0.88, 0.54, 0.90)))
	btn.pressed.connect(_on_room_button_pressed.bind(room_id))
	parent.add_child(btn)


func _room_card_text(room_id: String, label_text: String) -> String:
	var description: String = "Sala decorable"
	var badge: String = ""
	match room_id:
		"lobby":
			description = "Sala principal"
			badge = "Bot Guia disponible"
		"room_small":
			description = "Espacio compacto"
		"room_large":
			description = "Mas espacio para decorar"
	if badge != "":
		return label_text + "\n" + description + "  |  " + badge
	return label_text + "\n" + description


func _on_enter_hotel_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_enter_hotel.is_valid():
		_on_enter_hotel.call()


func _on_room_button_pressed(room_id: String) -> void:
	_play_ui_sound("ui_click")
	if _on_room_selected.is_valid():
		_on_room_selected.call(room_id)


func show_room_selector(rooms: Array) :
	if room_select_vbox == null or _room_cards_vbox == null:
		return
	# Clear legacy direct buttons if any, then rebuild the room cards.
	for child in room_select_vbox.get_children():
		if child is Button and child.text != "Editar Perfil":
			room_select_vbox.remove_child(child)
			child.queue_free()
	for child: Node in _room_cards_vbox.get_children():
		_room_cards_vbox.remove_child(child)
		child.queue_free()

	for r in rooms:
		var room_id: String = ""
		var r_label: String = ""
		
		# Handle Dictionary format
		if r is Dictionary and r.has("id") and r.has("label"):
			room_id = r["id"]
			r_label = r["label"]
		# Handle RefCounted format (RoomData objects) - access properties directly
		elif r is RefCounted:
			room_id = r.id
			r_label = r.display_name
		
		if room_id != "" and r_label != "":
			_add_room_button(_room_cards_vbox, room_id, r_label)

	# Make panel visible
	show_room_select()


func _build_profile_panel() -> void:
	_profile_shirt_btns.clear()
	_profile_pants_btns.clear()
	_profile_hair_color_btns.clear()
	_profile_skin_btns.clear()
	_profile_style_btns.clear()

	profile_panel = PanelContainer.new()
	profile_panel.name = "ProfilePanel"
	profile_panel.anchor_left = 0.5
	profile_panel.anchor_top = 0.5
	profile_panel.anchor_right = 0.5
	profile_panel.anchor_bottom = 0.5
	profile_panel.offset_left = -242.0
	profile_panel.offset_top = -218.0
	profile_panel.offset_right = 242.0
	profile_panel.offset_bottom = 218.0
	profile_panel.visible = false
	profile_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.12, 0.15, 0.22, 0.96)))
	ui_layer.add_child(profile_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	profile_panel.add_child(margin)

	var outer: HBoxContainer = HBoxContainer.new()
	outer.add_theme_constant_override("separation", 14)
	margin.add_child(outer)

	# ── LEFT: form ──
	var form: VBoxContainer = VBoxContainer.new()
	form.add_theme_constant_override("separation", 7)
	form.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_child(form)

	var title: Label = Label.new()
	title.text = "Perfil de jugador"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	form.add_child(title)

	var name_label: Label = Label.new()
	name_label.text = "Nombre:"
	name_label.add_theme_font_size_override("font_size", 12)
	form.add_child(name_label)

	profile_name_edit = LineEdit.new()
	profile_name_edit.max_length = 16
	form.add_child(profile_name_edit)

	_build_profile_color_row(form, "Camiseta:", [
		["Azul", Color(0.14, 0.32, 0.72)], ["Verde", Color(0.20, 0.55, 0.25)],
		["Rojo", Color(0.68, 0.14, 0.14)], ["Amarillo", Color(0.80, 0.65, 0.12)]
	], _profile_shirt_btns, func(i: int): _on_profile_shirt_selected(i))

	_build_profile_color_row(form, "Pantalón:", [
		["Osc", Color(0.14, 0.16, 0.30)], ["Negro", Color(0.10, 0.10, 0.12)],
		["Café", Color(0.36, 0.22, 0.10)]
	], _profile_pants_btns, func(i: int): _on_profile_pants_selected(i))

	_build_profile_color_row(form, "Pelo:", [
		["Café", Color(0.18, 0.10, 0.06)], ["Negro", Color(0.08, 0.06, 0.06)],
		["Rubio", Color(0.72, 0.54, 0.16)]
	], _profile_hair_color_btns, func(i: int): _on_profile_hair_color_selected(i))

	_build_profile_color_row(form, "Tono de piel:", [
		["Claro", Color(0.96, 0.82, 0.68)], ["Medio", Color(0.84, 0.62, 0.44)],
		["Oscuro", Color(0.60, 0.38, 0.22)]
	], _profile_skin_btns, func(i: int): _on_profile_skin_selected(i))

	_build_profile_style_row(form, "Peinado:", ["Corto", "Largo", "Sin pelo"],
		_profile_style_btns, func(i: int): _on_profile_style_selected(i))

	var footer: HBoxContainer = HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 12)
	form.add_child(footer)

	var save_btn: Button = Button.new()
	save_btn.text = "Guardar"
	save_btn.pressed.connect(_on_save_clicked)
	footer.add_child(save_btn)

	var back_btn: Button = Button.new()
	back_btn.text = "Volver"
	back_btn.pressed.connect(_on_profile_back_clicked)
	footer.add_child(back_btn)

	# ── RIGHT: preview ──
	var pv_vbox: VBoxContainer = VBoxContainer.new()
	pv_vbox.add_theme_constant_override("separation", 6)
	pv_vbox.custom_minimum_size = Vector2(118, 0)
	outer.add_child(pv_vbox)

	var pv_title: Label = Label.new()
	pv_title.text = "Vista previa"
	pv_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv_title.add_theme_font_size_override("font_size", 12)
	pv_vbox.add_child(pv_title)

	_profile_preview_root = Control.new()
	_profile_preview_root.name = "ProfilePreviewRoot"
	_profile_preview_root.custom_minimum_size = Vector2(110, 160)
	_profile_preview_root.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_profile_preview_root.clip_contents = true
	_profile_preview_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pv_bg: ColorRect = ColorRect.new()
	pv_bg.color = Color(0.16, 0.20, 0.28, 0.90)
	pv_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pv_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_profile_preview_root.add_child(pv_bg)
	var pv_avatar: Control = Control.new()
	pv_avatar.name = "AvatarPreview"
	pv_avatar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pv_avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_profile_preview_root.add_child(pv_avatar)
	pv_vbox.add_child(_profile_preview_root)


func _build_profile_color_row(parent: VBoxContainer, lbl: String, options: Array, btns: Array[Button], cb: Callable) -> void:
	var row: VBoxContainer = VBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	parent.add_child(row)
	var label: Label = Label.new()
	label.text = lbl
	label.add_theme_font_size_override("font_size", 11)
	row.add_child(label)
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	row.add_child(hbox)
	for i: int in options.size():
		var opt: Array = options[i] as Array
		var color: Color = opt[1] as Color
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(46, 24)
		btn.text = str(opt[0])
		btn.add_theme_font_size_override("font_size", 10)
		var st: StyleBoxFlat = StyleBoxFlat.new()
		st.bg_color = color
		st.corner_radius_top_left = 3; st.corner_radius_top_right = 3
		st.corner_radius_bottom_left = 3; st.corner_radius_bottom_right = 3
		btn.add_theme_stylebox_override("normal", st)
		var sth: StyleBoxFlat = st.duplicate() as StyleBoxFlat
		sth.bg_color = color.lightened(0.18)
		btn.add_theme_stylebox_override("hover", sth)
		var stp: StyleBoxFlat = st.duplicate() as StyleBoxFlat
		stp.bg_color = color.darkened(0.12)
		btn.add_theme_stylebox_override("pressed", stp)
		var lum: float = color.r * 0.299 + color.g * 0.587 + color.b * 0.114
		var tc: Color = Color.WHITE if lum < 0.5 else Color(0.08, 0.08, 0.08)
		btn.add_theme_color_override("font_color", tc)
		btn.add_theme_color_override("font_hover_color", tc)
		btn.add_theme_color_override("font_pressed_color", tc)
		_connect_profile_btn(btn, cb, i)
		hbox.add_child(btn)
		btns.append(btn)


func _build_profile_style_row(parent: VBoxContainer, lbl: String, opts: Array[String], btns: Array[Button], cb: Callable) -> void:
	var row: VBoxContainer = VBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	parent.add_child(row)
	var label: Label = Label.new()
	label.text = lbl
	label.add_theme_font_size_override("font_size", 11)
	row.add_child(label)
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	row.add_child(hbox)
	for i: int in opts.size():
		var btn: Button = Button.new()
		btn.custom_minimum_size = Vector2(56, 24)
		btn.text = opts[i]
		btn.add_theme_font_size_override("font_size", 10)
		_connect_profile_btn(btn, cb, i)
		hbox.add_child(btn)
		btns.append(btn)


func _connect_profile_btn(btn: Button, cb: Callable, idx: int) -> void:
	btn.pressed.connect(func(): cb.call(idx))


func _on_profile_shirt_selected(idx: int) -> void:
	var colors: Array = [Color(0.14, 0.32, 0.72), Color(0.20, 0.55, 0.25), Color(0.68, 0.14, 0.14), Color(0.80, 0.65, 0.12)]
	_profile_shirt_color = colors[idx]
	_set_btns_selected(_profile_shirt_btns, idx)
	_rebuild_avatar_preview()


func _on_profile_pants_selected(idx: int) -> void:
	var colors: Array = [Color(0.14, 0.16, 0.30), Color(0.10, 0.10, 0.12), Color(0.36, 0.22, 0.10)]
	_profile_pants_color = colors[idx]
	_set_btns_selected(_profile_pants_btns, idx)
	_rebuild_avatar_preview()


func _on_profile_hair_color_selected(idx: int) -> void:
	var colors: Array = [Color(0.18, 0.10, 0.06), Color(0.08, 0.06, 0.06), Color(0.72, 0.54, 0.16)]
	_profile_hair_color = colors[idx]
	_set_btns_selected(_profile_hair_color_btns, idx)
	_rebuild_avatar_preview()


func _on_profile_skin_selected(idx: int) -> void:
	var colors: Array = [Color(0.96, 0.82, 0.68), Color(0.84, 0.62, 0.44), Color(0.60, 0.38, 0.22)]
	_profile_skin_tone = colors[idx]
	_set_btns_selected(_profile_skin_btns, idx)
	_rebuild_avatar_preview()


func _on_profile_style_selected(idx: int) -> void:
	var styles: Array[String] = ["short", "long", "bald"]
	_profile_hair_style = styles[idx]
	_set_btns_selected(_profile_style_btns, idx)
	_rebuild_avatar_preview()


func _set_btns_selected(btns: Array[Button], active: int) -> void:
	for i: int in btns.size():
		btns[i].modulate = Color.WHITE if i == active else Color(0.52, 0.52, 0.52, 0.80)


func _sync_profile_button_states() -> void:
	var sc_opts: Array = [Color(0.14, 0.32, 0.72), Color(0.20, 0.55, 0.25), Color(0.68, 0.14, 0.14), Color(0.80, 0.65, 0.12)]
	var pc_opts: Array = [Color(0.14, 0.16, 0.30), Color(0.10, 0.10, 0.12), Color(0.36, 0.22, 0.10)]
	var hc_opts: Array = [Color(0.18, 0.10, 0.06), Color(0.08, 0.06, 0.06), Color(0.72, 0.54, 0.16)]
	var st_opts: Array = [Color(0.96, 0.82, 0.68), Color(0.84, 0.62, 0.44), Color(0.60, 0.38, 0.22)]
	var hs_opts: Array[String] = ["short", "long", "bald"]
	_set_btns_selected(_profile_shirt_btns, _find_nearest_color_idx(_profile_shirt_color, sc_opts))
	_set_btns_selected(_profile_pants_btns, _find_nearest_color_idx(_profile_pants_color, pc_opts))
	_set_btns_selected(_profile_hair_color_btns, _find_nearest_color_idx(_profile_hair_color, hc_opts))
	_set_btns_selected(_profile_skin_btns, _find_nearest_color_idx(_profile_skin_tone, st_opts))
	var si: int = hs_opts.find(_profile_hair_style)
	_set_btns_selected(_profile_style_btns, maxi(si, 0))


func _find_nearest_color_idx(target: Color, opts: Array) -> int:
	var best: int = 0
	var best_d: float = 1e9
	for i: int in opts.size():
		var o: Color = opts[i] as Color
		var d: float = (target.r - o.r) * (target.r - o.r) + (target.g - o.g) * (target.g - o.g) + (target.b - o.b) * (target.b - o.b)
		if d < best_d:
			best_d = d
			best = i
	return best


func _rebuild_avatar_preview() -> void:
	if _profile_preview_root == null:
		return
	var prev: Node = _profile_preview_root.find_child("AvatarPreview", false, false)
	if prev == null:
		return
	for child: Node in prev.get_children():
		prev.remove_child(child)
		child.queue_free()
	_draw_preview_avatar(prev as Control, _profile_shirt_color, _profile_pants_color, _profile_hair_color, _profile_skin_tone, _profile_hair_style)


func _draw_preview_avatar(root: Control, sc: Color, pc: Color, hc: Color, st: Color, hs: String) -> void:
	var cx: int = 55
	var gy: int = 140
	# Shadow
	_add_preview_rect(root, cx - 22, gy - 8, 44, 7, Color(0.04, 0.04, 0.06, 0.35))
	# Boots
	_add_preview_rect(root, cx - 18, gy - 15, 11, 7, Color(0.16, 0.09, 0.05))
	_add_preview_rect(root, cx + 8, gy - 15, 11, 7, Color(0.16, 0.09, 0.05))
	# Legs
	_add_preview_rect(root, cx - 16, gy - 31, 11, 17, pc)
	_add_preview_rect(root, cx + 6, gy - 31, 11, 17, pc)
	# Arms
	_add_preview_rect(root, cx - 24, gy - 52, 9, 17, sc.darkened(0.20))
	_add_preview_rect(root, cx + 16, gy - 52, 9, 17, sc.darkened(0.20))
	# Body
	_add_preview_rect(root, cx - 14, gy - 55, 28, 23, sc)
	# Shirt highlight
	_add_preview_rect(root, cx - 8, gy - 49, 16, 4, sc.lightened(0.35))
	# Collar
	_add_preview_rect(root, cx - 5, gy - 53, 10, 4, Color(0.88, 0.86, 0.82))
	# Head
	_add_preview_rect(root, cx - 14, gy - 81, 28, 26, st)
	# Skin highlight
	_add_preview_rect(root, cx - 9, gy - 81, 18, 4, Color(min(st.r + 0.10, 1.0), min(st.g + 0.12, 1.0), min(st.b + 0.12, 1.0), 0.50))
	# Cheeks
	_add_preview_rect(root, cx - 12, gy - 67, 5, 3, Color(0.90, 0.50, 0.42, 0.55))
	_add_preview_rect(root, cx + 8, gy - 67, 5, 3, Color(0.90, 0.50, 0.42, 0.55))
	# Eyes
	_add_preview_rect(root, cx - 9, gy - 73, 5, 5, Color(0.08, 0.06, 0.08))
	_add_preview_rect(root, cx + 5, gy - 73, 5, 5, Color(0.08, 0.06, 0.08))
	# Eye shine
	_add_preview_rect(root, cx - 8, gy - 74, 2, 2, Color.WHITE)
	_add_preview_rect(root, cx + 6, gy - 74, 2, 2, Color.WHITE)
	# Mouth
	_add_preview_rect(root, cx - 4, gy - 63, 8, 3, Color(0.58, 0.26, 0.18))
	# Hair
	match hs:
		"short":
			_add_preview_rect(root, cx - 15, gy - 90, 30, 10, hc)
			_add_preview_rect(root, cx - 15, gy - 82, 7, 9, hc)
			_add_preview_rect(root, cx + 7, gy - 83, 7, 6, hc)
		"long":
			_add_preview_rect(root, cx - 15, gy - 90, 30, 10, hc)
			_add_preview_rect(root, cx - 15, gy - 83, 7, 20, hc)
			_add_preview_rect(root, cx + 9, gy - 83, 7, 20, hc)
			_add_preview_rect(root, cx + 7, gy - 83, 7, 6, hc)
		"bald":
			pass


func _add_preview_rect(parent: Control, x: int, y: int, w: int, h: int, color: Color) -> void:
	var r: ColorRect = ColorRect.new()
	r.position = Vector2(x, y)
	r.size = Vector2(w, h)
	r.color = color
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)


func _on_save_clicked() -> void:
	var data: Dictionary = {
		"player_name": profile_name_edit.text,
		"shirt_color": _profile_shirt_color,
		"pants_color": _profile_pants_color,
		"hair_color": _profile_hair_color,
		"skin_tone": _profile_skin_tone,
		"hair_style": _profile_hair_style
	}
	_on_save_profile.call(data)


func _on_profile_back_clicked() -> void:
	_play_ui_sound("panel_close")
	profile_panel.visible = false
	show_missions_panel()


func show_profile() -> void:
	_play_ui_sound("panel_open")
	hide_shop_panel()
	hide_missions_panel()
	profile_panel.visible = true
	profile_panel.move_to_front()


func is_profile_open() -> bool:
	return profile_panel != null and profile_panel.visible


func update_profile_ui(profile_data: Dictionary) -> void:
	if profile_name_edit != null:
		profile_name_edit.text = str(profile_data.get("player_name", "Invitado"))
	_profile_shirt_color = profile_data.get("shirt_color", Color(0.14, 0.32, 0.72))
	_profile_pants_color = profile_data.get("pants_color", Color(0.14, 0.16, 0.30))
	_profile_hair_color = profile_data.get("hair_color", Color(0.18, 0.10, 0.06))
	_profile_skin_tone = profile_data.get("skin_tone", Color(0.84, 0.62, 0.44))
	_profile_hair_style = str(profile_data.get("hair_style", "short"))
	_sync_profile_button_states()
	_rebuild_avatar_preview()


func _build_controls_panel() :
	controls_panel = PanelContainer.new()
	controls_panel.name = "ControlsPanel"
	controls_panel.anchor_left = 0.0
	controls_panel.anchor_top = 1.0
	controls_panel.anchor_right = 1.0
	controls_panel.anchor_bottom = 1.0
	controls_panel.offset_left = 16.0
	controls_panel.offset_top = -72.0
	controls_panel.offset_right = -16.0
	controls_panel.offset_bottom = -16.0
	controls_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.17, 0.84)))
	ui_layer.add_child(controls_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	controls_panel.add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 6)
	margin.add_child(layout)

	var top_row: HBoxContainer = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 12)
	layout.add_child(top_row)

	room_label = Label.new()
	room_label.name = "RoomLabel"
	room_label.text = "Sala: Lobby"
	room_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	room_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	room_label.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0, 1.0))
	top_row.add_child(room_label)

	credits_label = Label.new()
	credits_label.name = "CreditsLabel"
	credits_label.text = "Créditos: 0"
	credits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	credits_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.48, 1.0))
	top_row.add_child(credits_label)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.visible = false
	ui_layer.add_child(status_label)

	_mode_button = Button.new()
	_mode_button.text = "Decorar"
	_mode_button.custom_minimum_size = Vector2(84.0, 0.0)
	_mode_button.pressed.connect(_on_mode_button_pressed)
	top_row.add_child(_mode_button)

	shop_button = Button.new()
	shop_button.text = "Tienda"
	shop_button.custom_minimum_size = Vector2(76.0, 0.0)
	shop_button.pressed.connect(_on_shop_button_pressed)
	shop_button.visible = false
	top_row.add_child(shop_button)

	help_button = Button.new()
	help_button.text = "Ayuda"
	help_button.custom_minimum_size = Vector2(68.0, 0.0)
	help_button.pressed.connect(_on_help_pressed)
	top_row.add_child(help_button)

	_pause_menu_btn = Button.new()
	_pause_menu_btn.text = "Menú"
	_pause_menu_btn.custom_minimum_size = Vector2(60.0, 0.0)
	_pause_menu_btn.pressed.connect(_on_pause_menu_btn_pressed)
	top_row.add_child(_pause_menu_btn)

	_settings_btn_in_room = Button.new()
	_settings_btn_in_room.visible = false
	ui_layer.add_child(_settings_btn_in_room)

	_hint_label = Label.new()
	_hint_label.name = "HintLabel"
	_hint_label.text = "Click para caminar · Enter chat · Tab decorar · Esc menú"
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_hint_label.add_theme_font_size_override("font_size", 12)
	_hint_label.add_theme_color_override("font_color", Color(0.65, 0.75, 0.88, 1.0))
	layout.add_child(_hint_label)


func _build_inventory_panel() :
	inventory_panel = PanelContainer.new()
	inventory_panel.name = "InventoryPanel"
	inventory_panel.anchor_left = 1.0
	inventory_panel.anchor_top = 0.5
	inventory_panel.anchor_right = 1.0
	inventory_panel.anchor_bottom = 0.5
	inventory_panel.offset_left = -196.0
	inventory_panel.offset_top = -120.0
	inventory_panel.offset_right = -16.0
	inventory_panel.offset_bottom = 120.0
	inventory_panel.visible = false
	inventory_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.17, 0.92)))
	ui_layer.add_child(inventory_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	inventory_panel.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Inventario"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	vbox.add_child(title)

	var items = [["1", "Silla"], ["2", "Mesa"], ["3", "Sofá"]]
	for item in items:
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		vbox.add_child(row)

		var key_label: Label = Label.new()
		key_label.text = "[" + item[0] + "]"
		key_label.custom_minimum_size = Vector2(28, 0)
		key_label.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
		row.add_child(key_label)

		var name_label: Label = Label.new()
		name_label.text = item[1]
		name_label.add_theme_color_override("font_color", Color(0.9, 0.93, 1.0))
		row.add_child(name_label)


func _build_missions_panel() -> void:
	missions_panel = PanelContainer.new()
	missions_panel.name = "MissionsPanel"
	missions_panel.anchor_left = 0.0
	missions_panel.anchor_top = 0.0
	missions_panel.anchor_right = 0.0
	missions_panel.anchor_bottom = 0.0
	missions_panel.offset_left = 16.0
	missions_panel.offset_top = 16.0
	missions_panel.offset_right = 330.0
	missions_panel.offset_bottom = 16.0
	missions_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	missions_panel.visible = false
	missions_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.17, 0.88)))
	ui_layer.add_child(missions_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	missions_panel.add_child(margin)

	_missions_list_vbox = VBoxContainer.new()
	_missions_list_vbox.add_theme_constant_override("separation", 3)
	margin.add_child(_missions_list_vbox)


func show_missions_panel() -> void:
	if not _missions_display_enabled:
		hide_premium_objective_panel()
		if missions_panel != null:
			missions_panel.visible = false
		return
	if premium_objective_panel != null:
		show_premium_objective_panel()
	elif missions_panel != null and not is_tutorial_visible():
		missions_panel.visible = true


func hide_missions_panel() -> void:
	if missions_panel != null:
		missions_panel.visible = false
	hide_premium_objective_panel()


func update_credits(amount: int) -> void:
	if credits_label != null:
		credits_label.text = "Créditos: " + str(amount)
	update_premium_credits(amount)


func update_missions(missions: Array[Dictionary]) -> void:
	update_missions_compact(missions)
	update_premium_objective(missions)


func show_mission_completed(mission_title: String) -> void:
	show_toast("Misión completada: " + mission_title, "success")


func _build_chat_ui() :
	chat_history_panel = PanelContainer.new()
	chat_history_panel.name = "ChatHistoryPanel"
	chat_history_panel.anchor_left = 0.0
	chat_history_panel.anchor_top = 1.0
	chat_history_panel.anchor_right = 0.0
	chat_history_panel.anchor_bottom = 1.0
	chat_history_panel.offset_left = CHAT_HISTORY_LEFT_MARGIN
	chat_history_panel.offset_top = -270.0
	chat_history_panel.offset_right = CHAT_HISTORY_LEFT_MARGIN + CHAT_HISTORY_WIDTH
	chat_history_panel.offset_bottom = -CHAT_HISTORY_BOTTOM_GAP
	chat_history_panel.visible = false
	chat_history_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.13, 0.70)))
	ui_layer.add_child(chat_history_panel)

	var history_margin: MarginContainer = MarginContainer.new()
	history_margin.add_theme_constant_override("margin_left", 12)
	history_margin.add_theme_constant_override("margin_top", 10)
	history_margin.add_theme_constant_override("margin_right", 12)
	history_margin.add_theme_constant_override("margin_bottom", 10)
	chat_history_panel.add_child(history_margin)

	chat_history_label = Label.new()
	chat_history_label.name = "ChatHistoryLabel"
	chat_history_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	chat_history_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	chat_history_label.add_theme_font_size_override("font_size", 14)
	chat_history_label.add_theme_color_override("font_color", Color(0.94, 0.97, 1.0, 1.0))
	history_margin.add_child(chat_history_label)

	chat_input_panel = PanelContainer.new()
	chat_input_panel.name = "ChatInputPanel"
	chat_input_panel.anchor_left = 0.5
	chat_input_panel.anchor_top = 1.0
	chat_input_panel.anchor_right = 0.5
	chat_input_panel.anchor_bottom = 1.0
	chat_input_panel.offset_left = -220.0
	chat_input_panel.offset_top = -162.0
	chat_input_panel.offset_right = 220.0
	chat_input_panel.offset_bottom = -114.0
	chat_input_panel.visible = false
	ui_layer.add_child(chat_input_panel)

	var input_margin: MarginContainer = MarginContainer.new()
	input_margin.add_theme_constant_override("margin_left", 10)
	input_margin.add_theme_constant_override("margin_top", 8)
	input_margin.add_theme_constant_override("margin_right", 10)
	input_margin.add_theme_constant_override("margin_bottom", 8)
	chat_input_panel.add_child(input_margin)

	chat_input = LineEdit.new()
	chat_input.name = "ChatInput"
	chat_input.max_length = 120
	chat_input.placeholder_text = "Escribe un mensaje y presiona Enter"
	chat_input.clear_button_enabled = true
	chat_input.text_submitted.connect(_on_chat_input_submitted)
	input_margin.add_child(chat_input)

	chat_bubble_panel = PanelContainer.new()
	chat_bubble_panel.name = "ChatBubblePanel"
	chat_bubble_panel.anchor_left = 0.0
	chat_bubble_panel.anchor_top = 0.0
	chat_bubble_panel.anchor_right = 0.0
	chat_bubble_panel.anchor_bottom = 0.0
	chat_bubble_panel.visible = false
	chat_bubble_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.95, 0.97, 1.0, 0.95)))
	ui_layer.add_child(chat_bubble_panel)

	var bubble_margin: MarginContainer = MarginContainer.new()
	bubble_margin.add_theme_constant_override("margin_left", 12)
	bubble_margin.add_theme_constant_override("margin_top", 8)
	bubble_margin.add_theme_constant_override("margin_right", 12)
	bubble_margin.add_theme_constant_override("margin_bottom", 8)
	chat_bubble_panel.add_child(bubble_margin)

	chat_bubble_label = Label.new()
	chat_bubble_label.name = "ChatBubbleLabel"
	chat_bubble_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	chat_bubble_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chat_bubble_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chat_bubble_label.add_theme_color_override("font_color", Color(0.12, 0.16, 0.22, 1.0))
	chat_bubble_label.add_theme_font_size_override("font_size", 14)
	bubble_margin.add_child(chat_bubble_label)

	npc_bubble_panel = PanelContainer.new()
	npc_bubble_panel.name = "NpcBubblePanel"
	npc_bubble_panel.anchor_left = 0.0
	npc_bubble_panel.anchor_top = 0.0
	npc_bubble_panel.anchor_right = 0.0
	npc_bubble_panel.anchor_bottom = 0.0
	npc_bubble_panel.visible = false
	npc_bubble_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(1.0, 0.96, 0.88, 0.95)))
	ui_layer.add_child(npc_bubble_panel)

	var npc_bubble_margin: MarginContainer = MarginContainer.new()
	npc_bubble_margin.add_theme_constant_override("margin_left", 12)
	npc_bubble_margin.add_theme_constant_override("margin_top", 8)
	npc_bubble_margin.add_theme_constant_override("margin_right", 12)
	npc_bubble_margin.add_theme_constant_override("margin_bottom", 8)
	npc_bubble_panel.add_child(npc_bubble_margin)

	npc_bubble_label = Label.new()
	npc_bubble_label.name = "NpcBubbleLabel"
	npc_bubble_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	npc_bubble_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	npc_bubble_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	npc_bubble_label.add_theme_color_override("font_color", Color(0.22, 0.12, 0.04, 1.0))
	npc_bubble_label.add_theme_font_size_override("font_size", 14)
	npc_bubble_margin.add_child(npc_bubble_label)


func _build_furniture_inspector() -> void:
	furniture_inspector_panel = PanelContainer.new()
	furniture_inspector_panel.name = "FurnitureInspectorPanel"
	furniture_inspector_panel.anchor_left = 0.0
	furniture_inspector_panel.anchor_top = 0.0
	furniture_inspector_panel.anchor_right = 0.0
	furniture_inspector_panel.anchor_bottom = 0.0
	furniture_inspector_panel.offset_left = 16.0
	furniture_inspector_panel.offset_top = 190.0
	furniture_inspector_panel.offset_right = 220.0
	furniture_inspector_panel.offset_bottom = 506.0
	furniture_inspector_panel.visible = false
	furniture_inspector_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.17, 0.92)))
	ui_layer.add_child(furniture_inspector_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	furniture_inspector_panel.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Inspector"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	vbox.add_child(title)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	_inspector_name_label = Label.new()
	_inspector_name_label.add_theme_font_size_override("font_size", 15)
	_inspector_name_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.75))
	vbox.add_child(_inspector_name_label)

	_inspector_cell_label = Label.new()
	_inspector_cell_label.add_theme_font_size_override("font_size", 13)
	_inspector_cell_label.add_theme_color_override("font_color", Color(0.80, 0.88, 1.0))
	vbox.add_child(_inspector_cell_label)

	_inspector_size_label = Label.new()
	_inspector_size_label.add_theme_font_size_override("font_size", 13)
	_inspector_size_label.add_theme_color_override("font_color", Color(0.80, 0.88, 1.0))
	vbox.add_child(_inspector_size_label)

	_inspector_state_label = Label.new()
	_inspector_state_label.add_theme_font_size_override("font_size", 13)
	_inspector_state_label.add_theme_color_override("font_color", Color(0.65, 0.90, 0.65))
	vbox.add_child(_inspector_state_label)

	_inspector_blocks_label = Label.new()
	_inspector_blocks_label.add_theme_font_size_override("font_size", 12)
	_inspector_blocks_label.add_theme_color_override("font_color", Color(0.78, 0.78, 0.78))
	vbox.add_child(_inspector_blocks_label)

	_inspector_layer_label = Label.new()
	_inspector_layer_label.add_theme_font_size_override("font_size", 12)
	_inspector_layer_label.add_theme_color_override("font_color", Color(0.72, 0.82, 0.96))
	vbox.add_child(_inspector_layer_label)

	var btn_sep: HSeparator = HSeparator.new()
	vbox.add_child(btn_sep)

	var btn_grid: HBoxContainer = HBoxContainer.new()
	btn_grid.add_theme_constant_override("separation", 4)
	vbox.add_child(btn_grid)

	var move_btn: Button = Button.new()
	move_btn.text = "Mover"
	move_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	move_btn.pressed.connect(_on_inspector_move_pressed)
	btn_grid.add_child(move_btn)

	var rotate_btn: Button = Button.new()
	rotate_btn.text = "Rotar"
	rotate_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rotate_btn.pressed.connect(_on_inspector_rotate_pressed)
	btn_grid.add_child(rotate_btn)

	var btn_row2: HBoxContainer = HBoxContainer.new()
	btn_row2.add_theme_constant_override("separation", 4)
	vbox.add_child(btn_row2)

	var delete_btn: Button = Button.new()
	delete_btn.text = "Eliminar"
	delete_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	delete_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	delete_btn.pressed.connect(_on_inspector_delete_pressed)
	btn_row2.add_child(delete_btn)

	var close_btn: Button = Button.new()
	close_btn.text = "Cerrar"
	close_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_btn.pressed.connect(_on_inspector_close_pressed)
	btn_row2.add_child(close_btn)


func setup_furniture_inspector_callbacks(move_cb: Callable, rotate_cb: Callable, delete_cb: Callable, close_cb: Callable) -> void:
	_on_inspector_move = move_cb
	_on_inspector_rotate = rotate_cb
	_on_inspector_delete = delete_cb
	_on_inspector_close = close_cb


func show_furniture_inspector(furniture: Object) -> void:
	if furniture_inspector_panel == null:
		return
	furniture_inspector_panel.visible = true
	_update_inspector_data(furniture)


func hide_furniture_inspector() -> void:
	if furniture_inspector_panel != null:
		furniture_inspector_panel.visible = false


func is_furniture_inspector_visible() -> bool:
	return furniture_inspector_panel != null and furniture_inspector_panel.visible


func update_furniture_inspector(furniture: Object) -> void:
	if furniture_inspector_panel == null or not furniture_inspector_panel.visible:
		return
	_update_inspector_data(furniture)


func set_furniture_inspector_message(message: String) -> void:
	if _inspector_state_label != null:
		_inspector_state_label.text = message


func _update_inspector_data(furniture: Object) -> void:
	_inspector_name_label.text = _inspector_display_name(str(furniture.get("type")))
	var cell: Vector2i = furniture.get("cell")
	_inspector_cell_label.text = "Pos: " + str(cell.x) + ", " + str(cell.y)
	var size: Vector2i = furniture.get("size")
	_inspector_size_label.text = "Tamaño: " + str(size.x) + "×" + str(size.y)
	_inspector_state_label.text = "Seleccionado"
	var bm: Variant = furniture.get("blocks_movement")
	var blocks: bool = bm == null or bool(bm)
	_inspector_blocks_label.text = "Bloquea paso: " + ("Sí" if blocks else "No")
	var layer_val: Variant = furniture.get("layer")
	_inspector_layer_label.text = "Capa: " + _layer_display_name(str(layer_val) if layer_val != null else "furniture")


func _layer_display_name(layer: String) -> String:
	match layer:
		"floor": return "Piso"
		"furniture": return "Mueble"
		"decor": return "Decoración"
	return layer


func _inspector_display_name(furniture_type: String) -> String:
	match furniture_type:
		"chair":       return "Silla"
		"table":       return "Mesa"
		"sofa":        return "Sofá"
		"plant":       return "Planta"
		"rug":         return "Alfombra"
		"blue_rug":    return "Alfombra Azul"
		"golden_plant":return "Planta Dorada"
		"lounge_chair":return "Sillón Lounge"
		"bed":         return "Cama"
		"lamp":        return "Lámpara"
		"bookshelf":   return "Estantería"
		"desk":        return "Escritorio"
		"poster":      return "Póster"
		"big_plant":   return "Maceta grande"
		"red_rug":     return "Alfombra Roja"
		"floor_tile":  return "Piso decorativo"
	return furniture_type


func _on_inspector_move_pressed() -> void:
	if is_chat_input_active():
		return
	_play_ui_sound("ui_click")
	if _on_inspector_move.is_valid():
		_on_inspector_move.call()


func _on_inspector_rotate_pressed() -> void:
	if is_chat_input_active():
		return
	if _on_inspector_rotate.is_valid():
		_on_inspector_rotate.call()


func _on_inspector_delete_pressed() -> void:
	if is_chat_input_active():
		return
	if _on_inspector_delete.is_valid():
		_on_inspector_delete.call()


func _on_inspector_close_pressed() -> void:
	_play_ui_sound("panel_close")
	if _on_inspector_close.is_valid():
		_on_inspector_close.call()


func _build_furniture_catalog() -> void:
	catalog_panel = PanelContainer.new()
	catalog_panel.name = "CatalogPanel"
	catalog_panel.anchor_left = 1.0
	catalog_panel.anchor_top = 0.0
	catalog_panel.anchor_right = 1.0
	catalog_panel.anchor_bottom = 1.0
	catalog_panel.offset_left = -176.0
	catalog_panel.offset_top = 78.0
	catalog_panel.offset_right = -14.0
	catalog_panel.offset_bottom = -112.0
	catalog_panel.visible = false
	catalog_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.17, 0.90)))
	ui_layer.add_child(catalog_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	catalog_panel.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Catálogo"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	vbox.add_child(title)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	_catalog_tab_hbox = HBoxContainer.new()
	_catalog_tab_hbox.add_theme_constant_override("separation", 2)
	vbox.add_child(_catalog_tab_hbox)

	var sep2: HSeparator = HSeparator.new()
	vbox.add_child(sep2)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)

	_catalog_items_vbox = VBoxContainer.new()
	_catalog_items_vbox.add_theme_constant_override("separation", 4)
	_catalog_items_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_catalog_items_vbox)


func build_furniture_catalog(catalog_data: Dictionary) -> void:
	_catalog_data = catalog_data
	_catalog_categories.clear()
	for type: String in catalog_data:
		var cat: String = catalog_data[type].get("category", "")
		if cat != "" and not _catalog_categories.has(cat):
			_catalog_categories.append(cat)
	_rebuild_catalog_tab_buttons()
	if not _catalog_categories.is_empty():
		set_catalog_category(_catalog_categories[0])


func _rebuild_catalog_tab_buttons() -> void:
	if _catalog_tab_hbox == null:
		return
	for child: Node in _catalog_tab_hbox.get_children():
		_catalog_tab_hbox.remove_child(child)
		child.queue_free()
	_catalog_tab_buttons.clear()
	for cat: String in _catalog_categories:
		var btn: Button = Button.new()
		btn.text = cat
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 11)
		btn.pressed.connect(set_catalog_category.bind(cat))
		_catalog_tab_hbox.add_child(btn)
		_catalog_tab_buttons.append(btn)


func set_catalog_category(category: String) -> void:
	_current_category = category
	var active_style: StyleBoxFlat = StyleBoxFlat.new()
	active_style.bg_color = Color(0.20, 0.38, 0.58, 0.92)
	active_style.corner_radius_top_left = 4
	active_style.corner_radius_top_right = 4
	active_style.corner_radius_bottom_right = 4
	active_style.corner_radius_bottom_left = 4
	for i: int in range(_catalog_tab_buttons.size()):
		if i < _catalog_categories.size() and _catalog_categories[i] == category:
			_catalog_tab_buttons[i].add_theme_stylebox_override("normal", active_style)
			_catalog_tab_buttons[i].add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		else:
			_catalog_tab_buttons[i].remove_theme_stylebox_override("normal")
			_catalog_tab_buttons[i].remove_theme_color_override("font_color")
	_rebuild_catalog_items()


func _rebuild_catalog_items() -> void:
	if _catalog_items_vbox == null:
		return
	for child: Node in _catalog_items_vbox.get_children():
		_catalog_items_vbox.remove_child(child)
		child.queue_free()
	_catalog_item_buttons.clear()
	_catalog_item_types.clear()
	for type: String in _catalog_data:
		var info: Dictionary = _catalog_data[type]
		if info.get("category", "") != _current_category:
			continue
		var shortcut: int = info.get("shortcut", 0)
		var shortcut_text: String = ""
		if shortcut != 0:
			shortcut_text = "[" + _shortcut_key_label(shortcut) + "] "
		var sz: Vector2i = info.get("size", Vector2i(1, 1))
		var is_limited: bool = info.has("stock")
		var stock: int = int(info.get("stock", 0)) if is_limited else -1
		var stock_suffix: String = ""
		if is_limited:
			stock_suffix = "  x" + str(stock)
		else:
			stock_suffix = "  ∞"
		var btn: Button = Button.new()
		btn.text = shortcut_text + info.get("display_name", type) + "  " + str(sz.x) + "×" + str(sz.y) + stock_suffix
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 13)
		if is_limited and stock == 0:
			btn.add_theme_color_override("font_color", Color(0.55, 0.55, 0.60))
		btn.pressed.connect(_on_catalog_item_pressed.bind(type))
		_catalog_items_vbox.add_child(btn)
		_catalog_item_buttons.append(btn)
		_catalog_item_types.append(type)
	_apply_catalog_item_highlight()


func _apply_catalog_item_highlight() -> void:
	var sel_style: StyleBoxFlat = StyleBoxFlat.new()
	sel_style.bg_color = Color(0.12, 0.40, 0.18, 0.92)
	sel_style.corner_radius_top_left = 6
	sel_style.corner_radius_top_right = 6
	sel_style.corner_radius_bottom_right = 6
	sel_style.corner_radius_bottom_left = 6
	sel_style.border_color = Color(0.35, 0.85, 0.42, 1.0)
	sel_style.border_width_left = 2
	sel_style.border_width_top = 2
	sel_style.border_width_right = 2
	sel_style.border_width_bottom = 2
	for i: int in range(_catalog_item_buttons.size()):
		if i < _catalog_item_types.size() and _catalog_item_types[i] == _catalog_selected_type:
			_catalog_item_buttons[i].add_theme_stylebox_override("normal", sel_style)
			_catalog_item_buttons[i].add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		else:
			_catalog_item_buttons[i].remove_theme_stylebox_override("normal")
			_catalog_item_buttons[i].remove_theme_color_override("font_color")


func _on_catalog_item_pressed(type: String) -> void:
	if is_chat_input_active():
		return
	_play_ui_sound("ui_click")
	if _on_catalog_selected.is_valid():
		_on_catalog_selected.call(type)


func set_catalog_selected_furniture(furniture_type: String) -> void:
	_catalog_selected_type = furniture_type
	if _catalog_data.has(furniture_type):
		var cat: String = _catalog_data[furniture_type].get("category", "")
		if cat != "" and cat != _current_category:
			set_catalog_category(cat)
			return
	_apply_catalog_item_highlight()


func _shortcut_key_label(keycode: int) -> String:
	match keycode:
		KEY_1: return "1"
		KEY_2: return "2"
		KEY_3: return "3"
	return ""


func _build_overlap_selector() -> void:
	overlap_selector_panel = PanelContainer.new()
	overlap_selector_panel.name = "OverlapSelectorPanel"
	overlap_selector_panel.anchor_left = 0.5
	overlap_selector_panel.anchor_top = 0.5
	overlap_selector_panel.anchor_right = 0.5
	overlap_selector_panel.anchor_bottom = 0.5
	overlap_selector_panel.offset_left = -120.0
	overlap_selector_panel.offset_top = -110.0
	overlap_selector_panel.offset_right = 120.0
	overlap_selector_panel.offset_bottom = 110.0
	overlap_selector_panel.visible = false
	overlap_selector_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.17, 0.95)))
	ui_layer.add_child(overlap_selector_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	overlap_selector_panel.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Seleccionar objeto"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0))
	vbox.add_child(title)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	_overlap_items_vbox = VBoxContainer.new()
	_overlap_items_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(_overlap_items_vbox)

	var sep2: HSeparator = HSeparator.new()
	vbox.add_child(sep2)

	var close_btn: Button = Button.new()
	close_btn.text = "Cerrar"
	close_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_btn.pressed.connect(_on_overlap_close_pressed)
	vbox.add_child(close_btn)


func setup_overlap_selector_callbacks(item_selected_cb: Callable, closed_cb: Callable) -> void:
	_on_overlap_item_selected = item_selected_cb
	_on_overlap_selector_closed = closed_cb


func set_tutorial_closed_callback(callback: Callable) -> void:
	_on_tutorial_closed = callback


func set_tutorial_open_requested_callback(callback: Callable) -> void:
	_on_tutorial_open_requested = callback


func set_shop_item_buy_callback(callback: Callable) -> void:
	_on_shop_item_buy = callback


func set_shop_closed_callback(callback: Callable) -> void:
	_on_shop_closed = callback


func set_mode_toggle_callback(callback: Callable) -> void:
	_on_mode_toggle = callback


func update_mode_button(mode: String) -> void:
	if _mode_button == null:
		return
	if mode == "decoration":
		_mode_button.text = "Explorar"
	else:
		_mode_button.text = "Decorar"
	set_premium_room_mode(mode)


func show_exploration_ui() -> void:
	hide_shop_button()
	show_premium_side_panel()
	update_context_hint("exploration")
	set_premium_room_mode("exploration")


func show_decoration_ui() -> void:
	show_shop_button()
	hide_premium_side_panel()
	update_context_hint("decoration")
	set_premium_room_mode("decoration")


func update_context_hint(mode: String, submode: String = "") -> void:
	match submode:
		"placing":
			update_premium_bottom_hint("Elige destino · verde válido · Esc cancelar")
		"moving":
			update_premium_bottom_hint("Moviendo mueble · elige destino")
		"chat":
			update_premium_bottom_hint("Chat activo · Enter enviar · Esc cancelar")
		_:
			if mode == "decoration":
				update_premium_bottom_hint("Elige un mueble · Click para colocar/seleccionar · Tab para explorar")
			else:
				update_premium_bottom_hint("Click para caminar · Enter para chatear · Tab para decorar")
	if _hint_label == null:
		return
	match submode:
		"placing":
			_hint_label.text = "Colocando: verde = válido · rojo = inválido · Esc cancelar"
			return
		"moving":
			_hint_label.text = "Moviendo mueble: elige destino · Esc cancelar"
			return
		"chat":
			_hint_label.text = "Chat: escribe y presiona Enter · Esc cancelar"
			return
	match mode:
		"decoration":
			_hint_label.text = "Catálogo activo · Click colocar/seleccionar · Tab explorar · Esc cancelar"
		_:
			_hint_label.text = "Click para caminar · Enter chat · Tab decorar · Esc menú"


func update_missions_compact(missions: Array[Dictionary]) -> void:
	if _missions_list_vbox == null:
		return
	for child: Node in _missions_list_vbox.get_children():
		_missions_list_vbox.remove_child(child)
		child.queue_free()

	var pending: Array[Dictionary] = []
	var completed_count: int = 0
	for m: Dictionary in missions:
		if bool(m.get("completed", false)):
			completed_count += 1
		else:
			pending.append(m)

	if pending.is_empty():
		var lbl: Label = Label.new()
		lbl.text = "✓ Misiones iniciales completas"
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(0.70, 0.94, 0.72))
		_missions_list_vbox.add_child(lbl)
		return

	var first: Dictionary = pending[0]
	var reward: int = int(first.get("reward_credits", 0))
	var lbl: Label = Label.new()
	lbl.text = "Objetivo: " + str(first.get("title", "")) + " (+" + str(reward) + ")"
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(0.86, 0.90, 0.96))
	lbl.tooltip_text = str(first.get("description", ""))
	_missions_list_vbox.add_child(lbl)

	if pending.size() > 1:
		var more: Label = Label.new()
		more.text = "+" + str(pending.size() - 1) + " pendientes"
		more.add_theme_font_size_override("font_size", 11)
		more.add_theme_color_override("font_color", Color(0.55, 0.65, 0.80))
		_missions_list_vbox.add_child(more)


func _on_mode_button_pressed() -> void:
	if is_chat_input_active():
		return
	_play_ui_sound("ui_click")
	if _on_mode_toggle.is_valid():
		_on_mode_toggle.call()


func _on_in_room_settings_pressed() -> void:
	if is_chat_input_active():
		return
	if _on_open_settings_cb.is_valid():
		_on_open_settings_cb.call()


func _on_main_menu_settings_pressed() -> void:
	if _on_open_settings_cb.is_valid():
		_on_open_settings_cb.call()


func set_open_settings_callback(cb: Callable) -> void:
	_on_open_settings_cb = cb


func _build_settings_panel() -> void:
	settings_panel = PanelContainer.new()
	settings_panel.name = "SettingsPanel"
	settings_panel.anchor_left = 0.5
	settings_panel.anchor_top = 0.5
	settings_panel.anchor_right = 0.5
	settings_panel.anchor_bottom = 0.5
	settings_panel.offset_left = -220.0
	settings_panel.offset_top = -280.0
	settings_panel.offset_right = 220.0
	settings_panel.offset_bottom = 280.0
	settings_panel.visible = false
	settings_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.17, 0.97)))
	ui_layer.add_child(settings_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 16)
	settings_panel.add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	margin.add_child(layout)

	var title: Label = Label.new()
	title.text = "Configuración"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.72))
	layout.add_child(title)

	layout.add_child(HSeparator.new())

	var autosave_row: HBoxContainer = HBoxContainer.new()
	autosave_row.add_theme_constant_override("separation", 8)
	layout.add_child(autosave_row)
	var autosave_lbl: Label = Label.new()
	autosave_lbl.text = "Guardado automático"
	autosave_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	autosave_lbl.add_theme_color_override("font_color", Color(0.88, 0.92, 1.0))
	autosave_row.add_child(autosave_lbl)
	_settings_autosave_toggle_btn = Button.new()
	_settings_autosave_toggle_btn.text = "Activado"
	_settings_autosave_toggle_btn.custom_minimum_size = Vector2(96.0, 0.0)
	_settings_autosave_toggle_btn.pressed.connect(_on_settings_autosave_toggle_pressed)
	autosave_row.add_child(_settings_autosave_toggle_btn)

	var interval_row: HBoxContainer = HBoxContainer.new()
	interval_row.add_theme_constant_override("separation", 4)
	layout.add_child(interval_row)
	var interval_lbl: Label = Label.new()
	interval_lbl.text = "Intervalo:"
	interval_lbl.add_theme_color_override("font_color", Color(0.72, 0.80, 0.92))
	interval_lbl.add_theme_font_size_override("font_size", 12)
	interval_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	interval_row.add_child(interval_lbl)
	_settings_interval_btns.clear()
	for secs: float in [30.0, 60.0, 120.0]:
		var ibtn: Button = Button.new()
		ibtn.text = str(int(secs)) + "s"
		ibtn.custom_minimum_size = Vector2(48.0, 0.0)
		ibtn.pressed.connect(_on_settings_interval_pressed.bind(secs))
		interval_row.add_child(ibtn)
		_settings_interval_btns.append(ibtn)

	layout.add_child(HSeparator.new())

	var sfx_row: HBoxContainer = HBoxContainer.new()
	sfx_row.add_theme_constant_override("separation", 8)
	layout.add_child(sfx_row)
	var sfx_lbl: Label = Label.new()
	sfx_lbl.text = "Sonidos"
	sfx_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_lbl.add_theme_color_override("font_color", Color(0.88, 0.92, 1.0))
	sfx_row.add_child(sfx_lbl)
	_settings_sfx_toggle_btn = Button.new()
	_settings_sfx_toggle_btn.text = "Activado"
	_settings_sfx_toggle_btn.custom_minimum_size = Vector2(96.0, 0.0)
	_settings_sfx_toggle_btn.pressed.connect(_on_settings_sfx_toggle_pressed)
	sfx_row.add_child(_settings_sfx_toggle_btn)

	var sfx_volume_row: HBoxContainer = HBoxContainer.new()
	sfx_volume_row.add_theme_constant_override("separation", 4)
	layout.add_child(sfx_volume_row)
	var sfx_volume_lbl: Label = Label.new()
	sfx_volume_lbl.text = "Volumen SFX:"
	sfx_volume_lbl.add_theme_color_override("font_color", Color(0.72, 0.80, 0.92))
	sfx_volume_lbl.add_theme_font_size_override("font_size", 12)
	sfx_volume_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sfx_volume_row.add_child(sfx_volume_lbl)
	_settings_sfx_volume_btns.clear()
	for vol: float in [0.25, 0.5, 0.75, 1.0]:
		var vbtn: Button = Button.new()
		vbtn.text = str(int(vol * 100.0)) + "%"
		vbtn.custom_minimum_size = Vector2(48.0, 0.0)
		vbtn.pressed.connect(_on_settings_sfx_volume_pressed.bind(vol))
		sfx_volume_row.add_child(vbtn)
		_settings_sfx_volume_btns.append(vbtn)

	layout.add_child(HSeparator.new())

	var missions_row: HBoxContainer = HBoxContainer.new()
	missions_row.add_theme_constant_override("separation", 8)
	layout.add_child(missions_row)
	var missions_lbl: Label = Label.new()
	missions_lbl.text = "Mostrar misiones"
	missions_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	missions_lbl.add_theme_color_override("font_color", Color(0.88, 0.92, 1.0))
	missions_row.add_child(missions_lbl)
	_settings_missions_btn = Button.new()
	_settings_missions_btn.text = "Sí"
	_settings_missions_btn.custom_minimum_size = Vector2(96.0, 0.0)
	_settings_missions_btn.pressed.connect(_on_settings_missions_toggle_pressed)
	missions_row.add_child(_settings_missions_btn)

	layout.add_child(HSeparator.new())

	var tutorial_btn: Button = Button.new()
	tutorial_btn.text = "Reiniciar tutorial"
	tutorial_btn.pressed.connect(_on_settings_tutorial_restart_pressed)
	layout.add_child(tutorial_btn)

	layout.add_child(HSeparator.new())

	var reset_btn: Button = Button.new()
	reset_btn.text = "Resetear datos locales"
	reset_btn.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	reset_btn.pressed.connect(_on_settings_reset_pressed)
	layout.add_child(reset_btn)

	layout.add_child(HSeparator.new())

	var close_btn: Button = Button.new()
	close_btn.text = "Cerrar"
	close_btn.pressed.connect(_on_settings_close_pressed)
	layout.add_child(close_btn)

	_build_confirm_reset_panel()


func _build_confirm_reset_panel() -> void:
	_confirm_reset_panel = PanelContainer.new()
	_confirm_reset_panel.name = "ConfirmResetPanel"
	_confirm_reset_panel.anchor_left = 0.5
	_confirm_reset_panel.anchor_top = 0.5
	_confirm_reset_panel.anchor_right = 0.5
	_confirm_reset_panel.anchor_bottom = 0.5
	_confirm_reset_panel.offset_left = -210.0
	_confirm_reset_panel.offset_top = -80.0
	_confirm_reset_panel.offset_right = 210.0
	_confirm_reset_panel.offset_bottom = 80.0
	_confirm_reset_panel.visible = false
	_confirm_reset_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.20, 0.07, 0.07, 0.98)))
	ui_layer.add_child(_confirm_reset_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	_confirm_reset_panel.add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)

	var msg: Label = Label.new()
	msg.text = "Esto borrará salas, perfil, créditos, tienda, stock, misiones y tutorial. ¿Continuar?"
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 13)
	msg.add_theme_color_override("font_color", Color(1.0, 0.82, 0.82))
	layout.add_child(msg)

	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 12)
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_child(btn_row)

	var cancel_btn: Button = Button.new()
	cancel_btn.text = "Cancelar"
	cancel_btn.pressed.connect(func() -> void: _confirm_reset_panel.visible = false)
	btn_row.add_child(cancel_btn)

	var confirm_btn: Button = Button.new()
	confirm_btn.text = "Sí, resetear"
	confirm_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	confirm_btn.pressed.connect(_on_settings_confirm_reset_pressed)
	btn_row.add_child(confirm_btn)


func show_settings_panel(settings_data: Dictionary) -> void:
	update_settings_panel(settings_data)
	if settings_panel != null:
		_play_ui_sound("panel_open")
		settings_panel.visible = true
		settings_panel.move_to_front()


func hide_settings_panel() -> void:
	if _confirm_reset_panel != null:
		_confirm_reset_panel.visible = false
	if settings_panel != null:
		if settings_panel.visible:
			_play_ui_sound("panel_close")
		settings_panel.visible = false
	if _on_settings_closed_cb.is_valid():
		_on_settings_closed_cb.call()


func is_settings_visible() -> bool:
	return settings_panel != null and settings_panel.visible


func update_settings_panel(settings_data: Dictionary) -> void:
	if settings_data.is_empty():
		return
	var autosave_on: bool = bool(settings_data.get("autosave_enabled", true))
	if _settings_autosave_toggle_btn != null:
		_settings_autosave_toggle_btn.text = "Activado" if autosave_on else "Desactivado"
	var interval: float = float(settings_data.get("autosave_interval", 60.0))
	var active_style: StyleBoxFlat = StyleBoxFlat.new()
	active_style.bg_color = Color(0.20, 0.38, 0.58, 0.92)
	active_style.corner_radius_top_left = 4
	active_style.corner_radius_top_right = 4
	active_style.corner_radius_bottom_right = 4
	active_style.corner_radius_bottom_left = 4
	var intervals: Array[float] = [30.0, 60.0, 120.0]
	for i: int in range(_settings_interval_btns.size()):
		if i < intervals.size() and is_equal_approx(intervals[i], interval):
			_settings_interval_btns[i].add_theme_stylebox_override("normal", active_style)
		else:
			_settings_interval_btns[i].remove_theme_stylebox_override("normal")
	var show_m: bool = bool(settings_data.get("show_missions", true))
	_missions_display_enabled = show_m
	if not show_m:
		hide_premium_objective_panel()
	if _settings_missions_btn != null:
		_settings_missions_btn.text = "Sí" if show_m else "No"


	_sync_sfx_settings_controls(settings_data, active_style)


func _sync_sfx_settings_controls(settings_data: Dictionary, active_style: StyleBoxFlat) -> void:
	var sfx_on: bool = bool(settings_data.get("sfx_enabled", true))
	if _settings_sfx_toggle_btn != null:
		_settings_sfx_toggle_btn.text = "Activado" if sfx_on else "Desactivado"
	var sfx_volume: float = float(settings_data.get("sfx_volume", 0.7))
	var volumes: Array[float] = [0.25, 0.5, 0.75, 1.0]
	for i: int in range(_settings_sfx_volume_btns.size()):
		if i < volumes.size() and is_equal_approx(volumes[i], sfx_volume):
			_settings_sfx_volume_btns[i].add_theme_stylebox_override("normal", active_style)
		else:
			_settings_sfx_volume_btns[i].remove_theme_stylebox_override("normal")


func set_settings_autosave_enabled_callback(cb: Callable) -> void:
	_on_settings_autosave_enabled = cb


func set_settings_autosave_interval_callback(cb: Callable) -> void:
	_on_settings_autosave_interval = cb


func set_settings_show_missions_callback(cb: Callable) -> void:
	_on_settings_show_missions = cb


func set_settings_sfx_enabled_callback(cb: Callable) -> void:
	_on_settings_sfx_enabled = cb


func set_settings_sfx_volume_callback(cb: Callable) -> void:
	_on_settings_sfx_volume = cb


func set_settings_tutorial_restart_callback(cb: Callable) -> void:
	_on_settings_tutorial_restart = cb


func set_settings_reset_data_callback(cb: Callable) -> void:
	_on_settings_reset_data = cb


func set_settings_closed_callback(cb: Callable) -> void:
	_on_settings_closed_cb = cb


func set_ui_sound_callback(cb: Callable) -> void:
	_on_ui_sound = cb


func _play_ui_sound(sound_id: String) -> void:
	if _on_ui_sound.is_valid():
		_on_ui_sound.call(sound_id)


func _on_settings_autosave_toggle_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_settings_autosave_enabled.is_valid():
		var new_val: bool = _settings_autosave_toggle_btn != null and _settings_autosave_toggle_btn.text == "Desactivado"
		_on_settings_autosave_enabled.call(new_val)


func _on_settings_interval_pressed(seconds: float) -> void:
	_play_ui_sound("ui_click")
	if _on_settings_autosave_interval.is_valid():
		_on_settings_autosave_interval.call(seconds)


func _on_settings_missions_toggle_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_settings_show_missions.is_valid():
		var new_val: bool = _settings_missions_btn != null and _settings_missions_btn.text == "No"
		_on_settings_show_missions.call(new_val)


func _on_settings_sfx_toggle_pressed() -> void:
	if _on_settings_sfx_enabled.is_valid():
		var new_val: bool = _settings_sfx_toggle_btn != null and _settings_sfx_toggle_btn.text == "Desactivado"
		_on_settings_sfx_enabled.call(new_val)
	_play_ui_sound("ui_click")


func _on_settings_sfx_volume_pressed(value: float) -> void:
	if _on_settings_sfx_volume.is_valid():
		_on_settings_sfx_volume.call(value)
	_play_ui_sound("ui_click")


func _on_settings_tutorial_restart_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_settings_tutorial_restart.is_valid():
		_on_settings_tutorial_restart.call()


func _on_settings_reset_pressed() -> void:
	_play_ui_sound("ui_click")
	if _confirm_reset_panel != null:
		_confirm_reset_panel.visible = true
		_confirm_reset_panel.move_to_front()


func _on_settings_confirm_reset_pressed() -> void:
	_play_ui_sound("ui_click")
	if _confirm_reset_panel != null:
		_confirm_reset_panel.visible = false
	if _on_settings_reset_data.is_valid():
		_on_settings_reset_data.call()


func _on_settings_close_pressed() -> void:
	hide_settings_panel()


func show_overlap_selector(items: Array) -> void:
	if overlap_selector_panel == null or _overlap_items_vbox == null:
		return
	for child: Node in _overlap_items_vbox.get_children():
		_overlap_items_vbox.remove_child(child)
		child.queue_free()
	for i: int in range(items.size()):
		var furniture: Object = items[i]
		var type_str: String = str(furniture.get("type"))
		var layer_str: String = str(furniture.get("layer") if furniture.get("layer") != null else "furniture")
		var size_val: Vector2i = furniture.get("size")
		var display: String = _inspector_display_name(type_str) + " · " + _layer_display_name(layer_str) + "  " + str(size_val.x) + "×" + str(size_val.y)
		var btn: Button = Button.new()
		btn.text = display
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 13)
		btn.pressed.connect(_on_overlap_item_pressed.bind(i))
		_overlap_items_vbox.add_child(btn)
	overlap_selector_panel.visible = true
	overlap_selector_panel.move_to_front()


func hide_overlap_selector() -> void:
	if overlap_selector_panel != null:
		overlap_selector_panel.visible = false


func is_overlap_selector_visible() -> bool:
	return overlap_selector_panel != null and overlap_selector_panel.visible


func _on_overlap_item_pressed(index: int) -> void:
	hide_overlap_selector()
	if _on_overlap_item_selected.is_valid():
		_on_overlap_item_selected.call(index)


func _on_overlap_close_pressed() -> void:
	hide_overlap_selector()
	if _on_overlap_selector_closed.is_valid():
		_on_overlap_selector_closed.call()


func show_furniture_catalog() -> void:
	if catalog_panel != null:
		catalog_panel.visible = true
	hide_premium_side_panel()


func hide_furniture_catalog() -> void:
	if catalog_panel != null:
		catalog_panel.visible = false


func show_main_menu() :
	main_menu_panel.visible = true
	room_select_panel.visible = false
	profile_panel.visible = false
	controls_panel.visible = false
	hide_premium_top_bar()
	hide_premium_objective_panel()
	hide_premium_side_panel()
	hide_premium_bottom_bar()
	chat_history_panel.visible = false
	chat_input_panel.visible = false
	if inventory_panel != null:
		inventory_panel.visible = false
	if help_button != null:
		help_button.visible = false
	if _mode_button != null:
		_mode_button.visible = false
	if _pause_menu_btn != null:
		_pause_menu_btn.visible = false
	hide_shop_button()
	hide_shop_panel()
	hide_settings_panel()
	hide_pause_menu()
	hide_missions_panel()
	hide_chat_bubble()
	hide_npc_bubble()
	hide_toast()
	hide_tutorial()
	hide_furniture_catalog()
	hide_furniture_inspector()
	hide_overlap_selector()
	hide_about_panel()


func show_room_select() :
	main_menu_panel.visible = false
	room_select_panel.visible = true
	room_select_panel.move_to_front()
	profile_panel.visible = false
	controls_panel.visible = false
	hide_premium_top_bar()
	hide_premium_objective_panel()
	hide_premium_side_panel()
	hide_premium_bottom_bar()
	chat_history_panel.visible = false
	chat_input_panel.visible = false
	if inventory_panel != null:
		inventory_panel.visible = false
	if help_button != null:
		help_button.visible = false
	if _mode_button != null:
		_mode_button.visible = false
	if _pause_menu_btn != null:
		_pause_menu_btn.visible = false
	hide_shop_panel()
	hide_settings_panel()
	hide_pause_menu()
	hide_missions_panel()
	hide_chat_bubble()
	hide_npc_bubble()
	hide_toast()
	hide_tutorial()
	hide_furniture_catalog()
	hide_furniture_inspector()
	hide_overlap_selector()
	hide_about_panel()


func show_in_room() :
	main_menu_panel.visible = false
	room_select_panel.visible = false
	profile_panel.visible = false
	controls_panel.visible = false
	if help_button != null:
		help_button.visible = false
	if _mode_button != null:
		_mode_button.visible = false
	if _pause_menu_btn != null:
		_pause_menu_btn.visible = false
	show_premium_top_bar()
	show_premium_side_panel()
	show_premium_bottom_bar()
	show_missions_panel()


func set_room_name(room_name) :
	if room_label != null:
		room_label.text = "Sala: " + room_name
	if _premium_room_name_label != null:
		_premium_room_name_label.text = str(room_name)


func set_status_message(message) :
	if status_label != null:
		status_label.text = message


func report_status(message) :
	print(message)
	set_status_message(message)


func focus_chat_input() :
	if chat_input_panel == null or chat_input == null:
		return

	chat_input_panel.visible = true
	chat_input.grab_focus()
	chat_input.caret_column = chat_input.text.length()


func close_chat_input(clear_text) :
	if chat_input_panel == null or chat_input == null:
		return

	if clear_text:
		chat_input.text = ""

	chat_input_panel.visible = false
	chat_input.release_focus()


func is_chat_input_active() :
	if chat_input_panel == null:
		return false
	return chat_input_panel.visible


func get_chat_input_text() :
	if chat_input == null:
		return ""
	return chat_input.text


func update_chat_history(messages: Array[String]) :
	if chat_history_panel == null or chat_history_label == null:
		return

	if messages.is_empty():
		chat_history_label.text = ""
		chat_history_panel.visible = false
		return

	chat_history_panel.visible = true
	chat_history_label.text = "\n".join(messages)


func show_chat_bubble(formatted_message, world_position) :
	if chat_bubble_panel == null or chat_bubble_label == null:
		return

	chat_bubble_label.text = formatted_message
	chat_bubble_timer = 3.0
	chat_bubble_visible = true
	chat_bubble_panel.visible = true
	update_chat_bubble(world_position, 0.0)


func update_chat_bubble(world_position, delta) :
	if not chat_bubble_visible:
		return

	if chat_bubble_panel == null or ui_layer == null:
		chat_bubble_visible = false
		return

	chat_bubble_timer -= delta
	if chat_bubble_timer <= 0.0:
		hide_chat_bubble()
		return

	var canvas_transform: Transform2D = ui_layer.get_viewport().get_canvas_transform()
	var screen_position = canvas_transform * world_position
	var chars_per_line = 30
	var line_count = maxi(1, int(ceil(float(chat_bubble_label.text.length()) / float(chars_per_line))))
	var bubble_width = clampf(120.0 + float(chat_bubble_label.text.length()) * 2.6, CHAT_BUBBLE_MIN_WIDTH, CHAT_BUBBLE_MAX_WIDTH)
	var bubble_height = 24.0 + float(line_count) * 18.0

	chat_bubble_panel.size = Vector2(bubble_width, bubble_height)
	chat_bubble_panel.position = screen_position + Vector2(-bubble_width * 0.5, -132.0 - bubble_height)


func hide_chat_bubble() :
	chat_bubble_visible = false
	chat_bubble_timer = 0.0
	if chat_bubble_panel != null:
		chat_bubble_panel.visible = false


func show_npc_bubble(formatted_message: String, world_position: Vector2) -> void:
	if npc_bubble_panel == null or npc_bubble_label == null:
		return
	npc_bubble_label.text = formatted_message
	npc_bubble_timer = 3.0
	npc_bubble_visible = true
	npc_bubble_panel.visible = true
	update_npc_bubble(world_position, 0.0)


func update_npc_bubble(world_position: Vector2, delta: float) -> void:
	if not npc_bubble_visible:
		return
	if npc_bubble_panel == null or ui_layer == null:
		npc_bubble_visible = false
		return
	npc_bubble_timer -= delta
	if npc_bubble_timer <= 0.0:
		hide_npc_bubble()
		return
	var canvas_transform: Transform2D = ui_layer.get_viewport().get_canvas_transform()
	var screen_position: Vector2 = canvas_transform * world_position
	var chars_per_line: int = 30
	var line_count: int = maxi(1, int(ceil(float(npc_bubble_label.text.length()) / float(chars_per_line))))
	var bubble_width: float = clampf(120.0 + float(npc_bubble_label.text.length()) * 2.6, CHAT_BUBBLE_MIN_WIDTH, CHAT_BUBBLE_MAX_WIDTH)
	var bubble_height: float = 24.0 + float(line_count) * 18.0
	npc_bubble_panel.size = Vector2(bubble_width, bubble_height)
	npc_bubble_panel.position = screen_position + Vector2(-bubble_width * 0.5, -132.0 - bubble_height)


func hide_npc_bubble() -> void:
	npc_bubble_visible = false
	npc_bubble_timer = 0.0
	if npc_bubble_panel != null:
		npc_bubble_panel.visible = false


func _build_tutorial_panel() -> void:
	tutorial_overlay = Control.new()
	tutorial_overlay.name = "TutorialOverlay"
	tutorial_overlay.anchor_left = 0.0
	tutorial_overlay.anchor_top = 0.0
	tutorial_overlay.anchor_right = 1.0
	tutorial_overlay.anchor_bottom = 1.0
	tutorial_overlay.offset_left = 0.0
	tutorial_overlay.offset_top = 0.0
	tutorial_overlay.offset_right = 0.0
	tutorial_overlay.offset_bottom = 0.0
	tutorial_overlay.visible = false
	tutorial_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_layer.add_child(tutorial_overlay)

	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.05, 0.28)
	dim.anchor_left = 0.0
	dim.anchor_top = 0.0
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial_overlay.add_child(dim)

	tutorial_panel = PanelContainer.new()
	tutorial_panel.name = "TutorialPanel"
	tutorial_panel.anchor_left = 0.5
	tutorial_panel.anchor_top = 0.5
	tutorial_panel.anchor_right = 0.5
	tutorial_panel.anchor_bottom = 0.5
	tutorial_panel.offset_left = -260.0
	tutorial_panel.offset_top = -150.0
	tutorial_panel.offset_right = 260.0
	tutorial_panel.offset_bottom = 150.0
	tutorial_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.17, 0.96)))
	tutorial_overlay.add_child(tutorial_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 16)
	tutorial_panel.add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	tutorial_counter_label = Label.new()
	tutorial_counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tutorial_counter_label.add_theme_color_override("font_color", Color(0.70, 0.80, 0.92))
	tutorial_counter_label.add_theme_font_size_override("font_size", 12)
	layout.add_child(tutorial_counter_label)

	tutorial_title_label = Label.new()
	tutorial_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_title_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.72))
	tutorial_title_label.add_theme_font_size_override("font_size", 20)
	layout.add_child(tutorial_title_label)

	tutorial_body_label = Label.new()
	tutorial_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tutorial_body_label.custom_minimum_size = Vector2(0.0, 92.0)
	tutorial_body_label.add_theme_color_override("font_color", Color(0.90, 0.94, 1.0))
	tutorial_body_label.add_theme_font_size_override("font_size", 15)
	layout.add_child(tutorial_body_label)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 8)
	layout.add_child(button_row)

	tutorial_skip_button = Button.new()
	tutorial_skip_button.text = "Omitir"
	tutorial_skip_button.pressed.connect(_on_tutorial_skip_pressed)
	button_row.add_child(tutorial_skip_button)

	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_child(spacer)

	tutorial_prev_button = Button.new()
	tutorial_prev_button.text = "Anterior"
	tutorial_prev_button.pressed.connect(_on_tutorial_prev_pressed)
	button_row.add_child(tutorial_prev_button)

	tutorial_next_button = Button.new()
	tutorial_next_button.text = "Siguiente"
	tutorial_next_button.pressed.connect(_on_tutorial_next_pressed)
	button_row.add_child(tutorial_next_button)

	tutorial_finish_button = Button.new()
	tutorial_finish_button.text = "Finalizar"
	tutorial_finish_button.pressed.connect(_on_tutorial_finish_pressed)
	button_row.add_child(tutorial_finish_button)


func show_tutorial(is_manual: bool = false) -> void:
	if tutorial_overlay == null:
		return
	tutorial_is_manual = is_manual
	_play_ui_sound("panel_open")
	hide_shop_button()
	hide_shop_panel()
	hide_missions_panel()
	set_tutorial_step(0)
	tutorial_overlay.visible = true
	tutorial_overlay.move_to_front()


func hide_tutorial() -> void:
	if tutorial_overlay != null:
		if tutorial_overlay.visible:
			_play_ui_sound("panel_close")
		tutorial_overlay.visible = false
	if controls_panel != null and controls_panel.visible:
		show_shop_button()
		show_missions_panel()


func is_tutorial_visible() -> bool:
	return tutorial_overlay != null and tutorial_overlay.visible


func set_tutorial_step(index: int) -> void:
	if _tutorial_steps.is_empty():
		return
	tutorial_step_index = clampi(index, 0, _tutorial_steps.size() - 1)
	var step: Dictionary = _tutorial_steps[tutorial_step_index]
	if tutorial_title_label != null:
		tutorial_title_label.text = str(step.get("title", ""))
	if tutorial_body_label != null:
		tutorial_body_label.text = str(step.get("body", ""))
	if tutorial_counter_label != null:
		tutorial_counter_label.text = str(tutorial_step_index + 1) + "/" + str(_tutorial_steps.size())
	if tutorial_prev_button != null:
		tutorial_prev_button.disabled = tutorial_step_index == 0
	if tutorial_next_button != null:
		tutorial_next_button.visible = tutorial_step_index < _tutorial_steps.size() - 1
	if tutorial_finish_button != null:
		tutorial_finish_button.visible = tutorial_step_index == _tutorial_steps.size() - 1


func _close_tutorial(completed: bool) -> void:
	hide_tutorial()
	if _on_tutorial_closed.is_valid():
		_on_tutorial_closed.call(completed)


func _on_tutorial_prev_pressed() -> void:
	_play_ui_sound("ui_click")
	set_tutorial_step(tutorial_step_index - 1)


func _on_tutorial_next_pressed() -> void:
	_play_ui_sound("ui_click")
	set_tutorial_step(tutorial_step_index + 1)


func _on_tutorial_skip_pressed() -> void:
	_close_tutorial(true)


func _on_tutorial_finish_pressed() -> void:
	_close_tutorial(true)


func _on_help_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_tutorial_open_requested.is_valid():
		_on_tutorial_open_requested.call()


func _build_shop_panel() -> void:
	shop_panel = PanelContainer.new()
	shop_panel.name = "ShopPanel"
	shop_panel.anchor_left = 0.5
	shop_panel.anchor_top = 0.5
	shop_panel.anchor_right = 0.5
	shop_panel.anchor_bottom = 0.5
	shop_panel.offset_left = -260.0
	shop_panel.offset_top = -190.0
	shop_panel.offset_right = 260.0
	shop_panel.offset_bottom = 190.0
	shop_panel.visible = false
	shop_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.17, 0.97)))
	ui_layer.add_child(shop_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	shop_panel.add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)

	var title: Label = Label.new()
	title.text = "Tienda"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.72))
	layout.add_child(title)

	_shop_credits_label = Label.new()
	_shop_credits_label.text = "Créditos: 0"
	_shop_credits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_shop_credits_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.48))
	layout.add_child(_shop_credits_label)

	_shop_items_vbox = VBoxContainer.new()
	_shop_items_vbox.add_theme_constant_override("separation", 6)
	layout.add_child(_shop_items_vbox)

	var close_btn: Button = Button.new()
	close_btn.text = "Cerrar"
	close_btn.pressed.connect(_on_shop_close_pressed)
	layout.add_child(close_btn)


func show_shop_panel(items: Array[Dictionary], credits: int, stock_data: Dictionary = {}) -> void:
	update_shop_items(items, credits, stock_data)
	if shop_panel != null:
		_play_ui_sound("panel_open")
		shop_panel.visible = true
		shop_panel.move_to_front()


func hide_shop_panel() -> void:
	if shop_panel != null:
		if shop_panel.visible:
			_play_ui_sound("panel_close")
		shop_panel.visible = false
	if controls_panel != null and controls_panel.visible:
		show_missions_panel()
	if _on_shop_closed.is_valid():
		_on_shop_closed.call()


func update_shop_items(items: Array[Dictionary], credits: int, stock_data: Dictionary = {}) -> void:
	if _shop_credits_label != null:
		_shop_credits_label.text = "Créditos: " + str(credits)
	if _shop_items_vbox == null:
		return
	for child: Node in _shop_items_vbox.get_children():
		_shop_items_vbox.remove_child(child)
		child.queue_free()
	for item: Dictionary in items:
		var item_id: String = str(item.get("id", ""))
		var display_name: String = str(item.get("display_name", item_id))
		var price: int = int(item.get("price", 0))
		var item_type: String = str(item.get("type", item_id))
		var stock: int = int(stock_data.get(item_type, 0))

		var col: VBoxContainer = VBoxContainer.new()
		col.add_theme_constant_override("separation", 2)
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_shop_items_vbox.add_child(col)

		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		col.add_child(row)

		var label: Label = Label.new()
		label.text = display_name + " — " + str(price) + " créditos"
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", Color(0.90, 0.94, 1.0))
		row.add_child(label)

		var buy_btn: Button = Button.new()
		buy_btn.text = "Comprar"
		buy_btn.pressed.connect(_on_shop_buy_pressed.bind(item_id))
		row.add_child(buy_btn)

		var stock_label: Label = Label.new()
		stock_label.text = "En inventario: " + str(stock)
		stock_label.add_theme_font_size_override("font_size", 11)
		stock_label.add_theme_color_override("font_color", Color(0.65, 0.80, 0.65) if stock > 0 else Color(0.60, 0.60, 0.60))
		col.add_child(stock_label)


func is_shop_visible() -> bool:
	return shop_panel != null and shop_panel.visible


func show_shop_button() -> void:
	if shop_button != null:
		shop_button.visible = true


func hide_shop_button() -> void:
	if shop_button != null:
		shop_button.visible = false


func _on_shop_button_pressed() -> void:
	_play_ui_sound("ui_click")
	if is_shop_visible():
		hide_shop_panel()
	elif _on_shop_item_buy.is_valid():
		_on_shop_item_buy.call("__open_shop__")


func _on_shop_buy_pressed(item_id: String) -> void:
	_play_ui_sound("ui_click")
	if _on_shop_item_buy.is_valid():
		_on_shop_item_buy.call(item_id)


func _on_shop_close_pressed() -> void:
	hide_shop_panel()


func build_premium_top_bar() -> void:
	premium_top_bar = PanelContainer.new()
	premium_top_bar.name = "PremiumTopBar"
	premium_top_bar.anchor_left = 0.0
	premium_top_bar.anchor_top = 0.0
	premium_top_bar.anchor_right = 1.0
	premium_top_bar.anchor_bottom = 0.0
	premium_top_bar.offset_left = 18.0
	premium_top_bar.offset_top = 8.0
	premium_top_bar.offset_right = -18.0
	premium_top_bar.offset_bottom = 56.0
	premium_top_bar.visible = false
	premium_top_bar.add_theme_stylebox_override("panel", _make_premium_panel_style(HUD_BG, 12))
	ui_layer.add_child(premium_top_bar)

	var margin: MarginContainer = _make_margin(12, 6, 12, 6)
	premium_top_bar.add_child(margin)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(row)

	var logo: Button = _make_premium_button("K", Vector2(34.0, 32.0))
	logo.tooltip_text = GAME_TITLE
	logo.pressed.connect(_on_premium_commands_pressed)
	row.add_child(logo)

	var room_box: VBoxContainer = VBoxContainer.new()
	room_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(room_box)
	_premium_room_name_label = _make_label("Lobby", 17, HUD_TEXT_MAIN, HORIZONTAL_ALIGNMENT_LEFT)
	_premium_room_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	room_box.add_child(_premium_room_name_label)
	var meta_row: HBoxContainer = HBoxContainer.new()
	meta_row.add_theme_constant_override("separation", 6)
	room_box.add_child(meta_row)
	_premium_people_label = _make_label("2 en sala", 11, HUD_TEXT_SECONDARY, HORIZONTAL_ALIGNMENT_LEFT)
	meta_row.add_child(_premium_people_label)
	_premium_rating_label = _make_label("★ 4.8", 11, HUD_WARNING, HORIZONTAL_ALIGNMENT_LEFT)
	meta_row.add_child(_premium_rating_label)

	var change_btn: Button = _make_premium_button("Cambiar", Vector2(76.0, 30.0))
	change_btn.pressed.connect(_on_premium_change_room_pressed)
	row.add_child(change_btn)

	_premium_credits_label = _make_label("Créditos 0", 13, HUD_WARNING, HORIZONTAL_ALIGNMENT_RIGHT)
	_premium_credits_label.custom_minimum_size = Vector2(104.0, 0.0)
	row.add_child(_premium_credits_label)
	var plus_btn: Button = _make_premium_button("+", Vector2(30.0, 30.0))
	plus_btn.pressed.connect(_on_premium_open_shop_pressed)
	row.add_child(plus_btn)
	var help_btn: Button = _make_premium_button("Ayuda", Vector2(62.0, 30.0))
	help_btn.pressed.connect(_on_premium_open_help_pressed)
	row.add_child(help_btn)
	var menu_btn: Button = _make_premium_button("Menú", Vector2(60.0, 30.0))
	menu_btn.pressed.connect(_on_premium_open_pause_pressed)
	row.add_child(menu_btn)


func build_premium_objective_panel() -> void:
	premium_objective_panel = PanelContainer.new()
	premium_objective_panel.name = "PremiumObjectivePanel"
	premium_objective_panel.anchor_left = 0.0
	premium_objective_panel.anchor_top = 0.0
	premium_objective_panel.anchor_right = 0.0
	premium_objective_panel.anchor_bottom = 0.0
	premium_objective_panel.offset_left = 18.0
	premium_objective_panel.offset_top = 72.0
	premium_objective_panel.offset_right = 288.0
	premium_objective_panel.offset_bottom = 210.0
	premium_objective_panel.visible = false
	premium_objective_panel.add_theme_stylebox_override("panel", _make_premium_panel_style(HUD_PANEL, 8))
	ui_layer.add_child(premium_objective_panel)

	var margin: MarginContainer = _make_margin(11, 10, 11, 10)
	premium_objective_panel.add_child(margin)
	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 4)
	margin.add_child(layout)

	# Header: "OBJETIVO DIARIO"
	layout.add_child(_make_label("★ OBJETIVO DIARIO", 9, HUD_ACCENT, HORIZONTAL_ALIGNMENT_LEFT))

	# Title
	_premium_objective_title_label = _make_label("Decora tu sala", 13, HUD_TEXT_MAIN, HORIZONTAL_ALIGNMENT_LEFT)
	_premium_objective_title_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_premium_objective_title_label.clip_text = true
	layout.add_child(_premium_objective_title_label)

	# Description
	_premium_objective_desc_label = _make_label("Coloca muebles en la sala.", 10, HUD_TEXT_SECONDARY, HORIZONTAL_ALIGNMENT_LEFT)
	_premium_objective_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_premium_objective_desc_label.custom_minimum_size = Vector2(0.0, 30.0)
	layout.add_child(_premium_objective_desc_label)

	# Progress row: label + bar
	var progress_row: HBoxContainer = HBoxContainer.new()
	progress_row.add_theme_constant_override("separation", 8)
	progress_row.custom_minimum_size = Vector2(0.0, 18.0)
	layout.add_child(progress_row)

	_premium_objective_progress_label = _make_label("0/1", 10, HUD_TEXT_SECONDARY, HORIZONTAL_ALIGNMENT_LEFT)
	_premium_objective_progress_label.custom_minimum_size = Vector2(28.0, 0.0)
	progress_row.add_child(_premium_objective_progress_label)

	var progress_bg: ColorRect = ColorRect.new()
	progress_bg.color = Color(0.10, 0.12, 0.20, 0.95)
	progress_bg.custom_minimum_size = Vector2(0.0, 8.0)
	progress_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_row.add_child(progress_bg)
	_premium_objective_progress_fill = ColorRect.new()
	_premium_objective_progress_fill.anchor_left = 0.0
	_premium_objective_progress_fill.anchor_top = 0.0
	_premium_objective_progress_fill.anchor_right = 0.0
	_premium_objective_progress_fill.anchor_bottom = 1.0
	_premium_objective_progress_fill.color = HUD_ACCENT
	progress_bg.add_child(_premium_objective_progress_fill)

	# Bottom row: reward + status badge
	var footer: HBoxContainer = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 6)
	layout.add_child(footer)

	_premium_objective_reward_label = _make_label("+20 créditos", 10, HUD_ACCENT, HORIZONTAL_ALIGNMENT_LEFT)
	footer.add_child(_premium_objective_reward_label)

	footer.add_child(Control.new())  # Spacer
	var spacer: Control = footer.get_child(-1)
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_premium_objective_status_label = _make_label("EN PROGRESO", 9, HUD_TEXT_SECONDARY, HORIZONTAL_ALIGNMENT_RIGHT)
	footer.add_child(_premium_objective_status_label)

	# Summary label (for all completed state)
	_premium_objective_summary_label = _make_label("0/0 completados", 9, HUD_TEXT_SECONDARY, HORIZONTAL_ALIGNMENT_LEFT)
	_premium_objective_summary_label.visible = false
	layout.add_child(_premium_objective_summary_label)


func build_premium_side_panel() -> void:
	premium_side_panel = PanelContainer.new()
	premium_side_panel.name = "PremiumSidePanel"
	premium_side_panel.anchor_left = 1.0
	premium_side_panel.anchor_top = 0.0
	premium_side_panel.anchor_right = 1.0
	premium_side_panel.anchor_bottom = 1.0
	premium_side_panel.offset_left = -248.0
	premium_side_panel.offset_top = 72.0
	premium_side_panel.offset_right = -12.0
	premium_side_panel.offset_bottom = -108.0
	premium_side_panel.visible = false
	premium_side_panel.add_theme_stylebox_override("panel", _make_premium_panel_style(HUD_PANEL, 10))
	ui_layer.add_child(premium_side_panel)

	var margin: MarginContainer = _make_margin(10, 10, 10, 10)
	premium_side_panel.add_child(margin)
	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 6)
	margin.add_child(layout)

	layout.add_child(_make_label("MAPA", 9, HUD_ACCENT, HORIZONTAL_ALIGNMENT_LEFT))
	var map_box: Control = Control.new()
	map_box.custom_minimum_size = Vector2(150.0, 88.0)
	layout.add_child(map_box)
	_build_premium_minimap(map_box)
	_premium_minimap_status_label = _make_label("en línea local", 9, HUD_SUCCESS, HORIZONTAL_ALIGNMENT_LEFT)
	_premium_map_badge_label = _premium_minimap_status_label
	layout.add_child(_premium_minimap_status_label)
	_premium_minimap_room_label = _make_label("Sala actual: Lobby", 9, HUD_TEXT_MAIN, HORIZONTAL_ALIGNMENT_LEFT)
	_premium_minimap_room_label.add_theme_color_override("font_color", HUD_TEXT_SECONDARY)
	layout.add_child(_premium_minimap_room_label)

	var map_tabs: GridContainer = GridContainer.new()
	map_tabs.columns = 2
	map_tabs.add_theme_constant_override("h_separation", 4)
	map_tabs.add_theme_constant_override("v_separation", 4)
	layout.add_child(map_tabs)
	_premium_map_lobby_btn = _make_premium_button("Lobby", Vector2(66.0, 26.0))
	_premium_map_lobby_btn.pressed.connect(_on_minimap_lobby_pressed)
	map_tabs.add_child(_premium_map_lobby_btn)
	_premium_map_cafe_btn = _make_premium_button("Café", Vector2(66.0, 26.0))
	_premium_map_cafe_btn.pressed.connect(_on_minimap_small_pressed)
	map_tabs.add_child(_premium_map_cafe_btn)
	_premium_map_pool_btn = _make_premium_button("Pool", Vector2(66.0, 26.0))
	_premium_map_pool_btn.pressed.connect(_on_minimap_large_pressed)
	map_tabs.add_child(_premium_map_pool_btn)
	_premium_map_more_btn = _make_premium_button("+", Vector2(66.0, 26.0))
	_premium_map_more_btn.pressed.connect(_on_minimap_more_pressed)
	map_tabs.add_child(_premium_map_more_btn)

	layout.add_child(HSeparator.new())
	var header_h: HBoxContainer = HBoxContainer.new()
	header_h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_h.add_theme_constant_override("separation", 6)
	layout.add_child(header_h)
	header_h.add_child(_make_label("EN LA SALA", 9, HUD_ACCENT, HORIZONTAL_ALIGNMENT_LEFT))
	_premium_side_people_count_label = _make_label("0", 10, HUD_TEXT_SECONDARY, HORIZONTAL_ALIGNMENT_RIGHT)
	_premium_side_people_count_label.add_theme_color_override("font_color", HUD_ACCENT)
	_premium_side_people_count_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_h.add_child(_premium_side_people_count_label)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 135)
	layout.add_child(scroll)

	_premium_people_vbox = VBoxContainer.new()
	_premium_people_vbox.add_theme_constant_override("separation", 6)
	_premium_people_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_premium_people_vbox)


func build_premium_bottom_bar() -> void:
	premium_bottom_bar = PanelContainer.new()
	premium_bottom_bar.name = "PremiumBottomBar"
	premium_bottom_bar.anchor_left = 0.0
	premium_bottom_bar.anchor_top = 1.0
	premium_bottom_bar.anchor_right = 1.0
	premium_bottom_bar.anchor_bottom = 1.0
	premium_bottom_bar.offset_left = 14.0
	premium_bottom_bar.offset_top = -96.0
	premium_bottom_bar.offset_right = -14.0
	premium_bottom_bar.offset_bottom = -10.0
	premium_bottom_bar.visible = false
	premium_bottom_bar.add_theme_stylebox_override("panel", _make_premium_panel_style(HUD_BG, 14))
	ui_layer.add_child(premium_bottom_bar)

	var margin: MarginContainer = _make_margin(12, 7, 12, 7)
	premium_bottom_bar.add_child(margin)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)

	var player_zone: PanelContainer = _make_bottom_zone(Vector2(178.0, 0.0))
	row.add_child(player_zone)
	var player_card: HBoxContainer = HBoxContainer.new()
	player_card.add_theme_constant_override("separation", 8)
	player_zone.add_child(_wrap_in_margin(player_card, 8, 6, 8, 6))
	_premium_player_color = ColorRect.new()
	_premium_player_color.custom_minimum_size = Vector2(34.0, 34.0)
	_premium_player_color.color = Color(0.14, 0.32, 0.72)
	player_card.add_child(_premium_player_color)
	var player_text: VBoxContainer = VBoxContainer.new()
	player_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_card.add_child(player_text)
	var player_top: HBoxContainer = HBoxContainer.new()
	player_top.add_theme_constant_override("separation", 5)
	player_text.add_child(player_top)
	_premium_player_name_label = _make_label("Invitado", 13, HUD_TEXT_MAIN, HORIZONTAL_ALIGNMENT_LEFT)
	_premium_player_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_premium_player_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_top.add_child(_premium_player_name_label)
	var online_dot: ColorRect = ColorRect.new()
	online_dot.custom_minimum_size = Vector2(7.0, 7.0)
	online_dot.color = HUD_SUCCESS
	player_top.add_child(online_dot)
	player_text.add_child(_make_label("online · LVL 1", 10, HUD_TEXT_SECONDARY, HORIZONTAL_ALIGNMENT_LEFT))
	var xp_bg: ColorRect = ColorRect.new()
	xp_bg.custom_minimum_size = Vector2(0.0, 5.0)
	xp_bg.color = Color(0.14, 0.18, 0.30, 0.9)
	player_text.add_child(xp_bg)
	var xp_fill: ColorRect = ColorRect.new()
	xp_fill.anchor_right = 0.2
	xp_fill.anchor_bottom = 1.0
	xp_fill.color = HUD_ACCENT
	xp_bg.add_child(xp_fill)

	var chat_zone: PanelContainer = _make_bottom_zone(Vector2(0.0, 0.0))
	chat_zone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(chat_zone)
	var chat_layout: VBoxContainer = VBoxContainer.new()
	chat_layout.add_theme_constant_override("separation", 4)
	chat_zone.add_child(_wrap_in_margin(chat_layout, 10, 7, 10, 7))
	chat_layout.add_child(_make_label("CHAT", 9, HUD_ACCENT, HORIZONTAL_ALIGNMENT_LEFT))
	_premium_bottom_hint_label = _make_label("Click para caminar · Enter para chatear · Tab para decorar", 12, Color(0.82, 0.90, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	_premium_bottom_hint_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	chat_layout.add_child(_premium_bottom_hint_label)
	chat_layout.add_child(_make_label("canal local", 9, HUD_TEXT_SECONDARY, HORIZONTAL_ALIGNMENT_LEFT))

	var nav_zone: PanelContainer = _make_bottom_zone(Vector2(390.0, 0.0))
	row.add_child(nav_zone)
	var nav_layout: VBoxContainer = VBoxContainer.new()
	nav_layout.add_theme_constant_override("separation", 5)
	nav_zone.add_child(_wrap_in_margin(nav_layout, 8, 6, 8, 6))
	nav_layout.add_child(_make_label("NAVEGACIÓN", 9, HUD_ACCENT, HORIZONTAL_ALIGNMENT_LEFT))
	var tabs: HBoxContainer = HBoxContainer.new()
	tabs.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs.add_theme_constant_override("separation", 5)
	nav_layout.add_child(tabs)
	_premium_tab_room_btn = _make_premium_button("Sala", Vector2(62.0, 27.0))
	_premium_tab_room_btn.pressed.connect(_on_bottom_explore_pressed)
	tabs.add_child(_premium_tab_room_btn)
	_premium_tab_decorate_btn = _make_premium_button("Decora", Vector2(70.0, 27.0))
	_premium_tab_decorate_btn.pressed.connect(_on_bottom_decorate_pressed)
	tabs.add_child(_premium_tab_decorate_btn)
	_premium_tab_shop_btn = _make_premium_button("Tienda", Vector2(68.0, 27.0))
	_premium_tab_shop_btn.pressed.connect(_on_bottom_shop_pressed)
	tabs.add_child(_premium_tab_shop_btn)
	_premium_tab_inventory_btn = _make_premium_button("Inv.", Vector2(56.0, 27.0))
	_premium_tab_inventory_btn.pressed.connect(_on_bottom_inventory_pressed)
	tabs.add_child(_premium_tab_inventory_btn)
	_premium_tab_profile_btn = _make_premium_button("Perfil", Vector2(64.0, 27.0))
	_premium_tab_profile_btn.pressed.connect(_on_bottom_profile_pressed)
	tabs.add_child(_premium_tab_profile_btn)

	var action_zone: PanelContainer = _make_bottom_zone(Vector2(148.0, 0.0))
	row.add_child(action_zone)
	var actions: GridContainer = GridContainer.new()
	actions.columns = 2
	actions.add_theme_constant_override("h_separation", 5)
	actions.add_theme_constant_override("v_separation", 5)
	action_zone.add_child(_wrap_in_margin(actions, 8, 6, 8, 6))
	var emotes_btn: Button = _make_social_action_button("Emo")
	emotes_btn.pressed.connect(_on_bottom_emotes_pressed)
	actions.add_child(emotes_btn)
	var dance_btn: Button = _make_social_action_button("Baile")
	dance_btn.pressed.connect(_on_bottom_dance_pressed)
	actions.add_child(dance_btn)
	var music_btn: Button = _make_social_action_button("Música")
	music_btn.pressed.connect(_on_bottom_music_pressed)
	actions.add_child(music_btn)
	var photo_btn: Button = _make_social_action_button("Foto")
	photo_btn.pressed.connect(_on_bottom_photo_pressed)
	actions.add_child(photo_btn)


func show_premium_top_bar() -> void:
	if premium_top_bar != null:
		premium_top_bar.visible = true


func hide_premium_top_bar() -> void:
	if premium_top_bar != null:
		premium_top_bar.visible = false


func show_premium_objective_panel() -> void:
	if premium_objective_panel != null and not is_tutorial_visible():
		premium_objective_panel.visible = true


func hide_premium_objective_panel() -> void:
	if premium_objective_panel != null:
		premium_objective_panel.visible = false


func show_premium_side_panel() -> void:
	if premium_side_panel != null:
		premium_side_panel.visible = true


func hide_premium_side_panel() -> void:
	if premium_side_panel != null:
		premium_side_panel.visible = false


func show_premium_bottom_bar() -> void:
	if premium_bottom_bar != null:
		premium_bottom_bar.visible = true


func hide_premium_bottom_bar() -> void:
	if premium_bottom_bar != null:
		premium_bottom_bar.visible = false


func show_social_bottom_bar() -> void:
	show_premium_bottom_bar()


func hide_social_bottom_bar() -> void:
	hide_premium_bottom_bar()


func update_premium_room_info(room_name: String, people_count: int, rating: float) -> void:
	if _premium_room_name_label != null:
		_premium_room_name_label.text = _trim_ui_text(room_name, 22)
	if _premium_people_label != null:
		_premium_people_label.text = str(people_count) + " en sala"
	if _premium_rating_label != null:
		_premium_rating_label.text = "★ " + str(rating)


func update_premium_credits(amount: int) -> void:
	if _premium_credits_label != null:
		_premium_credits_label.text = "Créditos " + str(amount)


func update_premium_daily_objective(active_objective: Dictionary, completed_count: int, total_count: int) -> void:
	if _premium_objective_title_label == null:
		return
	var title: String = str(active_objective.get("title", ""))
	var description: String = str(active_objective.get("description", ""))
	var reward: int = int(active_objective.get("reward_credits", 0))
	var current_progress: int = int(active_objective.get("current_progress", 0))
	var target_progress: int = max(1, int(active_objective.get("target_progress", 1)))
	var completed: bool = bool(active_objective.get("completed", false))
	var all_completed: bool = total_count > 0 and completed_count >= total_count

	if all_completed or str(active_objective.get("id", "")) == "daily_complete":
		# All objectives completed - show special state
		_premium_objective_title_label.text = "¡Todo listo por hoy!"
		_premium_objective_desc_label.text = "Objetivos diarios completos."
		_premium_objective_progress_label.text = str(total_count) + "/" + str(total_count)
		_premium_objective_status_label.text = "COMPLETADO"
		_premium_objective_status_label.add_theme_color_override("font_color", HUD_SUCCESS)
		_premium_objective_reward_label.text = ""  # Hide reward when all complete
		_premium_objective_summary_label.text = str(completed_count) + "/" + str(total_count)
		_premium_objective_summary_label.visible = true
		_set_objective_progress(total_count, total_count)
		return

	# Single objective in progress or completed
	_premium_objective_title_label.text = _trim_ui_text(title, 32)
	_premium_objective_desc_label.text = _trim_ui_text(description, 50)
	
	if _premium_objective_progress_label != null:
		_premium_objective_progress_label.text = str(current_progress) + "/" + str(target_progress)
	
	if completed:
		_premium_objective_status_label.text = "COMPLETADO"
		_premium_objective_status_label.add_theme_color_override("font_color", HUD_SUCCESS)
	else:
		_premium_objective_status_label.text = "EN PROGRESO"
		_premium_objective_status_label.add_theme_color_override("font_color", HUD_TEXT_SECONDARY)
	
	_premium_objective_reward_label.text = _format_objective_reward(reward)
	_premium_objective_summary_label.visible = false
	_set_objective_progress(current_progress, target_progress)


func update_premium_objective(missions: Array[Dictionary]) -> void:
	if _premium_objective_title_label == null:
		return
	var selected: Dictionary = {}
	for mission: Dictionary in missions:
		if not bool(mission.get("completed", false)):
			selected = mission
			break
	if selected.is_empty() and not missions.is_empty():
		selected = missions[0]
	if selected.is_empty():
		_premium_objective_title_label.text = "Misiones iniciales completas"
		_premium_objective_desc_label.text = "Buen trabajo por hoy."
		_premium_objective_status_label.text = "Completada"
		_premium_objective_reward_label.text = "+0 créditos"
		_set_objective_progress_fraction(1.0)
		return
	var completed: bool = bool(selected.get("completed", false))
	_premium_objective_title_label.text = _trim_ui_text(str(selected.get("title", "Objetivo")), 28)
	_premium_objective_desc_label.text = _trim_ui_text(str(selected.get("description", "Completa una acción.")), 44)
	_premium_objective_status_label.text = "Completada" if completed else "Pendiente"
	_premium_objective_reward_label.text = "+" + str(int(selected.get("reward_credits", 0))) + " créditos"
	_set_objective_progress_fraction(1.0 if completed else 0.08)


func set_social_person_clicked_callback(cb: Callable) -> void:
	_social_person_clicked_cb = cb


func update_premium_people_list(room_id: String, player_name: String, profile_data: Dictionary = {}) -> void:
	if _premium_people_vbox == null:
		return
	var people: Array[Dictionary] = _get_people_for_room(room_id, player_name, profile_data)
	
	# Limit visible to 4 people for compact display
	var visible_people: Array[Dictionary] = []
	for i in range(mini(people.size(), 4)):
		visible_people.append(people[i])
	
	if _premium_people_label != null:
		_premium_people_label.text = str(people.size()) + " en sala"
	if _premium_side_people_count_label != null:
		_premium_side_people_count_label.text = str(people.size())
	
	for child: Node in _premium_people_vbox.get_children():
		_premium_people_vbox.remove_child(child)
		child.queue_free()
	
	for person: Dictionary in visible_people:
		_premium_people_vbox.add_child(_make_person_row(person))
	
	# Show "+X más" if there are more people
	if people.size() > 4:
		var more_row: Control = _make_more_people_row(people.size() - 4)
		_premium_people_vbox.add_child(more_row)


func _get_people_for_room(room_id: String, player_name: String, profile_data: Dictionary) -> Array[Dictionary]:
	var people: Array[Dictionary] = []
	var player_color: Color = profile_data.get("shirt_color", HUD_ACCENT)
	people.append({
		"id": "self",
		"name": str(player_name),
		"role": "Tú",
		"status": "online",
		"color": player_color,
		"badge": ""
	})

	var bot: Dictionary = {
		"id": "bot_guide",
		"name": "Bot Guía",
		"role": "Guía",
		"status": "disponible",
		"color": Color(0.14, 0.56, 0.94),
		"badge": "GUÍA"
	}
	var mira: Dictionary = {
		"id": "mira",
		"name": "Mira",
		"role": "Decoradora",
		"status": "mirando",
		"color": Color(1.0, 0.45, 0.55),
		"badge": ""
	}
	var pixel: Dictionary = {
		"id": "pixel",
		"name": "Pixel",
		"role": "Visitante",
		"status": "explorando",
		"color": Color(0.64, 0.38, 0.92),
		"badge": ""
	}
	var ren: Dictionary = {
		"id": "ren_42",
		"name": "Ren_42",
		"role": "recién llegado",
		"status": "online",
		"color": Color(0.18, 0.80, 0.36),
		"badge": ""
	}

	match room_id:
		"lobby":
			people.append(bot)
			people.append(mira)
			people.append(pixel)
		"room_small":
			people.append(pixel)
		"room_large":
			people.append(mira)
			people.append(pixel)
			people.append(ren)
		_:
			people.append(pixel)

	return people


func _make_person_row(person: Dictionary) -> Control:
	var btn: Button = Button.new()
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.custom_minimum_size = Vector2(0.0, 38.0)
	btn.add_theme_stylebox_override("normal", _make_panel_style(Color(0, 0, 0, 0)))
	btn.add_theme_stylebox_override("hover", _make_panel_style(Color(0.10, 0.14, 0.22, 0.35)))
	btn.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.14, 0.18, 0.26, 0.45)))

	var h: HBoxContainer = HBoxContainer.new()
	h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.mouse_filter = Control.MOUSE_FILTER_STOP
	h.add_theme_constant_override("separation", 7)
	btn.add_child(h)

	# Avatar with initial
	var avatar: ColorRect = ColorRect.new()
	avatar.custom_minimum_size = Vector2(30.0, 30.0)
	avatar.color = person.get("color", HUD_ACCENT)
	h.add_child(avatar)

	var initial: Label = Label.new()
	initial.text = str(person.get("name", "?")).substr(0, 1).to_upper()
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.add_theme_color_override("font_color", Color(1, 1, 1))
	initial.add_theme_font_size_override("font_size", 12)
	avatar.add_child(initial)

	# Info section
	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 1)
	h.add_child(info)

	# Name
	var name_lbl: Label = Label.new()
	name_lbl.text = _truncate_social_text(str(person.get("name", "Invitado")), 20)
	name_lbl.add_theme_color_override("font_color", HUD_TEXT_MAIN)
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.clip_text = true
	info.add_child(name_lbl)

	# Role with status dot
	var role_row: HBoxContainer = HBoxContainer.new()
	role_row.add_theme_constant_override("separation", 4)
	info.add_child(role_row)

	var status_dot: ColorRect = ColorRect.new()
	status_dot.custom_minimum_size = Vector2(6, 6)
	var status_color: Color = Color(0.18, 0.80, 0.36)
	match str(person.get("status", "online")):
		"online":
			status_color = Color(0.18, 0.80, 0.36)
		"escribiendo":
			status_color = Color(1.0, 0.78, 0.14)
		"mirando":
			status_color = Color(0.22, 0.60, 1.0)
		"explorando":
			status_color = Color(0.64, 0.38, 0.92)
		_:
			status_color = Color(0.60, 0.60, 0.60)
	status_dot.color = status_color
	role_row.add_child(status_dot)

	# Role text (shortened)
	var role_text: String = str(person.get("role", "Visitante"))
	var status_text: String = str(person.get("status", "online"))
	var combined: String = role_text
	if status_text != "online" and status_text != "":
		combined = role_text + " · " + status_text
	var role_lbl: Label = Label.new()
	role_lbl.text = _truncate_social_text(combined, 28)
	role_lbl.add_theme_color_override("font_color", HUD_TEXT_SECONDARY)
	role_lbl.add_theme_font_size_override("font_size", 10)
	role_lbl.clip_text = true
	role_row.add_child(role_lbl)

	btn.pressed.connect(_on_person_clicked.bind(str(person.get("id", "")), str(person.get("name", ""))))
	return btn


func _make_more_people_row(count: int) -> Control:
	var container: Control = Control.new()
	container.custom_minimum_size = Vector2(0.0, 28.0)
	
	var lbl: Label = Label.new()
	lbl.text = "+" + str(count) + " más"
	lbl.add_theme_color_override("font_color", HUD_TEXT_SECONDARY)
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	container.add_child(lbl)
	return container


func _on_person_clicked(person_id: String, person_name: String) -> void:
	if _social_person_clicked_cb != null and _social_person_clicked_cb.is_valid():
		_social_person_clicked_cb.call(person_id, person_name)
		return
	match person_id:
		"self":
			show_profile()
		"bot_guide":
			show_toast("Bot Guía: escribe 'ayuda' en el chat", "info")
		_:
			show_toast("Perfil de %s próximamente".format(person_name), "info")


func update_premium_minimap(room_id: String, room_name: String = "") -> void:
	var active_room_name: String = room_name if room_name != "" else _get_minimap_room_name(room_id)
	var online_text: String = "en línea local" if room_id == "lobby" else "local"
	if _premium_map_badge_label != null:
		_premium_map_badge_label.text = online_text
	if _premium_minimap_status_label != null:
		_premium_minimap_status_label.text = online_text
	if _premium_minimap_room_label != null:
		_premium_minimap_room_label.text = "Sala actual: " + active_room_name
	_style_minimap_room_button(_premium_map_lobby_btn, room_id == "lobby")
	_style_minimap_room_button(_premium_map_cafe_btn, room_id == "room_small")
	_style_minimap_room_button(_premium_map_pool_btn, room_id == "room_large")
	_style_minimap_room_button(_premium_map_more_btn, false)
	if _premium_minimap_lobby_node != null:
		_style_minimap_room_button(_premium_minimap_lobby_node, room_id == "lobby")
	if _premium_minimap_cafe_node != null:
		_style_minimap_room_button(_premium_minimap_cafe_node, room_id == "room_small")
	if _premium_minimap_pool_node != null:
		_style_minimap_room_button(_premium_minimap_pool_node, room_id == "room_large")


func update_premium_map(room_id: String, room_name: String = "") -> void:
	update_premium_minimap(room_id, room_name)


func update_premium_bottom_hint(text: String) -> void:
	if _premium_bottom_hint_label != null:
		_premium_bottom_hint_label.text = _trim_ui_text(text, 58)


func update_social_bottom_hint(text: String) -> void:
	update_premium_bottom_hint(text)


func update_premium_player_card(player_name: String, profile_data: Dictionary) -> void:
	if _premium_player_name_label != null:
		_premium_player_name_label.text = _trim_ui_text(player_name, 16)
	if _premium_player_color != null:
		_premium_player_color.color = profile_data.get("shirt_color", Color(0.14, 0.32, 0.72))


func update_bottom_player_card(player_name: String, profile_data: Dictionary) -> void:
	update_premium_player_card(player_name, profile_data)


func set_premium_room_mode(mode: String) -> void:
	var active_style: StyleBoxFlat = _make_premium_button_style(HUD_ACCENT)
	var inactive_style: StyleBoxFlat = _make_premium_button_style(Color(0.10, 0.13, 0.24, 0.82))
	if _premium_tab_room_btn != null:
		if mode == "exploration":
			_premium_tab_room_btn.add_theme_stylebox_override("normal", active_style)
			_premium_tab_room_btn.add_theme_color_override("font_color", Color(0.10, 0.07, 0.05))
		else:
			_premium_tab_room_btn.add_theme_stylebox_override("normal", inactive_style)
			_premium_tab_room_btn.add_theme_color_override("font_color", HUD_TEXT_MAIN)
	if _premium_tab_decorate_btn != null:
		if mode == "decoration":
			_premium_tab_decorate_btn.add_theme_stylebox_override("normal", active_style)
			_premium_tab_decorate_btn.add_theme_color_override("font_color", Color(0.10, 0.07, 0.05))
		else:
			_premium_tab_decorate_btn.add_theme_stylebox_override("normal", inactive_style)
			_premium_tab_decorate_btn.add_theme_color_override("font_color", HUD_TEXT_MAIN)


func set_social_bottom_mode(mode: String) -> void:
	set_premium_room_mode(mode)


func set_top_change_room_callback(callback: Callable) -> void:
	_on_top_change_room = callback


func set_top_open_shop_callback(callback: Callable) -> void:
	_on_top_open_shop = callback


func set_top_open_pause_callback(callback: Callable) -> void:
	_on_top_open_pause = callback


func set_top_open_help_callback(callback: Callable) -> void:
	_on_top_open_help = callback


func set_side_map_callbacks(lobby_cb: Callable, small_cb: Callable, large_cb: Callable, more_cb: Callable) -> void:
	_on_side_map_lobby = lobby_cb
	_on_side_map_small = small_cb
	_on_side_map_large = large_cb
	_on_side_map_more = more_cb


func set_minimap_room_callback(callback: Callable) -> void:
	_on_minimap_room_requested = callback


func set_bottom_callbacks(explore_cb: Callable, decorate_cb: Callable, shop_cb: Callable, inventory_cb: Callable, profile_cb: Callable, emotes_cb: Callable, dance_cb: Callable, music_cb: Callable, photo_cb: Callable, commands_cb: Callable) -> void:
	_on_bottom_explore = explore_cb
	_on_bottom_decorate = decorate_cb
	_on_bottom_shop = shop_cb
	_on_bottom_inventory = inventory_cb
	_on_bottom_profile = profile_cb
	_on_bottom_emotes = emotes_cb
	_on_bottom_dance = dance_cb
	_on_bottom_music = music_cb
	_on_bottom_photo = photo_cb
	_on_bottom_commands = commands_cb


func _set_objective_progress_fraction(value: float) -> void:
	if _premium_objective_progress_fill == null:
		return
	_premium_objective_progress_fill.anchor_right = clampf(value, 0.0, 1.0)


func _set_objective_progress(current: int, target: int) -> void:
	if _premium_objective_progress_fill == null:
		return
	if target <= 0:
		_premium_objective_progress_fill.anchor_right = 1.0
		return
	_premium_objective_progress_fill.anchor_right = clampf(float(current) / float(target), 0.0, 1.0)


func _format_objective_reward(amount: int) -> String:
	if amount <= 0:
		return "Completado"
	return "+" + str(amount) + " créditos"


func _build_premium_minimap(parent: Control) -> void:
	var diamond: Polygon2D = Polygon2D.new()
	diamond.position = Vector2(75.0, 40.0)
	diamond.polygon = PackedVector2Array([
		Vector2(0.0, -28.0),
		Vector2(48.0, 0.0),
		Vector2(0.0, 28.0),
		Vector2(-48.0, 0.0)
	])
	diamond.color = Color(0.10, 0.14, 0.23, 0.94)
	parent.add_child(diamond)

	var outline: Line2D = Line2D.new()
	outline.position = diamond.position
	outline.points = PackedVector2Array([
		Vector2(0.0, -28.0),
		Vector2(48.0, 0.0),
		Vector2(0.0, 28.0),
		Vector2(-48.0, 0.0),
		Vector2(0.0, -28.0)
	])
	outline.width = 1.6
	outline.default_color = HUD_BORDER
	parent.add_child(outline)

	var lobby_line: Line2D = Line2D.new()
	lobby_line.points = PackedVector2Array([Vector2(27.0, 40.0), Vector2(75.0, 20.0), Vector2(123.0, 40.0)])
	lobby_line.width = 1.2
	lobby_line.default_color = Color(0.45, 0.55, 0.72, 0.55)
	parent.add_child(lobby_line)

	_premium_minimap_lobby_node = _make_premium_button("L", Vector2(28.0, 28.0))
	_premium_minimap_lobby_node.position = Vector2(21.0, 26.0)
	_premium_minimap_lobby_node.tooltip_text = "Lobby"
	_premium_minimap_lobby_node.pressed.connect(_on_minimap_lobby_pressed)
	parent.add_child(_premium_minimap_lobby_node)

	_premium_minimap_cafe_node = _make_premium_button("C", Vector2(28.0, 28.0))
	_premium_minimap_cafe_node.position = Vector2(61.0, 45.0)
	_premium_minimap_cafe_node.tooltip_text = "Café"
	_premium_minimap_cafe_node.pressed.connect(_on_minimap_small_pressed)
	parent.add_child(_premium_minimap_cafe_node)

	_premium_minimap_pool_node = _make_premium_button("P", Vector2(28.0, 28.0))
	_premium_minimap_pool_node.position = Vector2(101.0, 26.0)
	_premium_minimap_pool_node.tooltip_text = "Pool"
	_premium_minimap_pool_node.pressed.connect(_on_minimap_large_pressed)
	parent.add_child(_premium_minimap_pool_node)

	_style_minimap_room_button(_premium_minimap_lobby_node, false)
	_style_minimap_room_button(_premium_minimap_cafe_node, false)
	_style_minimap_room_button(_premium_minimap_pool_node, false)


func _style_minimap_room_button(button: Button, active: bool) -> void:
	if button == null:
		return
	var base_color: Color = Color(0.10, 0.13, 0.24, 0.82)
	var hover_color: Color = Color(0.16, 0.21, 0.36, 0.94)
	var pressed_color: Color = HUD_ACCENT if active else Color(0.20, 0.26, 0.42, 0.96)
	if active:
		base_color = HUD_ACCENT
		hover_color = Color(1.0, 0.76, 0.36, 1.0)
		pressed_color = Color(1.0, 0.82, 0.52, 1.0)
	button.add_theme_stylebox_override("normal", _make_premium_button_style(base_color))
	button.add_theme_stylebox_override("hover", _make_premium_button_style(hover_color))
	button.add_theme_stylebox_override("pressed", _make_premium_button_style(pressed_color))
	button.add_theme_color_override("font_color", Color(0.10, 0.07, 0.05) if active else HUD_TEXT_MAIN)


func _get_minimap_room_name(room_id: String) -> String:
	match room_id:
		"lobby":
			return "Lobby"
		"room_small":
			return "Café"
		"room_large":
			return "Pool"
		_:
			return "Sala"


func _request_minimap_room(room_id: String) -> void:
	if _on_minimap_room_requested.is_valid():
		_on_minimap_room_requested.call(room_id)
		return
	match room_id:
		"lobby":
			if _on_side_map_lobby.is_valid():
				_on_side_map_lobby.call()
		"room_small":
			if _on_side_map_small.is_valid():
				_on_side_map_small.call()
		"room_large":
			if _on_side_map_large.is_valid():
				_on_side_map_large.call()
		_:
			if _on_side_map_more.is_valid():
				_on_side_map_more.call()


func _on_minimap_lobby_pressed() -> void:
	_play_ui_sound("ui_click")
	_request_minimap_room("lobby")


func _on_minimap_small_pressed() -> void:
	_play_ui_sound("ui_click")
	_request_minimap_room("room_small")


func _on_minimap_large_pressed() -> void:
	_play_ui_sound("ui_click")
	_request_minimap_room("room_large")


func _on_minimap_more_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_side_map_more.is_valid():
		_on_side_map_more.call()
	else:
		show_toast("Más salas próximamente", "info")


func _add_premium_person(name: String, role: String, dot_color: Color) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	_premium_people_vbox.add_child(row)
	var dot: ColorRect = ColorRect.new()
	dot.custom_minimum_size = Vector2(7.0, 7.0)
	dot.color = dot_color
	row.add_child(dot)
	var text: VBoxContainer = VBoxContainer.new()
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text)
	text.add_child(_make_label(_trim_ui_text(name, 14), 11, HUD_TEXT_MAIN, HORIZONTAL_ALIGNMENT_LEFT))
	text.add_child(_make_label(role, 9, HUD_TEXT_SECONDARY, HORIZONTAL_ALIGNMENT_LEFT))


func _draw_premium_minimap(parent: Control) -> void:
	var diamond: Polygon2D = Polygon2D.new()
	diamond.position = Vector2(64.0, 34.0)
	diamond.polygon = PackedVector2Array([Vector2(0.0, -24.0), Vector2(48.0, 0.0), Vector2(0.0, 24.0), Vector2(-48.0, 0.0)])
	diamond.color = HUD_PANEL_LIGHT
	parent.add_child(diamond)
	var outline: Line2D = Line2D.new()
	outline.position = diamond.position
	outline.points = PackedVector2Array([Vector2(0.0, -24.0), Vector2(48.0, 0.0), Vector2(0.0, 24.0), Vector2(-48.0, 0.0), Vector2(0.0, -24.0)])
	outline.width = 1.5
	outline.default_color = HUD_BORDER
	parent.add_child(outline)
	_add_map_dot(parent, Vector2(58.0, 34.0), HUD_SUCCESS)
	_add_map_dot(parent, Vector2(78.0, 29.0), Color(0.58, 0.86, 1.0))


func _add_map_dot(parent: Control, position: Vector2, color: Color) -> void:
	var dot: ColorRect = ColorRect.new()
	dot.position = position
	dot.custom_minimum_size = Vector2(6.0, 6.0)
	dot.color = color
	parent.add_child(dot)


func _trim_ui_text(text: String, max_chars: int) -> String:
	if text.length() <= max_chars:
		return text
	return text.left(maxi(1, max_chars - 1)) + "…"


func _truncate_social_text(text: String, max_chars: int) -> String:
	if text.length() <= max_chars:
		return text
	return text.left(maxi(1, max_chars - 2)) + "…"


func _make_margin(left: int, top: int, right: int, bottom: int) -> MarginContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", left)
	margin.add_theme_constant_override("margin_top", top)
	margin.add_theme_constant_override("margin_right", right)
	margin.add_theme_constant_override("margin_bottom", bottom)
	return margin


func _wrap_in_margin(child: Control, left: int, top: int, right: int, bottom: int) -> MarginContainer:
	var margin: MarginContainer = _make_margin(left, top, right, bottom)
	margin.add_child(child)
	return margin


func _make_label(text: String, font_size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _make_bottom_zone(min_size: Vector2) -> PanelContainer:
	var zone: PanelContainer = PanelContainer.new()
	zone.custom_minimum_size = min_size
	zone.size_flags_vertical = Control.SIZE_EXPAND_FILL
	zone.add_theme_stylebox_override("panel", _make_premium_panel_style(Color(0.06, 0.08, 0.16, 0.54), 10))
	return zone


func _make_premium_button(text: String, min_size: Vector2) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", HUD_TEXT_MAIN)
	button.add_theme_color_override("font_hover_color", HUD_TEXT_MAIN)
	button.add_theme_color_override("font_pressed_color", Color(0.10, 0.07, 0.05))
	button.add_theme_stylebox_override("normal", _make_premium_button_style(Color(0.10, 0.13, 0.24, 0.82)))
	button.add_theme_stylebox_override("hover", _make_premium_button_style(Color(0.16, 0.21, 0.36, 0.94)))
	button.add_theme_stylebox_override("pressed", _make_premium_button_style(HUD_ACCENT))
	return button


func _make_social_action_button(text: String) -> Button:
	var button: Button = _make_premium_button(text, Vector2(62.0, 24.0))
	button.add_theme_font_size_override("font_size", 10)
	button.add_theme_stylebox_override("normal", _make_premium_button_style(Color(0.08, 0.10, 0.19, 0.76)))
	button.add_theme_stylebox_override("hover", _make_premium_button_style(Color(0.14, 0.18, 0.32, 0.90)))
	return button


func _make_premium_panel_style(bg_color: Color, radius: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = HUD_BORDER
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.26)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0.0, 2.0)
	return style


func _make_premium_button_style(bg_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = HUD_BORDER
	return style


func _make_room_card_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = _make_premium_button_style(bg_color)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.border_color = border_color
	style.content_margin_left = 18.0
	style.content_margin_right = 18.0
	style.content_margin_top = 9.0
	style.content_margin_bottom = 9.0
	return style


func _on_premium_change_room_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_top_change_room.is_valid():
		_on_top_change_room.call()


func _on_premium_open_shop_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_top_open_shop.is_valid():
		_on_top_open_shop.call()


func _on_premium_open_pause_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_top_open_pause.is_valid():
		_on_top_open_pause.call()


func _on_premium_open_help_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_top_open_help.is_valid():
		_on_top_open_help.call()


func _on_side_lobby_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_side_map_lobby.is_valid():
		_on_side_map_lobby.call()


func _on_side_small_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_side_map_small.is_valid():
		_on_side_map_small.call()


func _on_side_large_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_side_map_large.is_valid():
		_on_side_map_large.call()


func _on_side_more_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_side_map_more.is_valid():
		_on_side_map_more.call()


func _on_bottom_explore_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_bottom_explore.is_valid():
		_on_bottom_explore.call()


func _on_bottom_decorate_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_bottom_decorate.is_valid():
		_on_bottom_decorate.call()


func _on_bottom_shop_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_bottom_shop.is_valid():
		_on_bottom_shop.call()


func _on_bottom_inventory_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_bottom_inventory.is_valid():
		_on_bottom_inventory.call()


func _on_bottom_profile_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_bottom_profile.is_valid():
		_on_bottom_profile.call()


func _on_bottom_emotes_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_bottom_emotes.is_valid():
		_on_bottom_emotes.call()


func _on_bottom_dance_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_bottom_dance.is_valid():
		_on_bottom_dance.call()


func _on_bottom_music_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_bottom_music.is_valid():
		_on_bottom_music.call()


func _on_bottom_photo_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_bottom_photo.is_valid():
		_on_bottom_photo.call()


func _on_premium_commands_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_bottom_commands.is_valid():
		_on_bottom_commands.call()


func _build_toast_panel() -> void:
	toast_panel = PanelContainer.new()
	toast_panel.name = "ToastPanel"
	toast_panel.anchor_left = 0.5
	toast_panel.anchor_top = 0.0
	toast_panel.anchor_right = 0.5
	toast_panel.anchor_bottom = 0.0
	toast_panel.offset_left = -170.0
	toast_panel.offset_top = 72.0
	toast_panel.offset_right = 170.0
	toast_panel.offset_bottom = 120.0
	toast_panel.visible = false
	toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_panel.add_theme_stylebox_override("panel", _make_panel_style(_get_toast_color("info")))
	ui_layer.add_child(toast_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 10)
	toast_panel.add_child(margin)

	toast_label = Label.new()
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.add_theme_color_override("font_color", Color(1.0, 0.98, 0.90))
	toast_label.add_theme_font_size_override("font_size", 14)
	toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(toast_label)


func show_toast(message: String, kind: String = "info") -> void:
	if toast_panel == null or toast_label == null:
		return
	if toast_tween != null and toast_tween.is_valid():
		toast_tween.kill()
	toast_label.text = message
	toast_panel.add_theme_stylebox_override("panel", _make_panel_style(_get_toast_color(kind)))
	toast_panel.modulate.a = 1.0
	toast_panel.visible = true
	toast_panel.move_to_front()
	toast_tween = toast_panel.create_tween()
	toast_tween.tween_interval(1.8)
	toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.25)
	toast_tween.tween_callback(Callable(self, "_finish_toast"))


func hide_toast() -> void:
	if toast_tween != null and toast_tween.is_valid():
		toast_tween.kill()
	toast_tween = null
	_finish_toast()


func _finish_toast() -> void:
	toast_tween = null
	if toast_panel != null:
		toast_panel.visible = false
		toast_panel.modulate.a = 1.0


func _get_toast_color(kind: String) -> Color:
	match kind:
		"success":
			return Color(0.12, 0.22, 0.18, 0.92)
		"warning":
			return Color(0.34, 0.22, 0.10, 0.94)
		"error":
			return Color(0.36, 0.11, 0.10, 0.94)
	return Color(0.10, 0.13, 0.18, 0.92)


func _make_panel_style(bg_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.border_color = Color(1.0, 1.0, 1.0, 0.10)
	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 0
	return style


func clear_children(parent: Node) :
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()


# Wrapper methods for Main.gd compatibility
func toggle_profile() :
	if is_profile_open():
		profile_panel.visible = false
	else:
		show_profile()


func toggle_inventory(_items: Array) :
	if inventory_panel != null:
		inventory_panel.visible = not inventory_panel.visible


func _on_chat_input_submitted(text: String) :
	if _on_chat_submitted.is_valid():
		_on_chat_submitted.call(text)
	close_chat_input(true)


func open_chat_input() :
	focus_chat_input()


func get_chat_text() :
	return get_chat_input_text()


func _build_pause_menu() -> void:
	_pause_overlay = Control.new()
	_pause_overlay.name = "PauseOverlay"
	_pause_overlay.anchor_left = 0.0
	_pause_overlay.anchor_top = 0.0
	_pause_overlay.anchor_right = 1.0
	_pause_overlay.anchor_bottom = 1.0
	_pause_overlay.offset_left = 0.0
	_pause_overlay.offset_top = 0.0
	_pause_overlay.offset_right = 0.0
	_pause_overlay.offset_bottom = 0.0
	_pause_overlay.visible = false
	_pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_layer.add_child(_pause_overlay)

	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.06, 0.55)
	dim.anchor_left = 0.0
	dim.anchor_top = 0.0
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pause_overlay.add_child(dim)

	_pause_menu_panel = PanelContainer.new()
	_pause_menu_panel.name = "PauseMenuPanel"
	_pause_menu_panel.anchor_left = 0.5
	_pause_menu_panel.anchor_top = 0.5
	_pause_menu_panel.anchor_right = 0.5
	_pause_menu_panel.anchor_bottom = 0.5
	_pause_menu_panel.offset_left = -150.0
	_pause_menu_panel.offset_top = -185.0
	_pause_menu_panel.offset_right = 150.0
	_pause_menu_panel.offset_bottom = 185.0
	_pause_menu_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.17, 0.97)))
	_pause_overlay.add_child(_pause_menu_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 18)
	_pause_menu_panel.add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	margin.add_child(layout)

	var title: Label = Label.new()
	title.text = "Menu"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.72))
	layout.add_child(title)

	layout.add_child(HSeparator.new())

	var continue_btn: Button = Button.new()
	continue_btn.text = "Continuar"
	continue_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	continue_btn.pressed.connect(_on_pause_continue_pressed)
	layout.add_child(continue_btn)

	var save_btn: Button = Button.new()
	save_btn.text = "Guardar ahora"
	save_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_btn.pressed.connect(_on_pause_save_pressed)
	layout.add_child(save_btn)

	var settings_btn: Button = Button.new()
	settings_btn.text = "Configuracion"
	settings_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_btn.pressed.connect(_on_pause_settings_pressed)
	layout.add_child(settings_btn)

	var back_rooms_btn: Button = Button.new()
	back_rooms_btn.text = "Volver a salas"
	back_rooms_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back_rooms_btn.pressed.connect(_on_pause_back_to_rooms_pressed)
	layout.add_child(back_rooms_btn)

	var exit_btn: Button = Button.new()
	exit_btn.text = "Salir al menu principal"
	exit_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exit_btn.add_theme_color_override("font_color", Color(1.0, 0.65, 0.65))
	exit_btn.pressed.connect(_on_pause_exit_to_main_pressed)
	layout.add_child(exit_btn)

	_build_pause_exit_confirm()


func _build_pause_exit_confirm() -> void:
	_pause_exit_confirm_panel = PanelContainer.new()
	_pause_exit_confirm_panel.name = "PauseExitConfirmPanel"
	_pause_exit_confirm_panel.anchor_left = 0.5
	_pause_exit_confirm_panel.anchor_top = 0.5
	_pause_exit_confirm_panel.anchor_right = 0.5
	_pause_exit_confirm_panel.anchor_bottom = 0.5
	_pause_exit_confirm_panel.offset_left = -210.0
	_pause_exit_confirm_panel.offset_top = -90.0
	_pause_exit_confirm_panel.offset_right = 210.0
	_pause_exit_confirm_panel.offset_bottom = 90.0
	_pause_exit_confirm_panel.visible = false
	_pause_exit_confirm_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.14, 0.10, 0.07, 0.98)))
	_pause_overlay.add_child(_pause_exit_confirm_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	_pause_exit_confirm_panel.add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var msg: Label = Label.new()
	msg.text = "Salir al menu principal?\nSe guardaran los cambios locales."
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 13)
	msg.add_theme_color_override("font_color", Color(1.0, 0.90, 0.80))
	layout.add_child(msg)

	var btn_row: HBoxContainer = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 12)
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_child(btn_row)

	var cancel_btn: Button = Button.new()
	cancel_btn.text = "Cancelar"
	cancel_btn.pressed.connect(_on_pause_exit_cancel_pressed)
	btn_row.add_child(cancel_btn)

	var confirm_btn: Button = Button.new()
	confirm_btn.text = "Salir"
	confirm_btn.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	confirm_btn.pressed.connect(_on_pause_exit_confirm_pressed)
	btn_row.add_child(confirm_btn)


func show_pause_menu() -> void:
	if _pause_overlay != null:
		_play_ui_sound("panel_open")
		if _pause_exit_confirm_panel != null:
			_pause_exit_confirm_panel.visible = false
		_pause_overlay.visible = true
		_pause_overlay.move_to_front()


func hide_pause_menu() -> void:
	if _pause_overlay != null and _pause_overlay.visible:
		_play_ui_sound("panel_close")
	if _pause_exit_confirm_panel != null:
		_pause_exit_confirm_panel.visible = false
	if _pause_overlay != null:
		_pause_overlay.visible = false


func is_pause_menu_visible() -> bool:
	return _pause_overlay != null and _pause_overlay.visible


func show_pause_button() -> void:
	if _pause_menu_btn != null:
		_pause_menu_btn.visible = true


func hide_pause_button() -> void:
	if _pause_menu_btn != null:
		_pause_menu_btn.visible = false


func show_exit_to_main_confirmation() -> void:
	if _pause_exit_confirm_panel != null:
		_pause_exit_confirm_panel.visible = true
		_pause_exit_confirm_panel.move_to_front()


func hide_exit_to_main_confirmation() -> void:
	if _pause_exit_confirm_panel != null:
		_pause_exit_confirm_panel.visible = false


func set_pause_continue_callback(cb: Callable) -> void:
	_on_pause_continue = cb


func set_pause_save_callback(cb: Callable) -> void:
	_on_pause_save = cb


func set_pause_settings_callback(cb: Callable) -> void:
	_on_pause_settings = cb


func set_pause_back_to_rooms_callback(cb: Callable) -> void:
	_on_pause_back_to_rooms = cb


func set_pause_exit_confirm_callback(cb: Callable) -> void:
	_on_pause_exit_confirm = cb


func _on_pause_menu_btn_pressed() -> void:
	if is_chat_input_active():
		return
	_play_ui_sound("ui_click")
	show_pause_menu()


func _on_pause_continue_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_pause_continue.is_valid():
		_on_pause_continue.call()
	else:
		hide_pause_menu()


func _on_pause_save_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_pause_save.is_valid():
		_on_pause_save.call()


func _on_pause_settings_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_pause_settings.is_valid():
		_on_pause_settings.call()


func _on_pause_back_to_rooms_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_pause_back_to_rooms.is_valid():
		_on_pause_back_to_rooms.call()


func _on_pause_exit_to_main_pressed() -> void:
	_play_ui_sound("ui_click")
	show_exit_to_main_confirmation()


func _on_pause_exit_confirm_pressed() -> void:
	_play_ui_sound("ui_click")
	hide_exit_to_main_confirmation()
	if _on_pause_exit_confirm.is_valid():
		_on_pause_exit_confirm.call()


func _on_pause_exit_cancel_pressed() -> void:
	_play_ui_sound("ui_click")
	hide_exit_to_main_confirmation()


func display_chat_message(chat_entry) :
	# Convert chat_entry to formatted message and update history
	if chat_entry is Dictionary and chat_entry.has("player_name") and chat_entry.has("message"):
		var formatted = chat_entry["player_name"] + ": " + chat_entry["message"]
		update_chat_history([formatted])
	elif chat_entry is String:
		update_chat_history([chat_entry])


func set_about_closed_callback(cb: Callable) -> void:
	_on_about_closed_cb = cb


func _build_about_panel() -> void:
	var overlay: Control = Control.new()
	overlay.name = "AboutOverlay"
	overlay.anchor_left = 0.0
	overlay.anchor_top = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	ui_layer.add_child(overlay)

	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.06, 0.60)
	dim.anchor_left = 0.0
	dim.anchor_top = 0.0
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(dim)

	_about_panel = PanelContainer.new()
	_about_panel.name = "AboutPanel"
	_about_panel.anchor_left = 0.5
	_about_panel.anchor_top = 0.5
	_about_panel.anchor_right = 0.5
	_about_panel.anchor_bottom = 0.5
	_about_panel.offset_left = -250.0
	_about_panel.offset_top = -220.0
	_about_panel.offset_right = 250.0
	_about_panel.offset_bottom = 220.0
	_about_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.07, 0.10, 0.16, 0.97)))
	overlay.add_child(_about_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 18)
	_about_panel.add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)

	var title_lbl: Label = Label.new()
	title_lbl.text = GAME_TITLE
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 26)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.72))
	layout.add_child(title_lbl)

	var version_lbl: Label = Label.new()
	version_lbl.text = GAME_VERSION
	version_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version_lbl.add_theme_color_override("font_color", Color(0.60, 0.70, 0.90))
	layout.add_child(version_lbl)

	layout.add_child(HSeparator.new())

	var desc_lbl: Label = Label.new()
	desc_lbl.text = "Demo local de un juego social isométrico.\nDecora habitaciones, camina, chatea y completa misiones."
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.add_theme_font_size_override("font_size", 13)
	desc_lbl.add_theme_color_override("font_color", Color(0.88, 0.92, 1.0))
	layout.add_child(desc_lbl)

	var status_lbl: Label = Label.new()
	status_lbl.text = "Estado: Prototipo offline/local — sin multijugador ni servidores."
	status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_lbl.add_theme_font_size_override("font_size", 12)
	status_lbl.add_theme_color_override("font_color", Color(0.70, 0.80, 0.70))
	layout.add_child(status_lbl)

	layout.add_child(HSeparator.new())

	var credits_lbl: Label = Label.new()
	credits_lbl.text = "Desarrollado por Esteban Rojas\nMotor: Godot Engine 4\nArte: placeholders procedurales"
	credits_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	credits_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credits_lbl.add_theme_font_size_override("font_size", 12)
	credits_lbl.add_theme_color_override("font_color", Color(0.70, 0.75, 0.85))
	layout.add_child(credits_lbl)

	var close_btn: Button = Button.new()
	close_btn.text = "Cerrar"
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.pressed.connect(hide_about_panel)
	layout.add_child(close_btn)

	overlay.set_meta("_is_about_overlay", true)


func show_about_panel() -> void:
	for child: Node in ui_layer.get_children():
		if child.has_meta("_is_about_overlay"):
			_play_ui_sound("panel_open")
			child.visible = true
			child.move_to_front()
			return


func hide_about_panel() -> void:
	for child: Node in ui_layer.get_children():
		if child.has_meta("_is_about_overlay"):
			if child.visible:
				_play_ui_sound("panel_close")
			child.visible = false
	if _on_about_closed_cb.is_valid():
		_on_about_closed_cb.call()


func is_about_visible() -> bool:
	for child: Node in ui_layer.get_children():
		if child.has_meta("_is_about_overlay"):
			return child.visible
	return false


func _build_splash_panel() -> void:
	_splash_panel = Control.new()
	_splash_panel.name = "SplashPanel"
	_splash_panel.anchor_left = 0.0
	_splash_panel.anchor_top = 0.0
	_splash_panel.anchor_right = 1.0
	_splash_panel.anchor_bottom = 1.0
	_splash_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_splash_panel.visible = false

	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.05, 0.07, 0.12, 1.0)
	bg.anchor_left = 0.0
	bg.anchor_top = 0.0
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_splash_panel.add_child(bg)

	var center: CenterContainer = CenterContainer.new()
	center.anchor_left = 0.0
	center.anchor_top = 0.0
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_splash_panel.add_child(center)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vbox)

	var title_lbl: Label = Label.new()
	title_lbl.text = GAME_TITLE
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 40)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.72))
	vbox.add_child(title_lbl)

	var sub_lbl: Label = Label.new()
	sub_lbl.text = "Cargando demo local..."
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_size_override("font_size", 16)
	sub_lbl.add_theme_color_override("font_color", Color(0.60, 0.70, 0.90))
	vbox.add_child(sub_lbl)

	ui_layer.add_child(_splash_panel)


func show_splash(on_done: Callable) -> void:
	if _splash_panel == null:
		on_done.call()
		return
	_splash_panel.visible = true
	_splash_panel.modulate.a = 1.0
	_splash_panel.move_to_front()
	var tw: Tween = ui_layer.create_tween()
	tw.tween_interval(0.9)
	tw.tween_property(_splash_panel, "modulate:a", 0.0, 0.25)
	tw.tween_callback(Callable(self, "_finish_splash").bind(on_done))


func _finish_splash(on_done: Callable) -> void:
	if _splash_panel != null:
		_splash_panel.visible = false
	on_done.call()
