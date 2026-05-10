extends PanelContainer
## Panel de perfil del jugador: nombre, colores, peinado, preview de avatar.
## Migrado desde GameUI.gd (_build_profile_panel + helpers + update_profile_ui).
## Se comunica hacia el exterior solo mediante señales.

signal save_requested(profile_data: Dictionary)
signal panel_closed()

var _name_edit: LineEdit
var _preview_root: Control

var _shirt_color: Color = Color(0.14, 0.32, 0.72)
var _pants_color: Color = Color(0.14, 0.16, 0.30)
var _hair_color: Color = Color(0.18, 0.10, 0.06)
var _skin_tone: Color = Color(0.84, 0.62, 0.44)
var _hair_style: String = "short"

var _shirt_btns: Array[Button] = []
var _pants_btns: Array[Button] = []
var _hair_color_btns: Array[Button] = []
var _skin_btns: Array[Button] = []
var _style_btns: Array[Button] = []


func _ready() -> void:
	name = "ProfilePanel"
	anchor_left = 0.5; anchor_top = 0.5
	anchor_right = 0.5; anchor_bottom = 0.5
	offset_left = -242.0; offset_top = -218.0
	offset_right = 242.0; offset_bottom = 218.0
	visible = false
	add_theme_stylebox_override("panel", _make_panel_style(Color(0.12, 0.15, 0.22, 0.96)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var outer := HBoxContainer.new()
	outer.add_theme_constant_override("separation", 14)
	margin.add_child(outer)

	# ── Columna izquierda: formulario ──
	var form := VBoxContainer.new()
	form.add_theme_constant_override("separation", 7)
	form.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_child(form)

	var title := Label.new()
	title.text = "Perfil de jugador"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	form.add_child(title)

	var name_lbl := Label.new()
	name_lbl.text = "Nombre:"
	name_lbl.add_theme_font_size_override("font_size", 12)
	form.add_child(name_lbl)

	_name_edit = LineEdit.new()
	_name_edit.max_length = 16
	form.add_child(_name_edit)

	_build_color_row(form, "Camiseta:", [
		["Azul", Color(0.14, 0.32, 0.72)], ["Verde", Color(0.20, 0.55, 0.25)],
		["Rojo", Color(0.68, 0.14, 0.14)], ["Amarillo", Color(0.80, 0.65, 0.12)]
	], _shirt_btns, func(i: int): _on_shirt_selected(i))

	_build_color_row(form, "Pantalón:", [
		["Osc", Color(0.14, 0.16, 0.30)], ["Negro", Color(0.10, 0.10, 0.12)],
		["Café", Color(0.36, 0.22, 0.10)]
	], _pants_btns, func(i: int): _on_pants_selected(i))

	_build_color_row(form, "Pelo:", [
		["Café", Color(0.18, 0.10, 0.06)], ["Negro", Color(0.08, 0.06, 0.06)],
		["Rubio", Color(0.72, 0.54, 0.16)]
	], _hair_color_btns, func(i: int): _on_hair_color_selected(i))

	_build_color_row(form, "Tono de piel:", [
		["Claro", Color(0.96, 0.82, 0.68)], ["Medio", Color(0.84, 0.62, 0.44)],
		["Oscuro", Color(0.60, 0.38, 0.22)]
	], _skin_btns, func(i: int): _on_skin_selected(i))

	_build_style_row(form, "Peinado:", ["Corto", "Largo", "Sin pelo"],
		_style_btns, func(i: int): _on_style_selected(i))

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 12)
	form.add_child(footer)

	var save_btn := Button.new()
	save_btn.text = "Guardar"
	save_btn.pressed.connect(_on_save_pressed)
	footer.add_child(save_btn)

	var back_btn := Button.new()
	back_btn.text = "Volver"
	back_btn.pressed.connect(_on_back_pressed)
	footer.add_child(back_btn)

	# ── Columna derecha: preview ──
	var pv_vbox := VBoxContainer.new()
	pv_vbox.add_theme_constant_override("separation", 6)
	pv_vbox.custom_minimum_size = Vector2(118, 0)
	outer.add_child(pv_vbox)

	var pv_title := Label.new()
	pv_title.text = "Vista previa"
	pv_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv_title.add_theme_font_size_override("font_size", 12)
	pv_vbox.add_child(pv_title)

	_preview_root = Control.new()
	_preview_root.name = "ProfilePreviewRoot"
	_preview_root.custom_minimum_size = Vector2(110, 160)
	_preview_root.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_preview_root.clip_contents = true
	_preview_root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var pv_bg := ColorRect.new()
	pv_bg.color = Color(0.16, 0.20, 0.28, 0.90)
	pv_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pv_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_root.add_child(pv_bg)

	var pv_avatar := Control.new()
	pv_avatar.name = "AvatarPreview"
	pv_avatar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pv_avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_root.add_child(pv_avatar)
	pv_vbox.add_child(_preview_root)

	_rebuild_preview()


# --- API pública ---

func update_profile(profile_data: Dictionary) -> void:
	if _name_edit != null:
		_name_edit.text = str(profile_data.get("player_name", "Invitado"))
	_shirt_color = profile_data.get("shirt_color", Color(0.14, 0.32, 0.72))
	_pants_color = profile_data.get("pants_color", Color(0.14, 0.16, 0.30))
	_hair_color  = profile_data.get("hair_color",  Color(0.18, 0.10, 0.06))
	_skin_tone   = profile_data.get("skin_tone",   Color(0.84, 0.62, 0.44))
	_hair_style  = str(profile_data.get("hair_style", "short"))
	_sync_button_states()
	_rebuild_preview()


# --- Construcción de filas de colores ---

func _build_color_row(parent: VBoxContainer, lbl: String, options: Array, btns: Array[Button], cb: Callable) -> void:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	parent.add_child(row)

	var label := Label.new()
	label.text = lbl
	label.add_theme_font_size_override("font_size", 11)
	row.add_child(label)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	row.add_child(hbox)

	for i in options.size():
		var opt: Array = options[i] as Array
		var color: Color = opt[1] as Color
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(46, 24)
		btn.text = str(opt[0])
		btn.add_theme_font_size_override("font_size", 10)
		var st := StyleBoxFlat.new()
		st.bg_color = color
		st.corner_radius_top_left = 3; st.corner_radius_top_right = 3
		st.corner_radius_bottom_left = 3; st.corner_radius_bottom_right = 3
		btn.add_theme_stylebox_override("normal", st)
		var sth := st.duplicate() as StyleBoxFlat
		sth.bg_color = color.lightened(0.18)
		btn.add_theme_stylebox_override("hover", sth)
		var stp := st.duplicate() as StyleBoxFlat
		stp.bg_color = color.darkened(0.12)
		btn.add_theme_stylebox_override("pressed", stp)
		var lum := color.r * 0.299 + color.g * 0.587 + color.b * 0.114
		var tc := Color.WHITE if lum < 0.5 else Color(0.08, 0.08, 0.08)
		btn.add_theme_color_override("font_color", tc)
		btn.add_theme_color_override("font_hover_color", tc)
		btn.add_theme_color_override("font_pressed_color", tc)
		btn.pressed.connect(func(): cb.call(i))
		hbox.add_child(btn)
		btns.append(btn)


func _build_style_row(parent: VBoxContainer, lbl: String, opts: Array[String], btns: Array[Button], cb: Callable) -> void:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	parent.add_child(row)

	var label := Label.new()
	label.text = lbl
	label.add_theme_font_size_override("font_size", 11)
	row.add_child(label)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	row.add_child(hbox)

	for i in opts.size():
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(56, 24)
		btn.text = opts[i]
		btn.add_theme_font_size_override("font_size", 10)
		btn.pressed.connect(func(): cb.call(i))
		hbox.add_child(btn)
		btns.append(btn)


# --- Handlers internos ---

func _on_shirt_selected(idx: int) -> void:
	var colors: Array = [Color(0.14, 0.32, 0.72), Color(0.20, 0.55, 0.25), Color(0.68, 0.14, 0.14), Color(0.80, 0.65, 0.12)]
	_shirt_color = colors[idx]
	_set_selected(_shirt_btns, idx)
	_rebuild_preview()

func _on_pants_selected(idx: int) -> void:
	var colors: Array = [Color(0.14, 0.16, 0.30), Color(0.10, 0.10, 0.12), Color(0.36, 0.22, 0.10)]
	_pants_color = colors[idx]
	_set_selected(_pants_btns, idx)
	_rebuild_preview()

func _on_hair_color_selected(idx: int) -> void:
	var colors: Array = [Color(0.18, 0.10, 0.06), Color(0.08, 0.06, 0.06), Color(0.72, 0.54, 0.16)]
	_hair_color = colors[idx]
	_set_selected(_hair_color_btns, idx)
	_rebuild_preview()

func _on_skin_selected(idx: int) -> void:
	var colors: Array = [Color(0.96, 0.82, 0.68), Color(0.84, 0.62, 0.44), Color(0.60, 0.38, 0.22)]
	_skin_tone = colors[idx]
	_set_selected(_skin_btns, idx)
	_rebuild_preview()

func _on_style_selected(idx: int) -> void:
	var styles: Array[String] = ["short", "long", "bald"]
	_hair_style = styles[idx]
	_set_selected(_style_btns, idx)
	_rebuild_preview()

func _on_save_pressed() -> void:
	save_requested.emit({
		"player_name": _name_edit.text if _name_edit else "",
		"shirt_color": _shirt_color,
		"pants_color": _pants_color,
		"hair_color":  _hair_color,
		"skin_tone":   _skin_tone,
		"hair_style":  _hair_style
	})

func _on_back_pressed() -> void:
	visible = false
	panel_closed.emit()


# --- Utilidades de botones ---

func _set_selected(btns: Array[Button], active: int) -> void:
	for i in btns.size():
		btns[i].modulate = Color.WHITE if i == active else Color(0.52, 0.52, 0.52, 0.80)

func _sync_button_states() -> void:
	var sc_opts: Array = [Color(0.14, 0.32, 0.72), Color(0.20, 0.55, 0.25), Color(0.68, 0.14, 0.14), Color(0.80, 0.65, 0.12)]
	var pc_opts: Array = [Color(0.14, 0.16, 0.30), Color(0.10, 0.10, 0.12), Color(0.36, 0.22, 0.10)]
	var hc_opts: Array = [Color(0.18, 0.10, 0.06), Color(0.08, 0.06, 0.06), Color(0.72, 0.54, 0.16)]
	var st_opts: Array = [Color(0.96, 0.82, 0.68), Color(0.84, 0.62, 0.44), Color(0.60, 0.38, 0.22)]
	var hs_opts: Array[String] = ["short", "long", "bald"]
	_set_selected(_shirt_btns,      _nearest_color(_shirt_color, sc_opts))
	_set_selected(_pants_btns,      _nearest_color(_pants_color, pc_opts))
	_set_selected(_hair_color_btns, _nearest_color(_hair_color,  hc_opts))
	_set_selected(_skin_btns,       _nearest_color(_skin_tone,   st_opts))
	_set_selected(_style_btns,      maxi(hs_opts.find(_hair_style), 0))

func _nearest_color(target: Color, opts: Array) -> int:
	var best := 0
	var best_d := 1e9
	for i in opts.size():
		var o: Color = opts[i] as Color
		var d := (target.r - o.r) ** 2 + (target.g - o.g) ** 2 + (target.b - o.b) ** 2
		if d < best_d:
			best_d = d; best = i
	return best


# --- Preview de avatar ---

func _rebuild_preview() -> void:
	if _preview_root == null:
		return
	var av: Node = _preview_root.find_child("AvatarPreview", false, false)
	if av == null:
		return
	for child in av.get_children():
		av.remove_child(child)
		child.queue_free()
	_draw_avatar(av as Control, _shirt_color, _pants_color, _hair_color, _skin_tone, _hair_style)

func _draw_avatar(root: Control, sc: Color, pc: Color, hc: Color, st: Color, hs: String) -> void:
	var cx := 55; var gy := 140
	_r(root, cx - 22, gy - 8,  44, 7,  Color(0.04, 0.04, 0.06, 0.35))         # sombra
	_r(root, cx - 18, gy - 15, 11, 7,  Color(0.16, 0.09, 0.05))                # bota izq
	_r(root, cx + 8,  gy - 15, 11, 7,  Color(0.16, 0.09, 0.05))                # bota der
	_r(root, cx - 16, gy - 31, 11, 17, pc)                                      # pierna izq
	_r(root, cx + 6,  gy - 31, 11, 17, pc)                                      # pierna der
	_r(root, cx - 24, gy - 52, 9,  17, sc.darkened(0.20))                       # brazo izq
	_r(root, cx + 16, gy - 52, 9,  17, sc.darkened(0.20))                       # brazo der
	_r(root, cx - 14, gy - 55, 28, 23, sc)                                      # cuerpo
	_r(root, cx - 8,  gy - 49, 16, 4,  sc.lightened(0.35))                     # highlight
	_r(root, cx - 5,  gy - 53, 10, 4,  Color(0.88, 0.86, 0.82))               # cuello
	_r(root, cx - 14, gy - 81, 28, 26, st)                                      # cabeza
	_r(root, cx - 9,  gy - 81, 18, 4,  Color(min(st.r+0.10,1.0), min(st.g+0.12,1.0), min(st.b+0.12,1.0), 0.50))
	_r(root, cx - 12, gy - 67, 5,  3,  Color(0.90, 0.50, 0.42, 0.55))         # mejilla izq
	_r(root, cx + 8,  gy - 67, 5,  3,  Color(0.90, 0.50, 0.42, 0.55))         # mejilla der
	_r(root, cx - 9,  gy - 73, 5,  5,  Color(0.08, 0.06, 0.08))               # ojo izq
	_r(root, cx + 5,  gy - 73, 5,  5,  Color(0.08, 0.06, 0.08))               # ojo der
	_r(root, cx - 8,  gy - 74, 2,  2,  Color.WHITE)                            # brillo ojo izq
	_r(root, cx + 6,  gy - 74, 2,  2,  Color.WHITE)                            # brillo ojo der
	_r(root, cx - 4,  gy - 63, 8,  3,  Color(0.58, 0.26, 0.18))               # boca
	match hs:
		"short":
			_r(root, cx - 15, gy - 90, 30, 10, hc)
			_r(root, cx - 15, gy - 82, 7,  9,  hc)
			_r(root, cx + 7,  gy - 83, 7,  6,  hc)
		"long":
			_r(root, cx - 15, gy - 90, 30, 10, hc)
			_r(root, cx - 15, gy - 83, 7,  20, hc)
			_r(root, cx + 9,  gy - 83, 7,  20, hc)
			_r(root, cx + 7,  gy - 83, 7,  6,  hc)
		"bald":
			pass

func _r(parent: Control, x: int, y: int, w: int, h: int, color: Color) -> void:
	var rect := ColorRect.new()
	rect.position = Vector2(x, y)
	rect.size = Vector2(w, h)
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)


func _make_panel_style(bg_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 10; style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10; style.corner_radius_bottom_left = 10
	style.border_color = Color(1.0, 1.0, 1.0, 0.10)
	return style
