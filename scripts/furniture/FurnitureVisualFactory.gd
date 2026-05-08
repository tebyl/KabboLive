extends RefCounted


var blocks_node: Node2D
var iso_grid

const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const FurnitureData = FurnitureDataScript
const VT = preload("res://scripts/visual/VisualTheme.gd")


func _init(p_blocks_node: Node2D, p_iso_grid) :
	blocks_node = p_blocks_node
	iso_grid = p_iso_grid


func redraw(items, selected_index) :
	clear_blocks()

	for furniture in items:
		draw_furniture(furniture)

	draw_selected_furniture_marker(items, selected_index)


func play_place_pop(furniture: RefCounted) -> void:
	if blocks_node == null or iso_grid == null or furniture == null:
		return
	var valid_cells: Array[Vector2i] = []
	for cell: Vector2i in furniture.get_occupied_cells():
		if iso_grid.is_valid_cell(cell):
			valid_cells.append(cell)
	if valid_cells.is_empty():
		return

	var center: Vector2 = Vector2.ZERO
	var max_z: int = -999999
	for cell: Vector2i in valid_cells:
		center += iso_grid.grid_to_iso(cell)
		max_z = maxi(max_z, iso_grid.get_draw_z_index(cell))
	center /= float(valid_cells.size())

	var root: Node2D = Node2D.new()
	root.name = "PlacePop"
	root.position = center
	root.scale = Vector2(0.85, 0.85)
	root.z_index = max_z + 12
	root.z_as_relative = false
	blocks_node.add_child(root)

	for cell: Vector2i in valid_cells:
		var flash: Polygon2D = Polygon2D.new()
		flash.polygon = iso_grid.get_iso_diamond_polygon()
		flash.position = iso_grid.grid_to_iso(cell) - center + Vector2(0.0, -get_furniture_height(furniture.type))
		flash.color = Color(1.0, 0.96, 0.55, 0.34)
		flash.z_index = 0
		root.add_child(flash)

	var tween: Tween = root.create_tween()
	tween.tween_property(root, "scale", Vector2(1.05, 1.05), 0.10)
	tween.parallel().tween_property(root, "modulate:a", 0.72, 0.10)
	tween.tween_property(root, "scale", Vector2.ONE, 0.08)
	tween.parallel().tween_property(root, "modulate:a", 0.0, 0.14)
	tween.tween_callback(Callable(root, "queue_free"))


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
	shadow.color = VT.SHADOW_SOFT
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

	# Seat cushion
	_add_small_diamond(c, -h - 1.0, 0.62, VT.CHAIR_CUSHION, z + 3)
	_add_small_diamond(c, -h - 3.0, 0.36, VT.CHAIR_CUSHION_HI, z + 4)
	# Seat front edge (wood rim under cushion)
	add_rect_polygon(c + Vector2(0, -h + 1.0), Vector2(28, 5), VT.CHAIR_DARK, z + 2)
	# Backrest panel
	add_rect_polygon(c + Vector2(0, -h - 22.0), Vector2(22, 20), VT.CHAIR_BODY, z + 2)
	# Backrest top rail
	add_rect_polygon(c + Vector2(0, -h - 33.0), Vector2(24, 6), VT.WOOD_MID, z + 2)
	# Backrest horizontal slat (mid)
	add_rect_polygon(c + Vector2(0, -h - 24.0), Vector2(18, 3), VT.CHAIR_SLAT, z + 3)
	# Backrest horizontal slat (lower)
	add_rect_polygon(c + Vector2(0, -h - 18.0), Vector2(18, 3), VT.CHAIR_SLAT, z + 3)


func draw_table_details(furniture, lz: int = 0) -> void:
	var h: float = get_furniture_height(furniture.type)
	var cells: Array = furniture.get_occupied_cells()
	for cell in cells:
		if not iso_grid.is_valid_cell(cell):
			continue
		var c: Vector2 = iso_grid.grid_to_iso(cell)
		var z: int = iso_grid.get_draw_z_index(cell) + lz

		# Tablecloth surface
		_add_small_diamond(c, -h - 1.0, 0.90, VT.TABLE_TOP, z + 3)
		# Tablecloth center runner
		_add_small_diamond(c, -h - 2.5, 0.42, VT.TABLE_RUNNER, z + 4)
		# Table apron (front skirt under surface)
		add_rect_polygon(c + Vector2(0, -h * 0.5 + 2.0), Vector2(30, 5), VT.TABLE_APRON, z + 2)
		# Legs
		add_rect_polygon(c + Vector2(-16, -h * 0.5 + 5.0), Vector2(4, h - 2), VT.TABLE_DARK, z + 1)
		add_rect_polygon(c + Vector2(16, -h * 0.5 + 5.0), Vector2(4, h - 2), VT.WOOD_MID, z + 1)


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

		# Seat cushion base
		_add_small_diamond(c, -h - 1.0, 0.74, VT.SOFA_CUSHION, z + 3)
		# Cushion puff highlight
		_add_small_diamond(c, -h - 5.0, 0.40, VT.SOFA_LIGHT, z + 4)
		# Cushion seam crease
		add_rect_polygon(c + Vector2(0, -h - 2.0), Vector2(26, 2), Color(VT.SOFA_SEAM.r, VT.SOFA_SEAM.g, VT.SOFA_SEAM.b, 0.70), z + 5)
		# Backrest body
		add_rect_polygon(c + Vector2(0, -h - 19.0), Vector2(42, 18), VT.SOFA_DARK, z + 2)
		# Backrest top lip
		add_rect_polygon(c + Vector2(0, -h - 29.0), Vector2(44, 7), VT.SOFA_BODY, z + 2)
		# Backrest highlight stripe
		add_rect_polygon(c + Vector2(0, -h - 24.0), Vector2(36, 3), Color(VT.SOFA_LIGHT.r, VT.SOFA_LIGHT.g, VT.SOFA_LIGHT.b, 0.70), z + 3)
		# Armrests
		if i == 0:
			add_rect_polygon(c + Vector2(-22, -h - 12.0), Vector2(8, 24), VT.SOFA_ARM, z + 4)
			add_rect_polygon(c + Vector2(-22, -h - 24.0), Vector2(10, 6), VT.SOFA_ARM_TOP, z + 5)
		if i == total - 1:
			add_rect_polygon(c + Vector2(22, -h - 12.0), Vector2(8, 24), VT.SOFA_ARM, z + 4)
			add_rect_polygon(c + Vector2(22, -h - 24.0), Vector2(10, 6), VT.SOFA_ARM_TOP, z + 5)


func draw_plant_details(furniture, lz: int = 0) -> void:
	var c: Vector2 = iso_grid.grid_to_iso(furniture.cell)
	var z: int = iso_grid.get_draw_z_index(furniture.cell) + lz

	# Pot body
	add_rect_polygon(c + Vector2(0, -20), Vector2(18, 14), VT.PLANT_POT, z + 4)
	add_rect_polygon(c + Vector2(0, -25), Vector2(22, 5), VT.PLANT_POT_DARK, z + 4)
	# Pot rim
	add_rect_polygon(c + Vector2(0, -14), Vector2(26, 6), VT.PLANT_POT_RIM, z + 5)
	# Pot rim highlight
	add_rect_polygon(c + Vector2(0, -13), Vector2(20, 3), Color(VT.PLANT_POT_HI.r, VT.PLANT_POT_HI.g, VT.PLANT_POT_HI.b, 0.60), z + 6)
	# Soil surface
	_add_small_diamond(c, -27.0, 0.28, VT.PLANT_SOIL, z + 6)
	# Stem
	add_rect_polygon(c + Vector2(0, -36), Vector2(4, 14), VT.PLANT_STEM, z + 5)
	# Leaf cluster — back-left
	_add_small_diamond(c + Vector2(-12, 0), -50.0, 0.44, VT.PLANT_LEAF_DK, z + 5)
	# Leaf cluster — back-right
	_add_small_diamond(c + Vector2(12, 0), -52.0, 0.40, VT.PLANT_LEAF_DK, z + 5)
	# Leaf cluster — front-left
	_add_small_diamond(c + Vector2(-8, 0), -44.0, 0.38, VT.PLANT_LEAF, z + 6)
	# Leaf cluster — front-right
	_add_small_diamond(c + Vector2(8, 0), -46.0, 0.34, VT.PLANT_LEAF, z + 6)
	# Crown top
	_add_small_diamond(c, -58.0, 0.36, VT.PLANT_LEAF_LT, z + 7)
	# Crown highlight
	_add_small_diamond(c + Vector2(-3, 0), -62.0, 0.16, Color(VT.PLANT_LEAF_HI.r, VT.PLANT_LEAF_HI.g, VT.PLANT_LEAF_HI.b, 0.70), z + 8)


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
	var yo: float = -h - 1.0

	# Filled inner area
	var fill: Polygon2D = Polygon2D.new()
	fill.polygon = PackedVector2Array([
		Vector2(0, -26), Vector2(54, 0), Vector2(0, 26), Vector2(-54, 0)
	])
	fill.position = center + Vector2(0, yo)
	fill.color = Color(VT.RUG_FILL.r, VT.RUG_FILL.g, VT.RUG_FILL.b, 0.50)
	fill.z_index = z
	blocks_node.add_child(fill)

	# Outer border
	var outer: Line2D = Line2D.new()
	outer.points = PackedVector2Array([
		Vector2(0, -30), Vector2(62, 0), Vector2(0, 30), Vector2(-62, 0), Vector2(0, -30)
	])
	outer.position = center + Vector2(0, yo)
	outer.width = 2.5
	outer.default_color = VT.RUG_BORDER
	outer.z_index = z + 1
	blocks_node.add_child(outer)

	# Inner border
	var inner: Line2D = Line2D.new()
	inner.points = PackedVector2Array([
		Vector2(0, -20), Vector2(42, 0), Vector2(0, 20), Vector2(-42, 0), Vector2(0, -20)
	])
	inner.position = center + Vector2(0, yo)
	inner.width = 1.5
	inner.default_color = VT.RUG_BORDER_DIM
	inner.z_index = z + 1
	blocks_node.add_child(inner)

	# Cross pattern lines (N-S axis)
	var line_ns: Line2D = Line2D.new()
	line_ns.points = PackedVector2Array([Vector2(0, -18), Vector2(0, 18)])
	line_ns.position = center + Vector2(0, yo)
	line_ns.width = 1.2
	line_ns.default_color = VT.RUG_CROSS
	line_ns.z_index = z + 1
	blocks_node.add_child(line_ns)

	# Cross pattern lines (E-W axis)
	var line_ew: Line2D = Line2D.new()
	line_ew.points = PackedVector2Array([Vector2(-38, 0), Vector2(38, 0)])
	line_ew.position = center + Vector2(0, yo)
	line_ew.width = 1.2
	line_ew.default_color = VT.RUG_CROSS
	line_ew.z_index = z + 1
	blocks_node.add_child(line_ew)

	# Central rosette
	_add_small_diamond(center, yo - 1.0, 0.18, VT.RUG_CENTER, z + 2)
	_add_small_diamond(center, yo - 0.5, 0.08, VT.RUG_CENTER_HI, z + 3)


func get_furniture_color(furniture_type) -> Color:
	match furniture_type:
		&"chair": return VT.CHAIR_BODY
		&"table": return VT.TABLE_BODY
		&"sofa":  return VT.SOFA_BODY
		&"plant": return VT.PLANT_LEAF_DK
		&"rug":   return VT.RUG_BODY
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
