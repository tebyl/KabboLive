extends RefCounted


const CHAT_HISTORY_LEFT_MARGIN = 24.0
const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const RoomDataScript = preload("res://scripts/room/RoomData.gd")
const IsoGridScript = preload("res://scripts/room/IsoGrid.gd")

const FurnitureData = FurnitureDataScript
const RoomData = RoomDataScript
const IsoGrid = IsoGridScript
const CHAT_HISTORY_BOTTOM_GAP = 152.0
const CHAT_HISTORY_WIDTH = 380.0
const CHAT_BUBBLE_MAX_WIDTH = 300.0
const CHAT_BUBBLE_MIN_WIDTH = 140.0

var ui_layer: CanvasLayer
var room_label: Label
var status_label: Label
var controls_panel: PanelContainer
var main_menu_panel: PanelContainer
var room_select_panel: PanelContainer
var room_select_vbox: VBoxContainer
var profile_panel: PanelContainer
var profile_name_edit: LineEdit
var profile_color_rect: ColorRect
var current_profile_color: Color = Color.BLUE
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
	_build_toast_panel()
	_build_tutorial_panel()


func _build_main_menu() :
	main_menu_panel = PanelContainer.new()
	main_menu_panel.name = "MainMenuPanel"
	main_menu_panel.anchor_left = 0.5
	main_menu_panel.anchor_top = 0.5
	main_menu_panel.anchor_right = 0.5
	main_menu_panel.anchor_bottom = 0.5
	main_menu_panel.offset_left = -180.0
	main_menu_panel.offset_top = -100.0
	main_menu_panel.offset_right = 180.0
	main_menu_panel.offset_bottom = 100.0
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
	title.text = "Kabbo Hotel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var enter_btn: Button = Button.new()
	enter_btn.text = "Entrar al hotel"
	enter_btn.pressed.connect(_on_enter_hotel)
	vbox.add_child(enter_btn)

	var profile_btn: Button = Button.new()
	profile_btn.text = "Perfil"
	profile_btn.pressed.connect(show_profile)
	vbox.add_child(profile_btn)


func _build_room_select() :
	room_select_panel = PanelContainer.new()
	room_select_panel.name = "RoomSelectPanel"
	room_select_panel.anchor_left = 0.5
	room_select_panel.anchor_top = 0.5
	room_select_panel.anchor_right = 0.5
	room_select_panel.anchor_bottom = 0.5
	room_select_panel.offset_left = -180.0
	room_select_panel.offset_top = -160.0
	room_select_panel.offset_right = 180.0
	room_select_panel.offset_bottom = 160.0
	ui_layer.add_child(room_select_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	room_select_panel.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Seleccionar sala"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	room_select_vbox = vbox

	# default buttons (kept for backward compatibility)
	_add_room_button(room_select_vbox, "lobby", "Lobby")
	_add_room_button(room_select_vbox, "room_small", "Sala pequeña")
	_add_room_button(room_select_vbox, "room_large", "Sala grande")

	var profile_btn: Button = Button.new()
	profile_btn.text = "Editar Perfil"
	profile_btn.pressed.connect(show_profile)
	vbox.add_child(profile_btn)


func _add_room_button(parent: VBoxContainer, room_id, label_text) :
	var btn: Button = Button.new()
	btn.text = label_text
	btn.pressed.connect(_on_room_selected.bind(room_id))
	parent.add_child(btn)


func show_room_selector(rooms: Array) :
	if room_select_vbox == null:
		return
	# clear existing room buttons (keep title and profile button)
	for child in room_select_vbox.get_children():
		if child is Button and child.text != "Editar Perfil":
			room_select_vbox.remove_child(child)
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
			_add_room_button(room_select_vbox, room_id, r_label)

	# Make panel visible
	show_room_select()


func _build_profile_panel() :
	profile_panel = PanelContainer.new()
	profile_panel.name = "ProfilePanel"
	profile_panel.anchor_left = 0.5
	profile_panel.anchor_top = 0.5
	profile_panel.anchor_right = 0.5
	profile_panel.anchor_bottom = 0.5
	profile_panel.offset_left = -200.0
	profile_panel.offset_top = -180.0
	profile_panel.offset_right = 200.0
	profile_panel.offset_bottom = 180.0
	profile_panel.visible = false
	profile_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.12, 0.15, 0.22, 0.95)))
	ui_layer.add_child(profile_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	profile_panel.add_child(margin)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	margin.add_child(vbox)

	var title: Label = Label.new()
	title.text = "Perfil de Usuario"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var name_label: Label = Label.new()
	name_label.text = "Nombre:"
	vbox.add_child(name_label)

	profile_name_edit = LineEdit.new()
	profile_name_edit.max_length = 16
	vbox.add_child(profile_name_edit)

	var color_label: Label = Label.new()
	color_label.text = "Color del avatar:"
	vbox.add_child(color_label)

	var color_hbox: HBoxContainer = HBoxContainer.new()
	color_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	color_hbox.add_theme_constant_override("separation", 10)
	vbox.add_child(color_hbox)

	_add_color_button(color_hbox, Color(0.14, 0.32, 0.72), "Azul")
	_add_color_button(color_hbox, Color(0.25, 0.55, 0.25), "Verde")
	_add_color_button(color_hbox, Color(0.72, 0.14, 0.14), "Rojo")

	profile_color_rect = ColorRect.new()
	profile_color_rect.custom_minimum_size = Vector2(40, 40)
	vbox.add_child(profile_color_rect)

	var footer_hbox: HBoxContainer = HBoxContainer.new()
	footer_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	footer_hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(footer_hbox)

	var save_btn: Button = Button.new()
	save_btn.text = "Guardar"
	save_btn.pressed.connect(_on_save_clicked)
	footer_hbox.add_child(save_btn)

	var back_btn: Button = Button.new()
	back_btn.text = "Volver"
	back_btn.pressed.connect(_on_profile_back_clicked)
	footer_hbox.add_child(back_btn)


func _add_color_button(parent: Control, color: Color, _text) :
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(60, 30)
	btn.text = _text
	btn.pressed.connect(func(): set_profile_preview_color(color))
	parent.add_child(btn)


func set_profile_preview_color(color: Color) :
	current_profile_color = color
	if profile_color_rect != null:
		profile_color_rect.color = color


func _on_save_clicked() :
	_on_save_profile.call(profile_name_edit.text, current_profile_color)


func _on_profile_back_clicked() :
	profile_panel.visible = false
	if help_button != null and controls_panel != null and controls_panel.visible:
		help_button.visible = true
	show_shop_button()
	show_missions_panel()


func show_profile() :
	if help_button != null:
		help_button.visible = false
	hide_shop_button()
	hide_shop_panel()
	hide_missions_panel()
	profile_panel.visible = true
	profile_panel.move_to_front()


func is_profile_open() :
	return profile_panel != null and profile_panel.visible


func update_profile_ui(p_name, p_color: Color) :
	if profile_name_edit != null:
		profile_name_edit.text = p_name
	set_profile_preview_color(p_color)


func _build_controls_panel() :
	controls_panel = PanelContainer.new()
	controls_panel.name = "ControlsPanel"
	controls_panel.anchor_left = 0.0
	controls_panel.anchor_top = 1.0
	controls_panel.anchor_right = 1.0
	controls_panel.anchor_bottom = 1.0
	controls_panel.offset_left = 16.0
	controls_panel.offset_top = -128.0
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

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "Sin seleccion"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.add_theme_color_override("font_color", Color(0.84, 0.91, 1.0, 1.0))
	top_row.add_child(status_label)

	credits_label = Label.new()
	credits_label.name = "CreditsLabel"
	credits_label.text = "Créditos: 0"
	credits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	credits_label.custom_minimum_size = Vector2(116.0, 0.0)
	credits_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.48, 1.0))
	top_row.add_child(credits_label)

	var back_btn: Button = Button.new()
	back_btn.text = "Volver a salas"
	back_btn.pressed.connect(_on_back_to_rooms)
	top_row.add_child(back_btn)

	help_button = Button.new()
	help_button.text = "Ayuda"
	help_button.custom_minimum_size = Vector2(72.0, 0.0)
	help_button.pressed.connect(_on_help_pressed)
	top_row.add_child(help_button)

	shop_button = Button.new()
	shop_button.text = "Tienda"
	shop_button.custom_minimum_size = Vector2(76.0, 0.0)
	shop_button.pressed.connect(_on_shop_button_pressed)
	top_row.add_child(shop_button)

	var controls_label: Label = Label.new()
	controls_label.name = "ControlsLabel"
	controls_label.text = "Enter Chat  |  Esc Deseleccionar / Volver  |  S Guardar  |  L Cargar  |  F1 Lobby  |  F2 Sala pequeña  |  F3 Sala grande"
	controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	controls_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_label.add_theme_font_size_override("font_size", 13)
	controls_label.add_theme_color_override("font_color", Color(0.78, 0.86, 0.94, 1.0))
	layout.add_child(controls_label)


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
	missions_panel.offset_left = 236.0
	missions_panel.offset_top = 16.0
	missions_panel.offset_right = 520.0
	missions_panel.offset_bottom = 198.0
	missions_panel.visible = false
	missions_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.17, 0.88)))
	ui_layer.add_child(missions_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	missions_panel.add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 7)
	margin.add_child(layout)

	var title: Label = Label.new()
	title.text = "Misiones"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.72))
	title.add_theme_font_size_override("font_size", 15)
	layout.add_child(title)

	_missions_list_vbox = VBoxContainer.new()
	_missions_list_vbox.add_theme_constant_override("separation", 4)
	layout.add_child(_missions_list_vbox)


func show_missions_panel() -> void:
	if missions_panel != null and not is_tutorial_visible():
		missions_panel.visible = true
	if credits_label != null and controls_panel != null and controls_panel.visible and not is_tutorial_visible():
		credits_label.visible = true


func hide_missions_panel() -> void:
	if missions_panel != null:
		missions_panel.visible = false
	if credits_label != null:
		credits_label.visible = false


func update_credits(amount: int) -> void:
	if credits_label != null:
		credits_label.text = "Créditos: " + str(amount)


func update_missions(missions: Array[Dictionary]) -> void:
	if _missions_list_vbox == null:
		return
	for child: Node in _missions_list_vbox.get_children():
		_missions_list_vbox.remove_child(child)
		child.queue_free()
	for mission: Dictionary in missions:
		var label: Label = Label.new()
		var completed: bool = bool(mission.get("completed", false))
		var reward: int = int(mission.get("reward_credits", 0))
		var marker: String = "✓" if completed else "□"
		label.text = marker + " " + str(mission.get("title", "")) + " (+" + str(reward) + ")"
		label.tooltip_text = str(mission.get("description", ""))
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.70, 0.94, 0.72) if completed else Color(0.86, 0.90, 0.96))
		_missions_list_vbox.add_child(label)


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
	chat_history_panel.offset_top = -308.0
	chat_history_panel.offset_right = CHAT_HISTORY_LEFT_MARGIN + CHAT_HISTORY_WIDTH
	chat_history_panel.offset_bottom = -CHAT_HISTORY_BOTTOM_GAP
	chat_history_panel.visible = false
	chat_history_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.13, 0.76)))
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
	chat_input_panel.offset_top = -64.0
	chat_input_panel.offset_right = 220.0
	chat_input_panel.offset_bottom = -16.0
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
	furniture_inspector_panel.offset_top = 16.0
	furniture_inspector_panel.offset_right = 220.0
	furniture_inspector_panel.offset_bottom = 290.0
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
		"chair": return "Silla"
		"table": return "Mesa"
		"sofa":  return "Sofá"
		"plant": return "Planta"
		"rug":   return "Alfombra"
	match furniture_type:
		"blue_rug": return "Alfombra Azul"
		"golden_plant": return "Planta Dorada"
		"lounge_chair": return "SillÃ³n Lounge"
	return furniture_type


func _on_inspector_move_pressed() -> void:
	if is_chat_input_active():
		return
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
	if _on_inspector_close.is_valid():
		_on_inspector_close.call()


func _build_furniture_catalog() -> void:
	catalog_panel = PanelContainer.new()
	catalog_panel.name = "CatalogPanel"
	catalog_panel.anchor_left = 1.0
	catalog_panel.anchor_top = 0.5
	catalog_panel.anchor_right = 1.0
	catalog_panel.anchor_bottom = 0.5
	catalog_panel.offset_left = -182.0
	catalog_panel.offset_top = -170.0
	catalog_panel.offset_right = -16.0
	catalog_panel.offset_bottom = 170.0
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

	_catalog_items_vbox = VBoxContainer.new()
	_catalog_items_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(_catalog_items_vbox)


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


func hide_furniture_catalog() -> void:
	if catalog_panel != null:
		catalog_panel.visible = false


func show_main_menu() :
	main_menu_panel.visible = true
	room_select_panel.visible = false
	profile_panel.visible = false
	controls_panel.visible = false
	chat_history_panel.visible = false
	chat_input_panel.visible = false
	if inventory_panel != null:
		inventory_panel.visible = false
	if help_button != null:
		help_button.visible = false
	hide_shop_button()
	hide_shop_panel()
	hide_missions_panel()
	hide_chat_bubble()
	hide_npc_bubble()
	hide_toast()
	hide_tutorial()
	hide_furniture_catalog()
	hide_furniture_inspector()
	hide_overlap_selector()


func show_room_select() :
	main_menu_panel.visible = false
	room_select_panel.visible = true
	profile_panel.visible = false
	controls_panel.visible = false
	chat_history_panel.visible = false
	chat_input_panel.visible = false
	if inventory_panel != null:
		inventory_panel.visible = false
	if help_button != null:
		help_button.visible = false
	hide_missions_panel()
	hide_chat_bubble()
	hide_npc_bubble()
	hide_toast()
	hide_tutorial()
	hide_furniture_catalog()
	hide_furniture_inspector()
	hide_overlap_selector()


func show_in_room() :
	main_menu_panel.visible = false
	room_select_panel.visible = false
	profile_panel.visible = false
	controls_panel.visible = true
	if help_button != null:
		help_button.visible = true
	show_shop_button()
	show_missions_panel()
	show_furniture_catalog()


func set_room_name(room_name) :
	if room_label != null:
		room_label.text = "Sala: " + room_name


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
	hide_shop_button()
	hide_shop_panel()
	hide_missions_panel()
	set_tutorial_step(0)
	tutorial_overlay.visible = true
	tutorial_overlay.move_to_front()


func hide_tutorial() -> void:
	if tutorial_overlay != null:
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
	set_tutorial_step(tutorial_step_index - 1)


func _on_tutorial_next_pressed() -> void:
	set_tutorial_step(tutorial_step_index + 1)


func _on_tutorial_skip_pressed() -> void:
	_close_tutorial(true)


func _on_tutorial_finish_pressed() -> void:
	_close_tutorial(true)


func _on_help_pressed() -> void:
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
		shop_panel.visible = true
		shop_panel.move_to_front()
	hide_missions_panel()


func hide_shop_panel() -> void:
	if shop_panel != null:
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
	if is_shop_visible():
		hide_shop_panel()
	elif _on_shop_item_buy.is_valid():
		_on_shop_item_buy.call("__open_shop__")


func _on_shop_buy_pressed(item_id: String) -> void:
	if _on_shop_item_buy.is_valid():
		_on_shop_item_buy.call(item_id)


func _on_shop_close_pressed() -> void:
	hide_shop_panel()


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
	style.border_color = Color(1.0, 1.0, 1.0, 0.14)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
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


func display_chat_message(chat_entry) :
	# Convert chat_entry to formatted message and update history
	if chat_entry is Dictionary and chat_entry.has("player_name") and chat_entry.has("message"):
		var formatted = chat_entry["player_name"] + ": " + chat_entry["message"]
		update_chat_history([formatted])
	elif chat_entry is String:
		update_chat_history([chat_entry])
