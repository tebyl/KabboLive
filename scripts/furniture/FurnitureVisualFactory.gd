extends RefCounted


var blocks_node: Node2D
var iso_grid

const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const FurnitureData = FurnitureDataScript


func _init(p_blocks_node: Node2D, p_iso_grid) :
	blocks_node = p_blocks_node
	iso_grid = p_iso_grid


func redraw(items, selected_index) :
	clear_blocks()

	for furniture in items:
		draw_furniture(furniture)

	draw_selected_furniture_marker(items, selected_index)


func draw_furniture(furniture) -> void:
	var height: float = get_furniture_height(furniture.type)
	var base_color: Color = get_furniture_color(furniture.type)
	var lz: int = _get_layer_z_offset(furniture)

	for cell in furniture.get_occupied_cells():
		if not iso_grid.is_valid_cell(cell):
			continue
		draw_furniture_block_cell(cell, height, base_color, lz)

	match furniture.type:
		&"chair":  draw_chair_details(furniture, lz)
		&"table":  draw_table_details(furniture, lz)
		&"sofa":   draw_sofa_details(furniture, lz)
		&"plant":  draw_plant_details(furniture, lz)
		&"rug":    draw_rug_details(furniture, lz)


func _get_layer_z_offset(furniture) -> int:
	var l: Variant = furniture.get("layer")
	if l != null and str(l) == "floor":
		return -8
	if str(furniture.get("type")) == "rug":
		return -8
	return 0


func clear_blocks() :
	for child: Node in blocks_node.get_children():
		blocks_node.remove_child(child)
		child.queue_free()


func draw_furniture_block_cell(cell, height: float, base_color: Color, lz: int = 0) -> void:
	var cp: Vector2 = iso_grid.grid_to_iso(cell)
	var dz: int = iso_grid.get_draw_z_index(cell) + lz
	var tw: float = float(iso_grid.tile_width)
	var th: float = float(iso_grid.tile_height)

	var shadow: Polygon2D = Polygon2D.new()
	shadow.polygon = iso_grid.get_iso_diamond_polygon()
	shadow.position = cp + Vector2(2, 5)
	shadow.color = Color(0.04, 0.05, 0.04, 0.30)
	shadow.z_index = dz - 1
	blocks_node.add_child(shadow)

	var left_face: Polygon2D = Polygon2D.new()
	left_face.polygon = PackedVector2Array([
		Vector2(-tw / 2.0, 0), Vector2(0, th / 2.0),
		Vector2(0, th / 2.0 + height), Vector2(-tw / 2.0, height)
	])
	left_face.position = cp + Vector2(0, -height)
	left_face.color = base_color.darkened(0.38)
	left_face.z_index = dz + 1
	blocks_node.add_child(left_face)

	var right_face: Polygon2D = Polygon2D.new()
	right_face.polygon = PackedVector2Array([
		Vector2(tw / 2.0, 0), Vector2(0, th / 2.0),
		Vector2(0, th / 2.0 + height), Vector2(tw / 2.0, height)
	])
	right_face.position = cp + Vector2(0, -height)
	right_face.color = base_color.darkened(0.18)
	right_face.z_index = dz + 1
	blocks_node.add_child(right_face)

	var top: Polygon2D = Polygon2D.new()
	top.polygon = iso_grid.get_iso_diamond_polygon()
	top.position = cp + Vector2(0, -height)
	top.color = base_color.lightened(0.26)
	top.z_index = dz + 2
	blocks_node.add_child(top)


func draw_chair_details(furniture, lz: int = 0) -> void:
	var cell = furniture.cell
	var h: float = get_furniture_height(furniture.type)
	var c: Vector2 = iso_grid.grid_to_iso(cell)
	var z: int = iso_grid.get_draw_z_index(cell) + lz
	_add_small_diamond(c, -h - 1.0, 0.60, Color(0.90, 0.62, 0.36), z + 3)
	_add_small_diamond(c, -h - 3.0, 0.36, Color(0.96, 0.76, 0.52), z + 4)
	add_rect_polygon(c + Vector2(0, -h - 20.0), Vector2(24, 22), Color(0.38, 0.17, 0.07), z + 2)
	add_rect_polygon(c + Vector2(0, -h - 33.0), Vector2(26, 7), Color(0.52, 0.26, 0.12), z + 2)


func draw_table_details(furniture, lz: int = 0) -> void:
	var h: float = get_furniture_height(furniture.type)
	var cells: Array = furniture.get_occupied_cells()
	for cell in cells:
		if not iso_grid.is_valid_cell(cell):
			continue
		var c: Vector2 = iso_grid.grid_to_iso(cell)
		var z: int = iso_grid.get_draw_z_index(cell) + lz
		_add_small_diamond(c, -h - 1.0, 0.86, Color(0.92, 0.84, 0.68), z + 3)
		_add_small_diamond(c, -h - 3.0, 0.44, Color(0.78, 0.54, 0.28), z + 4)
		add_rect_polygon(c + Vector2(-18, -h * 0.5 + 4.0), Vector2(5, h), Color(0.42, 0.22, 0.10), z + 1)
		add_rect_polygon(c + Vector2(18, -h * 0.5 + 4.0), Vector2(5, h), Color(0.50, 0.28, 0.13), z + 1)


func draw_sofa_details(furniture, lz: int = 0) -> void:
	var h: float = get_furniture_height(furniture.type)
	var cells: Array = furniture.get_occupied_cells()
	var total: int = cells.size()
	for i: int in range(total):
		var cell = cells[i]
		if not iso_grid.is_valid_cell(cell):
			continue
		var c: Vector2 = iso_grid.grid_to_iso(cell)
		var z: int = iso_grid.get_draw_z_index(cell) + lz
		_add_small_diamond(c, -h - 1.0, 0.72, Color(0.30, 0.58, 0.46), z + 3)
		_add_small_diamond(c, -h - 4.0, 0.30, Color(0.42, 0.74, 0.60), z + 4)
		add_rect_polygon(c + Vector2(0, -h - 18.0), Vector2(44, 20), Color(0.18, 0.38, 0.28), z + 2)
		add_rect_polygon(c + Vector2(0, -h - 29.0), Vector2(46, 6), Color(0.26, 0.50, 0.38), z + 2)
		if i == 0:
			add_rect_polygon(c + Vector2(-22, -h - 10.0), Vector2(8, 22), Color(0.20, 0.42, 0.32), z + 4)
		if i == total - 1:
			add_rect_polygon(c + Vector2(22, -h - 10.0), Vector2(8, 22), Color(0.20, 0.42, 0.32), z + 4)


func draw_plant_details(furniture, lz: int = 0) -> void:
	var c: Vector2 = iso_grid.grid_to_iso(furniture.cell)
	var z: int = iso_grid.get_draw_z_index(furniture.cell) + lz
	add_rect_polygon(c + Vector2(0, -20), Vector2(20, 16), Color(0.60, 0.30, 0.14), z + 4)
	add_rect_polygon(c + Vector2(0, -14), Vector2(24, 6), Color(0.70, 0.36, 0.18), z + 5)
	add_rect_polygon(c + Vector2(-9, -38), Vector2(18, 22), Color(0.14, 0.52, 0.22), z + 5)
	add_rect_polygon(c + Vector2(9, -40), Vector2(18, 20), Color(0.20, 0.68, 0.30), z + 5)
	add_rect_polygon(c + Vector2(0, -46), Vector2(12, 14), Color(0.26, 0.76, 0.36), z + 6)


func draw_selected_furniture_marker(items, selected_index) -> void:
	if selected_index < 0 or selected_index >= items.size():
		return

	var furniture = items[selected_index]
	var h: float = get_furniture_height(furniture.type)
	var lz: int = _get_layer_z_offset(furniture)

	for cell in furniture.get_occupied_cells():
		if not iso_grid.is_valid_cell(cell):
			continue

		var cp: Vector2 = iso_grid.grid_to_iso(cell)
		var dz: int = iso_grid.get_draw_z_index(cell) + lz

		_add_small_diamond(cp, 0.0, 1.02, Color(1.0, 0.92, 0.20, 0.28), dz - 2)
		_add_small_diamond(cp, 0.0, 0.88, Color(1.0, 0.92, 0.20, 0.18), dz - 2)

		var outline: Line2D = Line2D.new()
		var pts: PackedVector2Array = iso_grid.get_iso_diamond_polygon()
		pts.append(pts[0])
		outline.points = pts
		outline.position = cp + Vector2(0, -h - 1.0)
		outline.width = 2.2
		outline.default_color = Color(1.0, 0.95, 0.25, 0.90)
		outline.z_index = dz + 6
		blocks_node.add_child(outline)


func draw_rug_details(furniture, lz: int = 0) -> void:
	var h: float = get_furniture_height(furniture.type)
	var cx: int = furniture.cell.x
	var cy: int = furniture.cell.y
	var c00: Vector2 = iso_grid.grid_to_iso(Vector2i(cx, cy))
	var c10: Vector2 = iso_grid.grid_to_iso(Vector2i(cx + 1, cy))
	var c01: Vector2 = iso_grid.grid_to_iso(Vector2i(cx, cy + 1))
	var c11: Vector2 = iso_grid.grid_to_iso(Vector2i(cx + 1, cy + 1))
	var center: Vector2 = (c00 + c10 + c01 + c11) * 0.25
	var z: int = iso_grid.get_draw_z_index(Vector2i(cx + 1, cy + 1)) + lz + 3

	var outer: Line2D = Line2D.new()
	outer.points = PackedVector2Array([
		Vector2(0, -32), Vector2(64, 0), Vector2(0, 32), Vector2(-64, 0), Vector2(0, -32)
	])
	outer.position = center + Vector2(0, -h - 1)
	outer.width = 2.5
	outer.default_color = Color(0.92, 0.76, 0.34, 0.92)
	outer.z_index = z
	blocks_node.add_child(outer)

	var inner: Line2D = Line2D.new()
	inner.points = PackedVector2Array([
		Vector2(0, -22), Vector2(44, 0), Vector2(0, 22), Vector2(-44, 0), Vector2(0, -22)
	])
	inner.position = center + Vector2(0, -h - 1)
	inner.width = 1.5
	inner.default_color = Color(0.92, 0.76, 0.34, 0.58)
	inner.z_index = z
	blocks_node.add_child(inner)

	_add_small_diamond(center, -h - 2, 0.22, Color(0.96, 0.84, 0.44), z + 1)


func get_furniture_color(furniture_type) -> Color:
	match furniture_type:
		&"chair": return Color(0.58, 0.30, 0.13)
		&"table": return Color(0.62, 0.44, 0.20)
		&"sofa":  return Color(0.20, 0.42, 0.32)
		&"plant": return Color(0.22, 0.58, 0.26)
		&"rug":   return Color(0.66, 0.20, 0.20)
		_:        return Color(0.60, 0.60, 0.60)


func get_furniture_height(furniture_type) -> float:
	match furniture_type:
		&"chair": return 16.0
		&"table": return 14.0
		&"sofa":  return 18.0
		&"plant": return 24.0
		&"rug":   return 4.0
		_:        return 14.0


func _add_small_diamond(center: Vector2, y_offset: float, scale: float, color: Color, z: int) -> void:
	var hw: float = float(iso_grid.tile_width) * 0.5 * scale
	var hh: float = float(iso_grid.tile_height) * 0.5 * scale
	var poly: Polygon2D = Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(0, -hh), Vector2(hw, 0), Vector2(0, hh), Vector2(-hw, 0)
	])
	poly.position = center + Vector2(0, y_offset)
	poly.color = color
	poly.z_index = z
	blocks_node.add_child(poly)


func add_rect_polygon(center, size, color: Color, z_index) :
	var half_size = size / 2.0
	var rect: Polygon2D = Polygon2D.new()
	rect.polygon = PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(half_size.x, half_size.y),
		Vector2(-half_size.x, half_size.y)
	])
	rect.position = center
	rect.color = color
	rect.z_index = z_index
	blocks_node.add_child(rect)
