extends RefCounted


const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const FurnitureData = FurnitureDataScript


var floor_node: Node2D
var grid_width
var grid_height
var tile_width
var tile_height
var iso_offset


func _init(
	p_floor_node: Node2D,
	p_grid_width,
	p_grid_height,
	p_tile_width,
	p_tile_height,
	p_iso_offset
) :
	floor_node = p_floor_node
	grid_width = p_grid_width
	grid_height = p_grid_height
	tile_width = p_tile_width
	tile_height = p_tile_height
	iso_offset = p_iso_offset


func grid_to_iso(cell) -> Vector2:
	var iso_x = float(cell.x - cell.y) * float(tile_width) / 2.0
	var iso_y = float(cell.x + cell.y) * float(tile_height) / 2.0

	return Vector2(iso_x, iso_y) + iso_offset


func iso_to_grid(position) -> Vector2i:
	var local_position = position - iso_offset

	var grid_x_float = (
		local_position.x / (float(tile_width) / 2.0)
		+ local_position.y / (float(tile_height) / 2.0)
	) / 2.0

	var grid_y_float = (
		local_position.y / (float(tile_height) / 2.0)
		- local_position.x / (float(tile_width) / 2.0)
	) / 2.0

	return Vector2i(int(round(grid_x_float)), int(round(grid_y_float)))


func is_valid_cell(cell) :
	return (
		cell.x >= 0
		and cell.x < grid_width
		and cell.y >= 0
		and cell.y < grid_height
	)


func set_room_size(width, height) :
	grid_width = width
	grid_height = height


func get_iso_diamond_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0, -float(tile_height) / 2.0),
		Vector2(float(tile_width) / 2.0, 0),
		Vector2(0, float(tile_height) / 2.0),
		Vector2(-float(tile_width) / 2.0, 0)
	])


func get_room_bounds(margin) -> Rect2:
	var points: Array[Vector2] = [
		grid_to_iso(Vector2i(0, 0)),
		grid_to_iso(Vector2i(grid_width - 1, 0)),
		grid_to_iso(Vector2i(0, grid_height - 1)),
		grid_to_iso(Vector2i(grid_width - 1, grid_height - 1))
	]
	var min_position = points[0]
	var max_position = points[0]

	for point in points:
		min_position.x = minf(min_position.x, point.x)
		min_position.y = minf(min_position.y, point.y)
		max_position.x = maxf(max_position.x, point.x)
		max_position.y = maxf(max_position.y, point.y)

	var tile_padding = Vector2(float(tile_width), float(tile_height))
	var margin_vector = Vector2(margin, margin)
	var bounds_position = min_position - tile_padding - margin_vector
	var bounds_end = max_position + tile_padding + margin_vector

	return Rect2(bounds_position, bounds_end - bounds_position)


func redraw_tiles(blocked_cells: Array[Vector2i]) :
	clear_floor()

	for x in range(grid_width):
		for y in range(grid_height):
			var cell = Vector2i(x, y)
			var tile: Polygon2D = Polygon2D.new()
			tile.polygon = get_iso_diamond_polygon()
			tile.position = grid_to_iso(cell)
			tile.z_index = get_draw_z_index(cell) - 8

			if blocked_cells.has(cell):
				tile.color = Color(0.60, 0.68, 0.60)
			elif (x + y) % 2 == 0:
				tile.color = Color(0.86, 0.80, 0.66)
			else:
				tile.color = Color(0.79, 0.73, 0.58)

			floor_node.add_child(tile)
			_draw_tile_inner(cell)
			draw_tile_outline(cell)


func get_draw_z_index(cell) :
	return (cell.x + cell.y) * 10


func clear_floor() :
	for child: Node in floor_node.get_children():
		floor_node.remove_child(child)
		child.queue_free()


func _draw_tile_inner(cell) -> void:
	var inner: Polygon2D = Polygon2D.new()
	var s: float = 0.62
	var hw: float = float(tile_width) * 0.5 * s
	var hh: float = float(tile_height) * 0.5 * s
	inner.polygon = PackedVector2Array([
		Vector2(0, -hh), Vector2(hw, 0), Vector2(0, hh), Vector2(-hw, 0)
	])
	inner.position = grid_to_iso(cell)
	inner.color = Color(1.0, 1.0, 1.0, 0.06)
	inner.z_index = get_draw_z_index(cell) - 7
	floor_node.add_child(inner)


func draw_tile_outline(cell) :
	var outline: Line2D = Line2D.new()
	var outline_points: PackedVector2Array = get_iso_diamond_polygon()
	outline_points.append(outline_points[0])
	outline.points = outline_points
	outline.position = grid_to_iso(cell)
	outline.width = 1.4
	outline.default_color = Color(0.46, 0.38, 0.28, 0.42)
	outline.z_index = get_draw_z_index(cell) - 7
	floor_node.add_child(outline)
