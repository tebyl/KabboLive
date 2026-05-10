extends PanelContainer
## Panel de tienda independiente.
## Migrado desde GameUI.gd (_build_shop_panel / show_shop_panel / update_shop_items).
## Comunica acciones hacia el exterior exclusivamente vía señales — sin Callables manuales.

signal buy_requested(item_id: String)
signal panel_closed()

var _credits_label: Label
var _items_vbox: VBoxContainer

func _ready() -> void:
	name = "ShopPanel"
	anchor_left = 0.5
	anchor_top = 0.5
	anchor_right = 0.5
	anchor_bottom = 0.5
	offset_left = -260.0
	offset_top = -190.0
	offset_right = 260.0
	offset_bottom = 190.0
	visible = false
	add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.17, 0.97)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	margin.add_child(layout)

	var title := Label.new()
	title.text = "Tienda"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.72))
	layout.add_child(title)

	_credits_label = Label.new()
	_credits_label.text = "Créditos: 0"
	_credits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_credits_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.48))
	layout.add_child(_credits_label)

	_items_vbox = VBoxContainer.new()
	_items_vbox.add_theme_constant_override("separation", 6)
	layout.add_child(_items_vbox)

	var close_btn := Button.new()
	close_btn.text = "Cerrar"
	close_btn.pressed.connect(_on_close_pressed)
	layout.add_child(close_btn)


func show_with_data(items: Array[Dictionary], credits: int, stock_data: Dictionary = {}) -> void:
	update_items(items, credits, stock_data)
	visible = true
	move_to_front()


func update_items(items: Array[Dictionary], credits: int, stock_data: Dictionary = {}) -> void:
	if _credits_label != null:
		_credits_label.text = "Créditos: " + str(credits)
	if _items_vbox == null:
		return
	for child: Node in _items_vbox.get_children():
		_items_vbox.remove_child(child)
		child.queue_free()
	for item: Dictionary in items:
		var item_id: String = str(item.get("id", ""))
		var display_name: String = str(item.get("display_name", item_id))
		var price: int = int(item.get("price", 0))
		var item_type: String = str(item.get("type", item_id))
		var stock: int = int(stock_data.get(item_type, 0))

		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 2)
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_items_vbox.add_child(col)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		col.add_child(row)

		var label := Label.new()
		label.text = display_name + " — " + str(price) + " créditos"
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", Color(0.90, 0.94, 1.0))
		row.add_child(label)

		var buy_btn := Button.new()
		buy_btn.text = "Comprar"
		buy_btn.pressed.connect(_on_buy_pressed.bind(item_id))
		row.add_child(buy_btn)

		var stock_label := Label.new()
		stock_label.text = "En inventario: " + str(stock)
		stock_label.add_theme_font_size_override("font_size", 11)
		stock_label.add_theme_color_override(
			"font_color",
			Color(0.65, 0.80, 0.65) if stock > 0 else Color(0.60, 0.60, 0.60)
		)
		col.add_child(stock_label)


func _on_buy_pressed(item_id: String) -> void:
	buy_requested.emit(item_id)


func _on_close_pressed() -> void:
	visible = false
	panel_closed.emit()


func _make_panel_style(bg_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.border_color = Color(1.0, 1.0, 1.0, 0.10)
	return style
