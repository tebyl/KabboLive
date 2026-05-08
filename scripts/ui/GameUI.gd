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
var chat_bubble_timer = 0.0
var chat_bubble_visible = false

var _on_enter_hotel: Callable
var _on_room_selected: Callable
var _on_back_to_rooms: Callable
var _on_save_profile: Callable


func _init(root: Node, on_enter_hotel: Callable, on_room_selected: Callable, on_back_to_rooms: Callable, on_save_profile: Callable) :
	_on_enter_hotel = on_enter_hotel
	_on_room_selected = on_room_selected
	_on_back_to_rooms = on_back_to_rooms
	_on_save_profile = on_save_profile
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
	_build_chat_ui()


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


func show_profile() :
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

	var back_btn: Button = Button.new()
	back_btn.text = "Volver a salas"
	back_btn.pressed.connect(_on_back_to_rooms)
	top_row.add_child(back_btn)

	var controls_label: Label = Label.new()
	controls_label.name = "ControlsLabel"
	controls_label.text = "Enter Chat | 1 Silla | 2 Mesa | 3 Sofa | Esc Volver a salas | M Mover | R Rotar | Delete Eliminar | S Guardar | L Cargar | F1 Lobby | F2 Sala pequeña | F3 Sala grande"
	controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	controls_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_label.add_theme_font_size_override("font_size", 13)
	controls_label.add_theme_color_override("font_color", Color(0.78, 0.86, 0.94, 1.0))
	layout.add_child(controls_label)


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


func show_main_menu() :
	main_menu_panel.visible = true
	room_select_panel.visible = false
	profile_panel.visible = false
	controls_panel.visible = false
	chat_history_panel.visible = false
	chat_input_panel.visible = false
	hide_chat_bubble()


func show_room_select() :
	main_menu_panel.visible = false
	room_select_panel.visible = true
	profile_panel.visible = false
	controls_panel.visible = false
	chat_history_panel.visible = false
	chat_input_panel.visible = false
	hide_chat_bubble()


func show_in_room() :
	main_menu_panel.visible = false
	room_select_panel.visible = false
	profile_panel.visible = false
	controls_panel.visible = true


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
	# Placeholder for inventory toggle - can be expanded later
	pass


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
