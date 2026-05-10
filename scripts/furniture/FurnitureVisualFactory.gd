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
		&"chair":       draw_chair_details(furniture, lz)
		&"table":       draw_table_details(furniture, lz)
		&"sofa":        draw_sofa_details(furniture, lz)
		&"plant":       draw_plant_details(furniture, lz)
		&"rug":         draw_rug_details(furniture, lz)
		&"blue_rug":    draw_blue_rug_details(furniture, lz)
		&"golden_plant":draw_golden_plant_details(furniture, lz)
		&"lounge_chair":draw_lounge_chair_details(furniture, lz)
		&"bed":         draw_bed_details(furniture, lz)
		&"lamp":        draw_lamp_details(furniture, lz)
		&"bookshelf":   draw_bookshelf_details(furniture, lz)
		&"desk":        draw_desk_details(furniture, lz)
		&"poster":      draw_poster_details(furniture, lz)
		&"big_plant":   draw_big_plant_details(furniture, lz)
		&"red_rug":     draw_red_rug_details(furniture, lz)
		&"floor_tile":  draw_floor_tile_details(furniture, lz)


func _get_layer_z_offset(furniture) -> int:
	var l: Variant = furniture.get("layer")
	if l != null and str(l) == "floor":
		return -8
	if str(furniture.get("type")) == "rug" or str(furniture.get("type")) == "blue_rug":
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
	var cell: Vector2i = furniture.cell
	if not iso_grid.is_valid_cell(cell):
		return
	var c: Vector2 = iso_grid.grid_to_iso(cell)
	var z: int = iso_grid.get_draw_z_index(cell) + lz

	# Tablecloth surface - single cohesive visual
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
	var cell: Vector2i = furniture.cell
	if not iso_grid.is_valid_cell(cell):
		return
	var c: Vector2 = iso_grid.grid_to_iso(cell)
	var z: int = iso_grid.get_draw_z_index(cell) + lz

	# Seat cushion base (single cohesive sofa visual)
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
	# Left armrest
	add_rect_polygon(c + Vector2(-22, -h - 12.0), Vector2(8, 24), VT.SOFA_ARM, z + 4)
	add_rect_polygon(c + Vector2(-22, -h - 24.0), Vector2(10, 6), VT.SOFA_ARM_TOP, z + 5)
	# Right armrest
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


func draw_blue_rug_details(furniture, lz: int = 0) -> void:
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
	_add_small_diamond(center, yo, 1.85, Color(0.12, 0.34, 0.78, 0.58), z)
	_add_small_diamond(center, yo - 1.0, 1.42, Color(0.32, 0.64, 1.0, 0.34), z + 1)
	_add_small_diamond(center, yo - 2.0, 0.34, Color(0.76, 0.90, 1.0, 0.56), z + 2)


func draw_golden_plant_details(furniture, lz: int = 0) -> void:
	draw_plant_details(furniture, lz)
	var c: Vector2 = iso_grid.grid_to_iso(furniture.cell)
	var z: int = iso_grid.get_draw_z_index(furniture.cell) + lz
	add_rect_polygon(c + Vector2(0, -14), Vector2(28, 7), Color(0.95, 0.70, 0.18), z + 9)
	_add_small_diamond(c, -58.0, 0.42, Color(0.94, 0.78, 0.18, 0.74), z + 10)
	_add_small_diamond(c + Vector2(10, 0), -49.0, 0.28, Color(1.0, 0.88, 0.32, 0.70), z + 10)
	_add_small_diamond(c + Vector2(-10, 0), -47.0, 0.28, Color(0.86, 0.62, 0.10, 0.70), z + 10)


func draw_lounge_chair_details(furniture, lz: int = 0) -> void:
	var cell = furniture.cell
	var h: float = get_furniture_height(furniture.type)
	var c: Vector2 = iso_grid.grid_to_iso(cell)
	var z: int = iso_grid.get_draw_z_index(cell) + lz
	_add_small_diamond(c, -h - 1.0, 0.78, Color(0.52, 0.30, 0.70), z + 3)
	_add_small_diamond(c, -h - 5.0, 0.48, Color(0.74, 0.52, 0.92), z + 4)
	add_rect_polygon(c + Vector2(0, -h - 19.0), Vector2(34, 18), Color(0.38, 0.20, 0.56), z + 3)
	add_rect_polygon(c + Vector2(-21, -h - 8.0), Vector2(8, 22), Color(0.30, 0.16, 0.46), z + 4)
	add_rect_polygon(c + Vector2(21, -h - 8.0), Vector2(8, 22), Color(0.44, 0.24, 0.62), z + 4)


func draw_bed_details(furniture, lz: int = 0) -> void:
	var h: float = get_furniture_height(furniture.type)
	# Use the 2×2 center for the overall visual anchor
	var cx: int = furniture.cell.x
	var cy: int = furniture.cell.y
	var c00: Vector2 = iso_grid.grid_to_iso(Vector2i(cx, cy))
	var c10: Vector2 = iso_grid.grid_to_iso(Vector2i(cx + 1, cy))
	var c01: Vector2 = iso_grid.grid_to_iso(Vector2i(cx, cy + 1))
	var c11: Vector2 = iso_grid.grid_to_iso(Vector2i(cx + 1, cy + 1))
	var center: Vector2 = (c00 + c10 + c01 + c11) * 0.25
	var z_base: int = iso_grid.get_draw_z_index(Vector2i(cx + 1, cy + 1)) + lz + 2
	var yo: float = -h - 1.0
	# Mattress surface
	_add_wide_diamond(center, yo, 1.7, VT.BED_MATTRESS, z_base + 2)
	# Blanket (covers lower 60%)
	var blanket: Polygon2D = Polygon2D.new()
	blanket.polygon = PackedVector2Array([
		Vector2(0, -18), Vector2(54, 8), Vector2(54, 20), Vector2(0, 30), Vector2(-54, 20), Vector2(-54, 8)
	])
	blanket.position = center + Vector2(0, yo)
	blanket.color = VT.BED_BLANKET
	blanket.z_index = z_base + 3
	blocks_node.add_child(blanket)
	# Blanket crease highlight
	add_rect_polygon(center + Vector2(0, yo + 12), Vector2(60, 2), Color(VT.BED_BLANKET_HI.r, VT.BED_BLANKET_HI.g, VT.BED_BLANKET_HI.b, 0.65), z_base + 4)
	# Pillow
	_add_wide_diamond(center + Vector2(0, -4), yo - 6.0, 0.55, VT.BED_PILLOW, z_base + 5)
	# Headboard
	add_rect_polygon(c00 + Vector2(0, yo - 18), Vector2(44, 22), VT.BED_FRAME, z_base + 4)
	add_rect_polygon(c00 + Vector2(0, yo - 28), Vector2(46, 7), VT.BED_FRAME_DK, z_base + 4)
	# Footboard (small rail)
	add_rect_polygon(c11 + Vector2(0, yo + 4), Vector2(38, 8), VT.BED_FRAME_DK, z_base + 4)


func draw_lamp_details(furniture, lz: int = 0) -> void:
	var h: float = get_furniture_height(furniture.type)
	var c: Vector2 = iso_grid.grid_to_iso(furniture.cell)
	var z: int = iso_grid.get_draw_z_index(furniture.cell) + lz
	# Base disc
	_add_small_diamond(c, -h - 1.0, 0.36, VT.LAMP_BASE, z + 2)
	# Pole
	add_rect_polygon(c + Vector2(0, -h - 24), Vector2(4, 36), VT.LAMP_POLE, z + 3)
	# Shade (wide top trapezoid)
	var shade: Polygon2D = Polygon2D.new()
	shade.polygon = PackedVector2Array([
		Vector2(-18, 0), Vector2(18, 0), Vector2(12, 14), Vector2(-12, 14)
	])
	shade.position = c + Vector2(0, -h - 42)
	shade.color = VT.LAMP_SHADE
	shade.z_index = z + 4
	blocks_node.add_child(shade)
	# Shade highlight
	add_rect_polygon(c + Vector2(0, -h - 40), Vector2(24, 3), VT.LAMP_SHADE_HI, z + 5)
	# Glow circle on floor
	_add_small_diamond(c, -h + 1.0, 0.50, VT.LAMP_GLOW, z + 1)


func draw_bookshelf_details(furniture, lz: int = 0) -> void:
	var h: float = get_furniture_height(furniture.type)
	var cell: Vector2i = furniture.cell
	if not iso_grid.is_valid_cell(cell):
		return
	var c: Vector2 = iso_grid.grid_to_iso(cell)
	var z: int = iso_grid.get_draw_z_index(cell) + lz
	# Shelf body (wood back panel) - single visual unit
	add_rect_polygon(c + Vector2(0, -h * 0.5 - 4), Vector2(34, h), VT.SHELF_WOOD, z + 2)
	# Shelf dividers (horizontal planks)
	var shelf_y_offsets: Array[float] = [-h * 0.25, -h * 0.60]
	for sy: float in shelf_y_offsets:
		add_rect_polygon(c + Vector2(0, sy), Vector2(36, 3), VT.SHELF_WOOD_DK, z + 3)
	# Books on lower shelf
	var book_colors: Array = [VT.SHELF_BOOK_A, VT.SHELF_BOOK_B, VT.SHELF_BOOK_C, VT.SHELF_BOOK_D]
	var bx: float = -12.0
	for bi: int in range(4):
		add_rect_polygon(c + Vector2(bx, -h * 0.38), Vector2(5, 12), book_colors[bi], z + 4)
		bx += 7.0
	# Books on upper shelf (fewer)
	var book_colors2: Array = [VT.SHELF_BOOK_C, VT.SHELF_BOOK_A, VT.SHELF_BOOK_D]
	var bx2: float = -8.0
	for bi2: int in range(3):
		add_rect_polygon(c + Vector2(bx2, -h * 0.74), Vector2(5, 10), book_colors2[bi2], z + 4)
		bx2 += 7.0


func draw_desk_details(furniture, lz: int = 0) -> void:
	var h: float = get_furniture_height(furniture.type)
	var cell: Vector2i = furniture.cell
	if not iso_grid.is_valid_cell(cell):
		return
	var c: Vector2 = iso_grid.grid_to_iso(cell)
	var z: int = iso_grid.get_draw_z_index(cell) + lz
	# Desktop surface - single cohesive visual
	_add_small_diamond(c, -h - 1.0, 0.86, VT.DESK_TOP, z + 3)
	# Surface edge trim
	add_rect_polygon(c + Vector2(0, -h * 0.5 + 3), Vector2(32, 4), VT.DESK_EDGE, z + 2)
	# Legs
	add_rect_polygon(c + Vector2(-14, -h * 0.5 + 6), Vector2(4, h - 2), VT.DESK_LEG, z + 1)
	add_rect_polygon(c + Vector2(14, -h * 0.5 + 6), Vector2(4, h - 2), VT.DESK_LEG, z + 1)
	# Small object on desk surface (book/monitor stub)
	add_rect_polygon(c + Vector2(4, -h - 8), Vector2(10, 10), VT.SHELF_BOOK_B, z + 5)
	add_rect_polygon(c + Vector2(4, -h - 13), Vector2(10, 3), Color(0.90, 0.90, 0.90), z + 6)


func draw_poster_details(furniture, lz: int = 0) -> void:
	var h: float = get_furniture_height(furniture.type)
	var c: Vector2 = iso_grid.grid_to_iso(furniture.cell)
	var z: int = iso_grid.get_draw_z_index(furniture.cell) + lz
	# Board frame
	add_rect_polygon(c + Vector2(0, -h - 16), Vector2(28, 30), VT.POSTER_FRAME, z + 2)
	# White board face
	add_rect_polygon(c + Vector2(0, -h - 16), Vector2(24, 26), VT.POSTER_BOARD, z + 3)
	# Art stripes
	add_rect_polygon(c + Vector2(0, -h - 20), Vector2(20, 8), VT.POSTER_STRIPE_A, z + 4)
	add_rect_polygon(c + Vector2(0, -h - 10), Vector2(20, 6), VT.POSTER_STRIPE_B, z + 4)
	# Stand legs (two thin rects)
	add_rect_polygon(c + Vector2(-6, -h - 1), Vector2(3, 8), VT.POSTER_FRAME, z + 2)
	add_rect_polygon(c + Vector2(6, -h - 1), Vector2(3, 8), VT.POSTER_FRAME, z + 2)


func draw_big_plant_details(furniture, lz: int = 0) -> void:
	var c: Vector2 = iso_grid.grid_to_iso(furniture.cell)
	var z: int = iso_grid.get_draw_z_index(furniture.cell) + lz
	# Large pot body
	add_rect_polygon(c + Vector2(0, -22), Vector2(28, 18), VT.BIGPLANT_POT, z + 4)
	add_rect_polygon(c + Vector2(0, -30), Vector2(32, 8), VT.BIGPLANT_POT_DK, z + 4)
	# Pot rim
	add_rect_polygon(c + Vector2(0, -14), Vector2(36, 8), VT.BIGPLANT_POT_RIM, z + 5)
	# Soil
	_add_small_diamond(c, -32.0, 0.36, VT.PLANT_SOIL, z + 6)
	# Trunk/stem (thicker)
	add_rect_polygon(c + Vector2(0, -44), Vector2(6, 16), VT.PLANT_STEM, z + 5)
	# Large leaf clusters
	_add_small_diamond(c + Vector2(-18, 0), -60.0, 0.56, VT.PLANT_LEAF_DK, z + 5)
	_add_small_diamond(c + Vector2(18, 0), -62.0, 0.50, VT.PLANT_LEAF_DK, z + 5)
	_add_small_diamond(c + Vector2(-10, 0), -54.0, 0.46, VT.PLANT_LEAF, z + 6)
	_add_small_diamond(c + Vector2(10, 0), -56.0, 0.42, VT.PLANT_LEAF, z + 6)
	_add_small_diamond(c, -70.0, 0.44, VT.PLANT_LEAF_LT, z + 7)
	_add_small_diamond(c + Vector2(-4, 0), -76.0, 0.20, Color(VT.PLANT_LEAF_HI.r, VT.PLANT_LEAF_HI.g, VT.PLANT_LEAF_HI.b, 0.72), z + 8)


func draw_red_rug_details(furniture, lz: int = 0) -> void:
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
	var fill: Polygon2D = Polygon2D.new()
	fill.polygon = PackedVector2Array([
		Vector2(0, -26), Vector2(54, 0), Vector2(0, 26), Vector2(-54, 0)
	])
	fill.position = center + Vector2(0, yo)
	fill.color = Color(VT.RED_RUG_FILL.r, VT.RED_RUG_FILL.g, VT.RED_RUG_FILL.b, 0.52)
	fill.z_index = z
	blocks_node.add_child(fill)
	var outer: Line2D = Line2D.new()
	outer.points = PackedVector2Array([Vector2(0, -30), Vector2(62, 0), Vector2(0, 30), Vector2(-62, 0), Vector2(0, -30)])
	outer.position = center + Vector2(0, yo)
	outer.width = 2.5
	outer.default_color = VT.RED_RUG_BORDER
	outer.z_index = z + 1
	blocks_node.add_child(outer)
	var inner: Line2D = Line2D.new()
	inner.points = PackedVector2Array([Vector2(0, -20), Vector2(42, 0), Vector2(0, 20), Vector2(-42, 0), Vector2(0, -20)])
	inner.position = center + Vector2(0, yo)
	inner.width = 1.5
	inner.default_color = VT.RED_RUG_BORDER_DIM
	inner.z_index = z + 1
	blocks_node.add_child(inner)
	_add_small_diamond(center, yo - 1.0, 0.18, VT.RED_RUG_CENTER, z + 2)
	_add_small_diamond(center, yo - 0.5, 0.08, VT.RED_RUG_CENTER_HI, z + 3)


func draw_floor_tile_details(furniture, lz: int = 0) -> void:
	var h: float = get_furniture_height(furniture.type)
	var c: Vector2 = iso_grid.grid_to_iso(furniture.cell)
	var z: int = iso_grid.get_draw_z_index(furniture.cell) + lz - 4
	var tw: float = float(iso_grid.tile_width)
	var th: float = float(iso_grid.tile_height)
	# Tile base (slightly smaller than full diamond)
	_add_small_diamond(c, -h, 0.88, VT.TILE_BASE, z + 1)
	# Grout border line
	var border: Line2D = Line2D.new()
	var hw: float = tw * 0.44
	var hh: float = th * 0.44
	border.points = PackedVector2Array([
		Vector2(0, -hh), Vector2(hw, 0), Vector2(0, hh), Vector2(-hw, 0), Vector2(0, -hh)
	])
	border.position = c + Vector2(0, -h)
	border.width = 1.8
	border.default_color = VT.TILE_GROUT
	border.z_index = z + 2
	blocks_node.add_child(border)
	# Center highlight
	_add_small_diamond(c + Vector2(-3, 0), -h - 1.5, 0.28, VT.TILE_HI, z + 2)


func _add_wide_diamond(center: Vector2, y_offset: float, x_scale: float, color: Color, z: int) -> void:
	var hw: float = float(iso_grid.tile_width) * 0.5 * x_scale
	var hh: float = float(iso_grid.tile_height) * 0.5 * x_scale * 0.5
	var poly: Polygon2D = Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(0, -hh), Vector2(hw, 0), Vector2(0, hh), Vector2(-hw, 0)
	])
	poly.position = center + Vector2(0, y_offset)
	poly.color = color
	poly.z_index = z
	blocks_node.add_child(poly)


func get_furniture_color(furniture_type) -> Color:
	match furniture_type:
		&"chair":       return VT.CHAIR_BODY
		&"table":       return VT.TABLE_BODY
		&"sofa":        return VT.SOFA_BODY
		&"plant":       return VT.PLANT_LEAF_DK
		&"rug":         return VT.RUG_BODY
		&"blue_rug":    return Color(0.12, 0.34, 0.78)
		&"golden_plant":return Color(0.90, 0.66, 0.18)
		&"lounge_chair":return Color(0.42, 0.24, 0.62)
		&"bed":         return VT.BED_FRAME
		&"lamp":        return VT.LAMP_BASE
		&"bookshelf":   return VT.SHELF_WOOD
		&"desk":        return VT.DESK_SURFACE
		&"poster":      return VT.POSTER_BOARD
		&"big_plant":   return VT.BIGPLANT_POT
		&"red_rug":     return VT.RED_RUG_BODY
		&"floor_tile":  return VT.TILE_BASE
		_:              return Color(0.60, 0.60, 0.60)


func get_furniture_height(furniture_type) -> float:
	match furniture_type:
		&"chair":       return 16.0
		&"table":       return 14.0
		&"sofa":        return 18.0
		&"plant":       return 24.0
		&"rug":         return 4.0
		&"blue_rug":    return 4.0
		&"golden_plant":return 24.0
		&"lounge_chair":return 17.0
		&"bed":         return 12.0
		&"lamp":        return 6.0
		&"bookshelf":   return 28.0
		&"desk":        return 14.0
		&"poster":      return 2.0
		&"big_plant":   return 20.0
		&"red_rug":     return 4.0
		&"floor_tile":  return 2.0
		_:              return 14.0


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
