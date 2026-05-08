extends RefCounted
class_name GameUI

var ui_layer: CanvasLayer
var room_label: Label
var status_label: Label


func _init(root: Node) -> void:
	setup_ui(root)


func setup_ui(root: Node) -> void:
	var existing_ui: Node = root.get_node_or_null("UI")

	if existing_ui is CanvasLayer:
		ui_layer = existing_ui as CanvasLayer
	else:
		ui_layer = CanvasLayer.new()
		ui_layer.name = "UI"
		root.add_child(ui_layer)

	clear_children(ui_layer)

	var panel: PanelContainer = PanelContainer.new()
	panel.name = "ControlsPanel"
	panel.anchor_left = 0.0
	panel.anchor_top = 1.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 16.0
	panel.offset_top = -136.0
	panel.offset_right = -16.0
	panel.offset_bottom = -16.0
	ui_layer.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	margin.add_child(layout)

	room_label = Label.new()
	room_label.name = "RoomLabel"
	room_label.text = "Sala: Lobby"
	room_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(room_label)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "Sin seleccion"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(status_label)

	var controls_label: Label = Label.new()
	controls_label.name = "ControlsLabel"
	controls_label.text = "1 Silla | 2 Mesa | 3 Sofa | Escape Cancelar | M Mover | R Rotar | Delete Eliminar | S Guardar | L Cargar | F1 Lobby | F2 Sala pequeña | F3 Sala grande"
	controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(controls_label)


func set_room_name(room_name: String) -> void:
	if room_label != null:
		room_label.text = "Sala: " + room_name


func set_status_message(message: String) -> void:
	if status_label != null:
		status_label.text = message


func report_status(message: String) -> void:
	print(message)
	set_status_message(message)


func clear_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
