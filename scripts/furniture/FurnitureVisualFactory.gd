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


func draw_furniture(furniture) :
	var height = get_furniture_height(furniture.type)
	var base_color: Color = get_furniture_color(furniture.type)

	for cell in furniture.get_occupied_cells():
		if not iso_grid.is_valid_cell(cell):
			continue

		draw_furniture_block_cell(cell, height, base_color)

	match furniture.type:
		&"chair":
			draw_chair_details(furniture)
		&"table":
			draw_table_details(furniture)
		&"sofa":
			draw_sofa_details(furniture)
		&"plant":
			draw_plant_details(furniture)


func clear_blocks() :
	for child: Node in blocks_node.get_children():
		blocks_node.remove_child(child)
		child.queue_free()


func draw_furniture_block_cell(cell, height, base_color: Color) :
	var cell_position = iso_grid.grid_to_iso(cell)
	var draw_z = iso_grid.get_draw_z_index(cell)

	var shadow: Polygon2D = Polygon2D.new()
	shadow.polygon = iso_grid.get_iso_diamond_polygon()
	shadow.position = cell_position + Vector2(0, 3)
	shadow.color = Color(0.07, 0.08, 0.07, 0.28)
	shadow.z_index = draw_z - 1
	blocks_node.add_child(shadow)

	var top: Polygon2D = Polygon2D.new()
	top.polygon = iso_grid.get_iso_diamond_polygon()
	top.position = cell_position + Vector2(0, -height)
	top.color = base_color.lightened(0.20)
	top.z_index = draw_z + 2
	blocks_node.add_child(top)

	var left_face: Polygon2D = Polygon2D.new()
	left_face.polygon = PackedVector2Array([
		Vector2(-float(iso_grid.tile_width) / 2.0, 0),
		Vector2(0, float(iso_grid.tile_height) / 2.0),
		Vector2(0, float(iso_grid.tile_height) / 2.0 + height),
		Vector2(-float(iso_grid.tile_width) / 2.0, height)
	])
	left_face.position = cell_position + Vector2(0, -height)
	left_face.color = base_color.darkened(0.26)
	left_face.z_index = draw_z + 1
	blocks_node.add_child(left_face)

	var right_face: Polygon2D = Polygon2D.new()
	right_face.polygon = PackedVector2Array([
		Vector2(float(iso_grid.tile_width) / 2.0, 0),
		Vector2(0, float(iso_grid.tile_height) / 2.0),
		Vector2(0, float(iso_grid.tile_height) / 2.0 + height),
		Vector2(float(iso_grid.tile_width) / 2.0, height)
	])
	right_face.position = cell_position + Vector2(0, -height)
	right_face.color = base_color.darkened(0.10)
	right_face.z_index = draw_z + 1
	blocks_node.add_child(right_face)


func draw_chair_details(furniture) :
	var cell = furniture.cell
	var height = get_furniture_height(furniture.type)
	var center = iso_grid.grid_to_iso(cell)
	var draw_z = iso_grid.get_draw_z_index(cell)

	add_rect_polygon(center + Vector2(0, -height - 20.0), Vector2(34, 22), Color(0.39, 0.19, 0.11), draw_z + 4)
	add_rect_polygon(center + Vector2(0, -height - 6.0), Vector2(24, 8), Color(0.80, 0.46, 0.25), draw_z + 5)


func draw_table_details(furniture) :
	var height = get_furniture_height(furniture.type)

	for cell in furniture.get_occupied_cells():
		if not iso_grid.is_valid_cell(cell):
			continue

		var center = iso_grid.grid_to_iso(cell)
		var draw_z = iso_grid.get_draw_z_index(cell)
		var runner: Polygon2D = Polygon2D.new()
		runner.polygon = PackedVector2Array([
			Vector2(0, -8),
			Vector2(19, 0),
			Vector2(0, 8),
			Vector2(-19, 0)
		])
		runner.position = center + Vector2(0, -height - 1.0)
		runner.color = Color(0.88, 0.71, 0.45)
		runner.z_index = draw_z + 4
		blocks_node.add_child(runner)

		add_rect_polygon(center + Vector2(-16, 4), Vector2(6, 18), Color(0.34, 0.18, 0.10), draw_z + 3)
		add_rect_polygon(center + Vector2(16, 4), Vector2(6, 18), Color(0.42, 0.22, 0.12), draw_z + 3)


func draw_sofa_details(furniture) :
	var height = get_furniture_height(furniture.type)

	for cell in furniture.get_occupied_cells():
		if not iso_grid.is_valid_cell(cell):
			continue

		var center = iso_grid.grid_to_iso(cell)
		var draw_z = iso_grid.get_draw_z_index(cell)
		add_rect_polygon(center + Vector2(0, -height - 16.0), Vector2(50, 18), Color(0.18, 0.30, 0.58), draw_z + 4)
		add_rect_polygon(center + Vector2(0, -height - 1.0), Vector2(44, 10), Color(0.36, 0.56, 0.90), draw_z + 5)


func draw_plant_details(furniture) :
	var center = iso_grid.grid_to_iso(furniture.cell)
	var draw_z = iso_grid.get_draw_z_index(furniture.cell)
	add_rect_polygon(center + Vector2(0, -24), Vector2(18, 18), Color(0.28, 0.16, 0.08), draw_z + 4)
	add_rect_polygon(center + Vector2(-8, -40), Vector2(18, 24), Color(0.12, 0.50, 0.20), draw_z + 5)
	add_rect_polygon(center + Vector2(9, -43), Vector2(18, 22), Color(0.18, 0.68, 0.28), draw_z + 5)


func draw_selected_furniture_marker(items, selected_index) :
	if selected_index < 0 or selected_index >= items.size():
		return

	var furniture = items[selected_index]

	for cell in furniture.get_occupied_cells():
		if not iso_grid.is_valid_cell(cell):
			continue

		var marker: Polygon2D = Polygon2D.new()
		marker.polygon = iso_grid.get_iso_diamond_polygon()
		marker.position = iso_grid.grid_to_iso(cell) + Vector2(0, -get_furniture_height(furniture.type) - 4.0)
		marker.color = Color(1.0, 0.9, 0.15, 0.45)
		marker.z_index = iso_grid.get_draw_z_index(cell) + 5
		blocks_node.add_child(marker)


func get_furniture_color(furniture_type) -> Color:
	match furniture_type:
		&"chair":
			return Color(0.62, 0.32, 0.18)
		&"table":
			return Color(0.64, 0.39, 0.20)
		&"sofa":
			return Color(0.20, 0.38, 0.72)
		&"plant":
			return Color(0.2, 0.62, 0.28)
		_:
			return Color(0.65, 0.65, 0.65)


func get_furniture_height(furniture_type) -> float:
	match furniture_type:
		&"chair":
			return 17.0
		&"table":
			return 18.0
		&"sofa":
			return 22.0
		&"plant":
			return 28.0
		_:
			return 16.0


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
