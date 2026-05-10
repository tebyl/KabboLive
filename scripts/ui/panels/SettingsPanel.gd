extends PanelContainer

signal autosave_enabled_changed(enabled: bool)
signal autosave_interval_changed(seconds: float)
signal show_missions_changed(enabled: bool)
signal sfx_enabled_changed(enabled: bool)
signal sfx_volume_changed(value: float)
signal tutorial_restart_requested()
signal reset_data_requested()
signal panel_closed()

var _autosave_toggle_btn: Button
var _interval_btns: Array[Button] = []
var _missions_btn: Button
var _sfx_toggle_btn: Button
var _sfx_volume_btns: Array[Button] = []
var _confirm_reset_panel: PanelContainer

const _PANEL_BG: Color = Color(0.08, 0.11, 0.17, 0.97)
const _TEXT_MAIN: Color = Color(0.88, 0.92, 1.0)
const _TEXT_DIM: Color = Color(0.72, 0.80, 0.92)
const _ACCENT: Color = Color(1.0, 0.95, 0.72)
const _ACTIVE_BG: Color = Color(0.20, 0.38, 0.58, 0.92)

func _ready() -> void:
	anchor_left = 0.5
	anchor_top = 0.5
	anchor_right = 0.5
	anchor_bottom = 0.5
	offset_left = -220.0
	offset_top = -280.0
	offset_right = 220.0
	offset_bottom = 280.0
	visible = false
	add_theme_stylebox_override("panel", _make_style(_PANEL_BG))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	margin.add_child(layout)

	var title := Label.new()
	title.text = "Configuración"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", _ACCENT)
	layout.add_child(title)
	layout.add_child(HSeparator.new())

	# Autosave toggle
	var autosave_row := _make_row(layout, "Guardado automático")
	_autosave_toggle_btn = _make_wide_btn("Activado", autosave_row, _on_autosave_toggle_pressed)

	# Interval buttons
	var interval_row := HBoxContainer.new()
	interval_row.add_theme_constant_override("separation", 4)
	layout.add_child(interval_row)
	var interval_lbl := _make_small_label("Intervalo:", interval_row)
	interval_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_interval_btns.clear()
	for secs: float in [30.0, 60.0, 120.0]:
		var ibtn := Button.new()
		ibtn.text = str(int(secs)) + "s"
		ibtn.custom_minimum_size = Vector2(48.0, 0.0)
		ibtn.pressed.connect(_on_interval_pressed.bind(secs))
		interval_row.add_child(ibtn)
		_interval_btns.append(ibtn)

	layout.add_child(HSeparator.new())

	# SFX toggle
	var sfx_row := _make_row(layout, "Sonidos")
	_sfx_toggle_btn = _make_wide_btn("Activado", sfx_row, _on_sfx_toggle_pressed)

	# SFX volume
	var vol_row := HBoxContainer.new()
	vol_row.add_theme_constant_override("separation", 4)
	layout.add_child(vol_row)
	var vol_lbl := _make_small_label("Volumen SFX:", vol_row)
	vol_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sfx_volume_btns.clear()
	for vol: float in [0.25, 0.5, 0.75, 1.0]:
		var vbtn := Button.new()
		vbtn.text = str(int(vol * 100.0)) + "%"
		vbtn.custom_minimum_size = Vector2(48.0, 0.0)
		vbtn.pressed.connect(_on_sfx_volume_pressed.bind(vol))
		vol_row.add_child(vbtn)
		_sfx_volume_btns.append(vbtn)

	layout.add_child(HSeparator.new())

	# Show missions toggle
	var missions_row := _make_row(layout, "Mostrar misiones")
	_missions_btn = _make_wide_btn("Sí", missions_row, _on_missions_toggle_pressed)

	layout.add_child(HSeparator.new())

	var tutorial_btn := Button.new()
	tutorial_btn.text = "Reiniciar tutorial"
	tutorial_btn.pressed.connect(_on_tutorial_restart_pressed)
	layout.add_child(tutorial_btn)

	layout.add_child(HSeparator.new())

	var reset_btn := Button.new()
	reset_btn.text = "Resetear datos locales"
	reset_btn.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	reset_btn.pressed.connect(_on_reset_pressed)
	layout.add_child(reset_btn)

	layout.add_child(HSeparator.new())

	var close_btn := Button.new()
	close_btn.text = "Cerrar"
	close_btn.pressed.connect(_on_close_pressed)
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
	_confirm_reset_panel.add_theme_stylebox_override("panel", _make_style(Color(0.20, 0.07, 0.07, 0.98)))
	get_parent().add_child(_confirm_reset_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	_confirm_reset_panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)

	var msg := Label.new()
	msg.text = "Esto borrará salas, perfil, créditos, tienda, stock, misiones y tutorial. ¿Continuar?"
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 13)
	msg.add_theme_color_override("font_color", Color(1.0, 0.82, 0.82))
	layout.add_child(msg)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 12)
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_child(btn_row)

	var cancel_btn := Button.new()
	cancel_btn.text = "Cancelar"
	cancel_btn.pressed.connect(func() -> void: _confirm_reset_panel.visible = false)
	btn_row.add_child(cancel_btn)

	var confirm_btn := Button.new()
	confirm_btn.text = "Sí, resetear"
	confirm_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	confirm_btn.pressed.connect(_on_confirm_reset_pressed)
	btn_row.add_child(confirm_btn)


func update_settings(settings_data: Dictionary) -> void:
	if settings_data.is_empty():
		return
	var autosave_on: bool = bool(settings_data.get("autosave_enabled", true))
	if _autosave_toggle_btn != null:
		_autosave_toggle_btn.text = "Activado" if autosave_on else "Desactivado"

	var interval: float = float(settings_data.get("autosave_interval", 60.0))
	var active_style := _make_active_style()
	var intervals: Array[float] = [30.0, 60.0, 120.0]
	for i in range(_interval_btns.size()):
		if i < intervals.size() and is_equal_approx(intervals[i], interval):
			_interval_btns[i].add_theme_stylebox_override("normal", active_style)
		else:
			_interval_btns[i].remove_theme_stylebox_override("normal")

	var show_m: bool = bool(settings_data.get("show_missions", true))
	if _missions_btn != null:
		_missions_btn.text = "Sí" if show_m else "No"

	var sfx_on: bool = bool(settings_data.get("sfx_enabled", true))
	if _sfx_toggle_btn != null:
		_sfx_toggle_btn.text = "Activado" if sfx_on else "Desactivado"

	var sfx_volume: float = float(settings_data.get("sfx_volume", 0.7))
	var volumes: Array[float] = [0.25, 0.5, 0.75, 1.0]
	for i in range(_sfx_volume_btns.size()):
		if i < volumes.size() and is_equal_approx(volumes[i], sfx_volume):
			_sfx_volume_btns[i].add_theme_stylebox_override("normal", active_style)
		else:
			_sfx_volume_btns[i].remove_theme_stylebox_override("normal")


func _on_autosave_toggle_pressed() -> void:
	var new_val: bool = _autosave_toggle_btn != null and _autosave_toggle_btn.text == "Desactivado"
	autosave_enabled_changed.emit(new_val)


func _on_interval_pressed(seconds: float) -> void:
	autosave_interval_changed.emit(seconds)


func _on_missions_toggle_pressed() -> void:
	var new_val: bool = _missions_btn != null and _missions_btn.text == "No"
	show_missions_changed.emit(new_val)


func _on_sfx_toggle_pressed() -> void:
	var new_val: bool = _sfx_toggle_btn != null and _sfx_toggle_btn.text == "Desactivado"
	sfx_enabled_changed.emit(new_val)


func _on_sfx_volume_pressed(value: float) -> void:
	sfx_volume_changed.emit(value)


func _on_tutorial_restart_pressed() -> void:
	tutorial_restart_requested.emit()


func _on_reset_pressed() -> void:
	if _confirm_reset_panel != null:
		_confirm_reset_panel.visible = true
		_confirm_reset_panel.move_to_front()


func _on_confirm_reset_pressed() -> void:
	if _confirm_reset_panel != null:
		_confirm_reset_panel.visible = false
	reset_data_requested.emit()


func _on_close_pressed() -> void:
	if _confirm_reset_panel != null:
		_confirm_reset_panel.visible = false
	visible = false
	panel_closed.emit()


func _make_row(parent: VBoxContainer, label_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var lbl := Label.new()
	lbl.text = label_text
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_color_override("font_color", _TEXT_MAIN)
	row.add_child(lbl)
	return row


func _make_wide_btn(text: String, parent: HBoxContainer, cb: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(96.0, 0.0)
	btn.pressed.connect(cb)
	parent.add_child(btn)
	return btn


func _make_small_label(text: String, parent: HBoxContainer) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_color_override("font_color", _TEXT_DIM)
	lbl.add_theme_font_size_override("font_size", 12)
	parent.add_child(lbl)
	return lbl


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


func _make_active_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = _ACTIVE_BG
	s.corner_radius_top_left = 4
	s.corner_radius_top_right = 4
	s.corner_radius_bottom_right = 4
	s.corner_radius_bottom_left = 4
	return s
