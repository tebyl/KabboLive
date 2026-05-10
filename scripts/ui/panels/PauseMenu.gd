extends Control

signal resume_requested()
signal save_requested()
signal settings_requested()
signal back_to_rooms_requested()
signal exit_requested()

var _exit_confirm_panel: PanelContainer

const _PANEL_BG: Color = Color(0.08, 0.11, 0.17, 0.97)
const _ACCENT: Color = Color(1.0, 0.95, 0.72)

func _ready() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.03, 0.06, 0.55)
	dim.anchor_left = 0.0
	dim.anchor_top = 0.0
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -150.0
	panel.offset_top = -185.0
	panel.offset_right = 150.0
	panel.offset_bottom = 185.0
	panel.add_theme_stylebox_override("panel", _make_style(_PANEL_BG))
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	margin.add_child(layout)

	var title := Label.new()
	title.text = "Menu"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", _ACCENT)
	layout.add_child(title)
	layout.add_child(HSeparator.new())

	_add_menu_btn(layout, "Continuar", _on_continue_pressed)
	_add_menu_btn(layout, "Guardar ahora", _on_save_pressed)
	_add_menu_btn(layout, "Configuracion", _on_settings_pressed)
	_add_menu_btn(layout, "Volver a salas", _on_back_to_rooms_pressed)

	var exit_btn := Button.new()
	exit_btn.text = "Salir al menu principal"
	exit_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	exit_btn.add_theme_color_override("font_color", Color(1.0, 0.65, 0.65))
	exit_btn.pressed.connect(_on_exit_pressed)
	layout.add_child(exit_btn)

	_build_exit_confirm()


func _build_exit_confirm() -> void:
	_exit_confirm_panel = PanelContainer.new()
	_exit_confirm_panel.anchor_left = 0.5
	_exit_confirm_panel.anchor_top = 0.5
	_exit_confirm_panel.anchor_right = 0.5
	_exit_confirm_panel.anchor_bottom = 0.5
	_exit_confirm_panel.offset_left = -210.0
	_exit_confirm_panel.offset_top = -90.0
	_exit_confirm_panel.offset_right = 210.0
	_exit_confirm_panel.offset_bottom = 90.0
	_exit_confirm_panel.visible = false
	_exit_confirm_panel.add_theme_stylebox_override("panel", _make_style(Color(0.14, 0.10, 0.07, 0.98)))
	add_child(_exit_confirm_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	_exit_confirm_panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	margin.add_child(layout)

	var msg := Label.new()
	msg.text = "Salir al menu principal?\nSe guardaran los cambios locales."
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 13)
	msg.add_theme_color_override("font_color", Color(1.0, 0.90, 0.80))
	layout.add_child(msg)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 12)
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_child(btn_row)

	var cancel_btn := Button.new()
	cancel_btn.text = "Cancelar"
	cancel_btn.pressed.connect(func() -> void: _exit_confirm_panel.visible = false)
	btn_row.add_child(cancel_btn)

	var confirm_btn := Button.new()
	confirm_btn.text = "Salir"
	confirm_btn.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	confirm_btn.pressed.connect(_on_exit_confirmed)
	btn_row.add_child(confirm_btn)


func show_exit_confirm() -> void:
	if _exit_confirm_panel != null:
		_exit_confirm_panel.visible = true
		_exit_confirm_panel.move_to_front()


func hide_exit_confirm() -> void:
	if _exit_confirm_panel != null:
		_exit_confirm_panel.visible = false


func _on_continue_pressed() -> void:
	resume_requested.emit()


func _on_save_pressed() -> void:
	save_requested.emit()


func _on_settings_pressed() -> void:
	settings_requested.emit()


func _on_back_to_rooms_pressed() -> void:
	back_to_rooms_requested.emit()


func _on_exit_pressed() -> void:
	show_exit_confirm()


func _on_exit_confirmed() -> void:
	hide_exit_confirm()
	exit_requested.emit()


func _add_menu_btn(parent: VBoxContainer, text: String, cb: Callable) -> void:
	var btn := Button.new()
	btn.text = text
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(cb)
	parent.add_child(btn)


func _make_style(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.corner_radius_top_left = 6
	s.corner_radius_top_right = 6
	s.corner_radius_bottom_right = 6
	s.corner_radius_bottom_left = 6
	s.border_width_left = 1
	s.border_width_top = 1
	s.border_width_right = 1
	s.border_width_bottom = 1
	s.border_color = Color(0.48, 0.60, 0.78, 0.28)
	return s
