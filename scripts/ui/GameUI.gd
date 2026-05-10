extends RefCounted

const GAME_TITLE: String = "Kabbo Hotel"
const GAME_VERSION: String = "v0.1.0-demo"

const CHAT_HISTORY_LEFT_MARGIN = 24.0
const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const RoomDataScript = preload("res://scripts/room/RoomData.gd")
const IsoGridScript = preload("res://scripts/room/IsoGrid.gd")
const ShopPanelScene = preload("res://scenes/ui/ShopPanel.tscn")
const ProfilePanelScene = preload("res://scenes/ui/ProfilePanel.tscn")
const MainMenuScene = preload("res://scenes/ui/MainMenu.tscn")
const RoomSelectScene = preload("res://scenes/ui/RoomSelect.tscn")
const SettingsPanelScene = preload("res://scenes/ui/SettingsPanel.tscn")
const PauseMenuScene = preload("res://scenes/ui/PauseMenu.tscn")

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
var room_select_panel: PanelContainer  # instancia de RoomSelect.tscn
var profile_panel: PanelContainer  # instancia de ProfilePanel.tscn
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
var _pause_menu: Control
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
	# Cargado desde MainMenu.tscn — lógica migrada a scripts/ui/panels/MainMenu.gd
	main_menu_panel = MainMenuScene.instantiate() as PanelContainer
	main_menu_panel.enter_hotel_requested.connect(_on_enter_hotel_pressed)
	main_menu_panel.open_profile_requested.connect(show_profile)
	main_menu_panel.open_settings_requested.connect(_on_main_menu_settings_pressed)
	main_menu_panel.open_about_requested.connect(show_about_panel)
	ui_layer.add_child(main_menu_panel)


func _build_room_select() :
	# Cargado desde RoomSelect.tscn — lógica migrada a scripts/ui/panels/RoomSelect.gd
	room_select_panel = RoomSelectScene.instantiate() as PanelContainer
	room_select_panel.room_selected.connect(func(room_id: String):
		_play_ui_sound("ui_click")
		if _on_room_selected.is_valid():
			_on_room_selected.call(room_id)
	)
	room_select_panel.open_profile_requested.connect(show_profile)
	ui_layer.add_child(room_select_panel)


func _on_enter_hotel_pressed() -> void:
	_play_ui_sound("ui_click")
	if _on_enter_hotel.is_valid():
		_on_enter_hotel.call()


func show_room_selector(rooms: Array) :
	if room_select_panel != null and room_select_panel.has_method("populate_rooms"):
		room_select_panel.call("populate_rooms", rooms)
	show_room_select()


func _build_profile_panel() -> void:
	# Cargado desde ProfilePanel.tscn — lógica migrada a scripts/ui/panels/ProfilePanel.gd
	profile_panel = ProfilePanelScene.instantiate() as PanelContainer
	profile_panel.save_requested.connect(func(data: Dictionary): _on_save_profile.call(data))
	profile_panel.panel_closed.connect(func():
		_play_ui_sound("panel_close")
		show_missions_panel()
	)
	ui_layer.add_child(profile_panel)




func show_profile() -> void:
	_play_ui_sound("panel_open")
	hide_shop_panel()
	hide_missions_panel()
	if profile_panel != null:
		profile_panel.visible = true
		profile_panel.move_to_front()


func is_profile_open() -> bool:
	return profile_panel != null and profile_panel.visible


func update_profile_ui(profile_data: Dictionary) -> void:
	# Delegado a ProfilePanel.gd (escena independiente)
	if profile_panel != null and profile_panel.has_method("update_profile"):
		profile_panel.call("update_profile", profile_data)


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
	catalog_panel.offset_left = -244.0
	catalog_panel.offset_top = 78.0
	catalog_panel.offset_right = -14.0
	catalog_panel.offset_bottom = -112.0
	catalog_panel.custom_minimum_size = Vector2(230.0, 0.0)
	catalog_panel.visible = false
	catalog_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.17, 0.90)))
	ui_layer.add_child(catalog_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
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
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	vbox.add_child(scroll)

	_catalog_items_vbox = VBoxContainer.new()
	_catalog_items_vbox.add_theme_constant_override("separation", 4)
	_catalog_items_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_catalog_items_vbox.custom_minimum_size = Vector2(196.0, 0.0)
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
		btn.custom_minimum_size = Vector2(0.0, 28.0)
		btn.add_theme_font_size_override("font_size", 11)
		btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
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
		btn.custom_minimum_size = Vector2(0.0, 34.0)
		btn.add_theme_font_size_override("font_size", 13)
		btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
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
	settings_panel = SettingsPanelScene.instantiate() as PanelContainer
	settings_panel.autosave_enabled_changed.connect(func(v: bool) -> void:
		_play_ui_sound("ui_click")
		if _on_settings_autosave_enabled.is_valid(): _on_settings_autosave_enabled.call(v)
	)
	settings_panel.autosave_interval_changed.connect(func(v: float) -> void:
		_play_ui_sound("ui_click")
		if _on_settings_autosave_interval.is_valid(): _on_settings_autosave_interval.call(v)
	)
	settings_panel.show_missions_changed.connect(func(v: bool) -> void:
		_play_ui_sound("ui_click")
		_missions_display_enabled = v
		if not v: hide_premium_objective_panel()
		if _on_settings_show_missions.is_valid(): _on_settings_show_missions.call(v)
	)
	settings_panel.sfx_enabled_changed.connect(func(v: bool) -> void:
		if _on_settings_sfx_enabled.is_valid(): _on_settings_sfx_enabled.call(v)
		_play_ui_sound("ui_click")
	)
	settings_panel.sfx_volume_changed.connect(func(v: float) -> void:
		if _on_settings_sfx_volume.is_valid(): _on_settings_sfx_volume.call(v)
		_play_ui_sound("ui_click")
	)
	settings_panel.tutorial_restart_requested.connect(func() -> void:
		_play_ui_sound("ui_click")
		if _on_settings_tutorial_restart.is_valid(): _on_settings_tutorial_restart.call()
	)
	settings_panel.reset_data_requested.connect(func() -> void:
		_play_ui_sound("ui_click")
		if _on_settings_reset_data.is_valid(): _on_settings_reset_data.call()
	)
	settings_panel.panel_closed.connect(func() -> void:
		_play_ui_sound("panel_close")
		if _on_settings_closed_cb.is_valid(): _on_settings_closed_cb.call()
	)
	ui_layer.add_child(settings_panel)


func show_settings_panel(settings_data: Dictionary) -> void:
	update_settings_panel(settings_data)
	if settings_panel != null:
		_play_ui_sound("panel_open")
		settings_panel.visible = true
		settings_panel.move_to_front()


func hide_settings_panel() -> void:
	if settings_panel != null:
		if settings_panel.visible:
			_play_ui_sound("panel_close")
		settings_panel.visible = false
	if _on_settings_closed_cb.is_valid():
		_on_settings_closed_cb.call()


func is_settings_visible() -> bool:
	return settings_panel != null and settings_panel.visible


func update_settings_panel(settings_data: Dictionary) -> void:
	if settings_panel != null and settings_panel.has_method("update_settings"):
		settings_panel.call("update_settings", settings_data)
	var show_m: bool = bool(settings_data.get("show_missions", true))
	_missions_display_enabled = show_m
	if not show_m:
		hide_premium_objective_panel()


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
	# Cargado desde ShopPanel.tscn — lógica migrada a scripts/ui/panels/ShopPanel.gd
	shop_panel = ShopPanelScene.instantiate() as PanelContainer
	shop_panel.buy_requested.connect(_on_shop_buy_pressed)
	shop_panel.panel_closed.connect(_on_shop_close_pressed)
	ui_layer.add_child(shop_panel)


func show_shop_panel(items: Array[Dictionary], credits: int, stock_data: Dictionary = {}) -> void:
	if shop_panel != null and shop_panel.has_method("show_with_data"):
		_play_ui_sound("panel_open")
		shop_panel.call("show_with_data", items, credits, stock_data)
	else:
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
	# Delegado a ShopPanel.gd (escena independiente)
	if shop_panel != null and shop_panel.has_method("update_items"):
		shop_panel.call("update_items", items, credits, stock_data)


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
	btn.custom_minimum_size = Vector2(0.0, 44.0)  # Increased height from 38px to 44px for better readability
	btn.add_theme_stylebox_override("normal", _make_panel_style(Color(0, 0, 0, 0)))
	btn.add_theme_stylebox_override("hover", _make_panel_style(Color(0.10, 0.14, 0.22, 0.35)))
	btn.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.14, 0.18, 0.26, 0.45)))

	var h: HBoxContainer = HBoxContainer.new()
	h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.mouse_filter = Control.MOUSE_FILTER_STOP
	h.add_theme_constant_override("separation", 6)  # Reduced from 7px to 6px to gain horizontal space
	btn.add_child(h)

	# Avatar with initial - reduced from 30x30 to 28x28 to gain horizontal space
	var avatar: ColorRect = ColorRect.new()
	avatar.custom_minimum_size = Vector2(28.0, 28.0)
	avatar.color = person.get("color", HUD_ACCENT)
	h.add_child(avatar)

	var initial: Label = Label.new()
	initial.text = str(person.get("name", "?")).substr(0, 1).to_upper()
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.add_theme_color_override("font_color", Color(1, 1, 1))
	initial.add_theme_font_size_override("font_size", 12)
	avatar.add_child(initial)

	# Info section - expanded with SIZE_EXPAND_FILL to take available space
	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)  # Increased from 1px to 2px for better readability
	h.add_child(info)

	# Name - increased truncation limit from 20 to 26 chars
	var name_lbl: Label = Label.new()
	name_lbl.text = _truncate_social_text(str(person.get("name", "Invitado")), 26)
	name_lbl.add_theme_color_override("font_color", HUD_TEXT_MAIN)
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Expand to fill available space
	info.add_child(name_lbl)

	# Role only - simplified (removed status combination to save space)
	var role_row: HBoxContainer = HBoxContainer.new()
	role_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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

	# Role text only - show just the role for clarity and space efficiency
	var role_text: String = str(person.get("role", "Visitante"))
	var role_lbl: Label = Label.new()
	role_lbl.text = _truncate_social_text(role_text, 24)  # Reduced from 28 to 24 for role-only text
	role_lbl.add_theme_color_override("font_color", HUD_TEXT_SECONDARY)
	role_lbl.add_theme_font_size_override("font_size", 10)
	role_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Expand to fill available space
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
	_pause_menu = PauseMenuScene.instantiate() as Control
	_pause_menu.resume_requested.connect(func() -> void:
		_play_ui_sound("ui_click")
		if _on_pause_continue.is_valid(): _on_pause_continue.call()
		else: hide_pause_menu()
	)
	_pause_menu.save_requested.connect(func() -> void:
		_play_ui_sound("ui_click")
		if _on_pause_save.is_valid(): _on_pause_save.call()
	)
	_pause_menu.settings_requested.connect(func() -> void:
		_play_ui_sound("ui_click")
		if _on_pause_settings.is_valid(): _on_pause_settings.call()
	)
	_pause_menu.back_to_rooms_requested.connect(func() -> void:
		_play_ui_sound("ui_click")
		if _on_pause_back_to_rooms.is_valid(): _on_pause_back_to_rooms.call()
	)
	_pause_menu.exit_requested.connect(func() -> void:
		_play_ui_sound("ui_click")
		if _on_pause_exit_confirm.is_valid(): _on_pause_exit_confirm.call()
	)
	ui_layer.add_child(_pause_menu)


func show_pause_menu() -> void:
	if _pause_menu != null:
		_play_ui_sound("panel_open")
		if _pause_menu.has_method("hide_exit_confirm"): _pause_menu.call("hide_exit_confirm")
		_pause_menu.visible = true
		_pause_menu.move_to_front()


func hide_pause_menu() -> void:
	if _pause_menu != null and _pause_menu.visible:
		_play_ui_sound("panel_close")
	if _pause_menu != null:
		if _pause_menu.has_method("hide_exit_confirm"): _pause_menu.call("hide_exit_confirm")
		_pause_menu.visible = false


func is_pause_menu_visible() -> bool:
	return _pause_menu != null and _pause_menu.visible


func show_pause_button() -> void:
	if _pause_menu_btn != null:
		_pause_menu_btn.visible = true


func hide_pause_button() -> void:
	if _pause_menu_btn != null:
		_pause_menu_btn.visible = false


func show_exit_to_main_confirmation() -> void:
	if _pause_menu != null and _pause_menu.has_method("show_exit_confirm"):
		_pause_menu.call("show_exit_confirm")


func hide_exit_to_main_confirmation() -> void:
	if _pause_menu != null and _pause_menu.has_method("hide_exit_confirm"):
		_pause_menu.call("hide_exit_confirm")


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
