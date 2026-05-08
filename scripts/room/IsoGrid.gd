extends RefCounted
class_name IsoGrid

var floor_node: Node2D
var grid_width: int
var grid_height: int
var tile_width: int
var tile_height: int
var iso_offset: Vector2


func _init(
	p_floor_node: Node2D,
	p_grid_width: int,
	p_grid_height: int,
	p_tile_width: int,
	p_tile_height: int,
	p_iso_offset: Vector2
) -> void:
	floor_node = p_floor_node
	grid_width = p_grid_width
	grid_height = p_grid_height
	tile_width = p_tile_width
	tile_height = p_tile_height
	iso_offset = p_iso_offset


func grid_to_iso(cell: Vector2i) -> Vector2:
	var iso_x: float = float(cell.x - cell.y) * float(tile_width) / 2.0
	var iso_y: float = float(cell.x + cell.y) * float(tile_height) / 2.0

	return Vector2(iso_x, iso_y) + iso_offset


func iso_to_grid(position: Vector2) -> Vector2i:
	var local_position: Vector2 = position - iso_offset

	var grid_x_float: float = (
		local_position.x / (float(tile_width) / 2.0)
		+ local_position.y / (float(tile_height) / 2.0)
	) / 2.0

	var grid_y_float: float = (
		local_position.y / (float(tile_height) / 2.0)
		- local_position.x / (float(tile_width) / 2.0)
	) / 2.0

	return Vector2i(int(round(grid_x_float)), int(round(grid_y_float)))


func is_valid_cell(cell: Vector2i) -> bool:
	return (
		cell.x >= 0
		and cell.x < grid_width
		and cell.y >= 0
		and cell.y < grid_height
	)


func set_room_size(width: int, height: int) -> void:
	grid_width = width
	grid_height = height


func get_iso_diamond_polygon() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(0, -float(tile_height) / 2.0),
		Vector2(float(tile_width) / 2.0, 0),
		Vector2(0, float(tile_height) / 2.0),
		Vector2(-float(tile_width) / 2.0, 0)
	])


func get_room_bounds(margin: float) -> Rect2:
	var points: Array[Vector2] = [
		grid_to_iso(Vector2i(0, 0)),
		grid_to_iso(Vector2i(grid_width - 1, 0)),
		grid_to_iso(Vector2i(0, grid_height - 1)),
		grid_to_iso(Vector2i(grid_width - 1, grid_height - 1))
	]
	var min_position: Vector2 = points[0]
	var max_position: Vector2 = points[0]

	for point: Vector2 in points:
		min_position.x = minf(min_position.x, point.x)
		min_position.y = minf(min_position.y, point.y)
		max_position.x = maxf(max_position.x, point.x)
		max_position.y = maxf(max_position.y, point.y)

	var tile_padding: Vector2 = Vector2(float(tile_width), float(tile_height))
	var margin_vector: Vector2 = Vector2(margin, margin)
	var bounds_position: Vector2 = min_position - tile_padding - margin_vector
	var bounds_end: Vector2 = max_position + tile_padding + margin_vector

	return Rect2(bounds_position, bounds_end - bounds_position)


func redraw_tiles(blocked_cells: Array[Vector2i]) -> void:
	clear_floor()

	for x: int in range(grid_width):
		for y: int in range(grid_height):
			var cell: Vector2i = Vector2i(x, y)
			var tile: Polygon2D = Polygon2D.new()

			tile.polygon = get_iso_diamond_polygon()
			tile.position = grid_to_iso(cell)
			tile.z_index = get_draw_z_index(cell) - 8
			tile.color = Color(0.70, 0.82, 0.68)

			if blocked_cells.has(cell):
				tile.color = Color(0.55, 0.64, 0.58)

			floor_node.add_child(tile)
			draw_tile_outline(cell)


func get_draw_z_index(cell: Vector2i) -> int:
	return (cell.x + cell.y) * 10


func clear_floor() -> void:
	for child: Node in floor_node.get_children():
		floor_node.remove_child(child)
		child.queue_free()


func draw_tile_outline(cell: Vector2i) -> void:
	var outline: Line2D = Line2D.new()
	var outline_points: PackedVector2Array = get_iso_diamond_polygon()
	outline_points.append(outline_points[0])
	outline.points = outline_points
	outline.position = grid_to_iso(cell)
	outline.width = 1.2
	outline.default_color = Color(0.20, 0.29, 0.24, 0.32)
	outline.z_index = get_draw_z_index(cell) - 7
	floor_node.add_child(outline)
