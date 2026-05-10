extends RefCounted


const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const FurnitureData = FurnitureDataScript
const VT = preload("res://scripts/visual/VisualTheme.gd")
const RoomFloorSpriteSheetResolver = preload("res://scripts/room/RoomFloorSpriteSheetResolver.gd")

const ROOM_WALL_HEIGHT: float = 150.0
const ROOM_WALL_Z: int = -260
const ROOM_WALL_LEFT: Color = Color(0.88, 0.80, 0.66)
const ROOM_WALL_RIGHT: Color = Color(0.80, 0.70, 0.56)
const ROOM_WALL_TOP: Color = Color(0.96, 0.90, 0.78)
const ROOM_BASEBOARD: Color = Color(0.36, 0.22, 0.12)
const ROOM_BASEBOARD_HI: Color = Color(0.58, 0.38, 0.20)
const ROOM_DOOR: Color = Color(0.42, 0.24, 0.12)
const ROOM_DOOR_HI: Color = Color(0.60, 0.36, 0.18)
const ROOM_WINDOW: Color = Color(0.48, 0.68, 0.82)
const ROOM_WINDOW_HI: Color = Color(0.76, 0.88, 0.96, 0.72)
const ROOM_TRIM: Color = Color(0.28, 0.18, 0.10)
const ROOM_PICTURE: Color = Color(0.74, 0.42, 0.28)
const ROOM_PICTURE_INNER: Color = Color(0.92, 0.78, 0.46)
const FLOOR_SPRITE_SCALE := Vector2(1.0667, 0.6154)


var floor_node: Node2D
var grid_width
var grid_height
var tile_width
var tile_height
var iso_offset
var default_floor_type: String = "beige_basic"
var _floor_spritesheet_warning_shown: bool = false


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


func set_floor_type(floor_type: String) -> void:
	default_floor_type = floor_type if RoomFloorSpriteSheetResolver.has_tile(floor_type) else "beige_basic"


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
	var bounds_position = min_position - tile_padding - margin_vector - Vector2(0.0, ROOM_WALL_HEIGHT * 0.45)
	var bounds_end = max_position + tile_padding + margin_vector

	return Rect2(bounds_position, bounds_end - bounds_position)


func redraw_tiles(blocked_cells: Array[Vector2i]) :
	clear_floor()
	draw_room_shell()

	if not draw_sprite_floor():
		clear_floor()
		draw_room_shell()
		draw_fallback_floor(blocked_cells)


func draw_sprite_floor() -> bool:
	if not RoomFloorSpriteSheetResolver.has_floor_spritesheet():
		_warn_floor_spritesheet_fallback("Floor spritesheet missing, using fallback floor renderer.")
		return false

	for x in range(grid_width):
		for y in range(grid_height):
			var cell := Vector2i(x, y)
			var tile_type := get_tile_type_for_cell(cell)
			var texture := RoomFloorSpriteSheetResolver.get_floor_tile(tile_type)
			if texture == null:
				_warn_floor_spritesheet_fallback("Floor tile '" + tile_type + "' unavailable, using fallback floor renderer.")
				return false

			var tile := Sprite2D.new()
			tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			tile.texture_repeat = CanvasItem.TEXTURE_REPEAT_DISABLED
			tile.texture = texture
			tile.centered = true
			tile.scale = FLOOR_SPRITE_SCALE
			tile.position = grid_to_iso(cell)
			tile.z_index = get_draw_z_index(cell) - 8
			floor_node.add_child(tile)

	return true


func draw_fallback_floor(blocked_cells: Array[Vector2i]) -> void:
	for x in range(grid_width):
		for y in range(grid_height):
			var cell = Vector2i(x, y)
			var tile: Polygon2D = Polygon2D.new()
			tile.polygon = get_iso_diamond_polygon()
			tile.position = grid_to_iso(cell)
			tile.z_index = get_draw_z_index(cell) - 8
			if blocked_cells.has(cell):
				tile.color = Color(0.72, 0.68, 0.55)
			elif (x + y) % 2 == 0:
				tile.color = VT.FLOOR_A
			else:
				tile.color = VT.FLOOR_B

			floor_node.add_child(tile)
			_draw_tile_inner(cell)
			_draw_tile_edge_shadow(cell)
			draw_tile_outline(cell)


func get_tile_type_for_cell(_cell: Vector2i) -> String:
	return default_floor_type


func _warn_floor_spritesheet_fallback(message: String) -> void:
	if _floor_spritesheet_warning_shown:
		return
	_floor_spritesheet_warning_shown = true
	push_warning(message)


func get_draw_z_index(cell) :
	return (cell.x + cell.y) * 10


func clear_floor() :
	for child: Node in floor_node.get_children():
		floor_node.remove_child(child)
		child.queue_free()


func draw_room_shell() -> void:
	var corners: Dictionary = _get_room_floor_corners()
	var top: Vector2 = corners["top"]
	var left: Vector2 = corners["left"]
	var right: Vector2 = corners["right"]
	var bottom: Vector2 = corners["bottom"]
	var up: Vector2 = Vector2(0.0, -ROOM_WALL_HEIGHT)

	_draw_soft_room_shadow(left, right, bottom)
	_draw_poly(PackedVector2Array([top, left, left + up, top + up]), ROOM_WALL_LEFT, ROOM_WALL_Z)
	_draw_poly(PackedVector2Array([top, right, right + up, top + up]), ROOM_WALL_RIGHT, ROOM_WALL_Z + 1)
	_draw_wall_cap(top, left, right, up)
	_draw_wall_decorations(top, left, right, up)
	_draw_baseboards(top, left, right)


func _get_room_floor_corners() -> Dictionary:
	var tw: float = float(tile_width)
	var th: float = float(tile_height)
	return {
		"top": grid_to_iso(Vector2i(0, 0)) + Vector2(0.0, -th * 0.5),
		"left": grid_to_iso(Vector2i(0, grid_height - 1)) + Vector2(-tw * 0.5, 0.0),
		"right": grid_to_iso(Vector2i(grid_width - 1, 0)) + Vector2(tw * 0.5, 0.0),
		"bottom": grid_to_iso(Vector2i(grid_width - 1, grid_height - 1)) + Vector2(0.0, th * 0.5),
	}


func _draw_soft_room_shadow(left: Vector2, right: Vector2, bottom: Vector2) -> void:
	var shadow: Polygon2D = _draw_poly(
		PackedVector2Array([
			left + Vector2(-22.0, 18.0),
			right + Vector2(22.0, 18.0),
			bottom + Vector2(0.0, 34.0),
			bottom + Vector2(-90.0, 48.0),
			left + Vector2(-52.0, 24.0),
		]),
		Color(0.08, 0.07, 0.10, 0.18),
		ROOM_WALL_Z - 3
	)
	shadow.antialiased = true


func _draw_wall_cap(top: Vector2, left: Vector2, right: Vector2, up: Vector2) -> void:
	var cap_height: float = 8.0
	_draw_poly(PackedVector2Array([
		left + up,
		top + up,
		top + up + Vector2(0.0, -cap_height),
		left + up + Vector2(-8.0, -cap_height),
	]), ROOM_WALL_TOP, ROOM_WALL_Z + 2)
	_draw_poly(PackedVector2Array([
		top + up,
		right + up,
		right + up + Vector2(8.0, -cap_height),
		top + up + Vector2(0.0, -cap_height),
	]), ROOM_WALL_TOP.darkened(0.08), ROOM_WALL_Z + 2)


func _draw_wall_decorations(top: Vector2, left: Vector2, right: Vector2, up: Vector2) -> void:
	_draw_door_on_right_wall(top, right, up)
	_draw_window_on_left_wall(top, left, up)
	_draw_picture_on_right_wall(top, right, up)


func _draw_door_on_right_wall(top: Vector2, right: Vector2, up: Vector2) -> void:
	var b1: Vector2 = top.lerp(right, 0.48)
	var b2: Vector2 = top.lerp(right, 0.66)
	var door_up: Vector2 = up * 0.56
	var frame_pad: Vector2 = (b2 - b1).normalized() * 5.0
	_draw_poly(PackedVector2Array([b1 - frame_pad, b2 + frame_pad, b2 + door_up + frame_pad, b1 + door_up - frame_pad]), ROOM_TRIM, ROOM_WALL_Z + 4)
	_draw_poly(PackedVector2Array([b1, b2, b2 + door_up, b1 + door_up]), ROOM_DOOR, ROOM_WALL_Z + 5)
	_draw_poly(PackedVector2Array([b1.lerp(b2, 0.10), b1.lerp(b2, 0.45), b1.lerp(b2, 0.45) + door_up * 0.88, b1.lerp(b2, 0.10) + door_up * 0.88]), ROOM_DOOR_HI, ROOM_WALL_Z + 6)
	_draw_small_diamond(b1.lerp(b2, 0.78) + door_up * 0.46, 3.0, Color(0.95, 0.74, 0.32), ROOM_WALL_Z + 7)


func _draw_window_on_left_wall(top: Vector2, left: Vector2, up: Vector2) -> void:
	var b1: Vector2 = top.lerp(left, 0.32) + up * 0.38
	var b2: Vector2 = top.lerp(left, 0.52) + up * 0.38
	var h: Vector2 = up * 0.26
	var side: Vector2 = (b2 - b1).normalized() * 5.0
	_draw_poly(PackedVector2Array([b1 - side, b2 + side, b2 + h + side, b1 + h - side]), ROOM_TRIM, ROOM_WALL_Z + 4)
	_draw_poly(PackedVector2Array([b1, b2, b2 + h, b1 + h]), ROOM_WINDOW, ROOM_WALL_Z + 5)
	_draw_line(PackedVector2Array([b1.lerp(b2, 0.5), b1.lerp(b2, 0.5) + h]), ROOM_TRIM, 2.0, ROOM_WALL_Z + 6)
	_draw_poly(PackedVector2Array([
		b1.lerp(b2, 0.18) + h * 0.18,
		b1.lerp(b2, 0.44) + h * 0.18,
		b1.lerp(b2, 0.30) + h * 0.78,
		b1.lerp(b2, 0.08) + h * 0.78,
	]), ROOM_WINDOW_HI, ROOM_WALL_Z + 6)


func _draw_picture_on_right_wall(top: Vector2, right: Vector2, up: Vector2) -> void:
	var b1: Vector2 = top.lerp(right, 0.16) + up * 0.44
	var b2: Vector2 = top.lerp(right, 0.29) + up * 0.44
	var h: Vector2 = up * 0.18
	var pad: Vector2 = (b2 - b1).normalized() * 4.0
	_draw_poly(PackedVector2Array([b1 - pad, b2 + pad, b2 + h + pad, b1 + h - pad]), ROOM_TRIM, ROOM_WALL_Z + 4)
	_draw_poly(PackedVector2Array([b1, b2, b2 + h, b1 + h]), ROOM_PICTURE, ROOM_WALL_Z + 5)
	_draw_poly(PackedVector2Array([
		b1.lerp(b2, 0.18) + h * 0.18,
		b1.lerp(b2, 0.82) + h * 0.18,
		b1.lerp(b2, 0.70) + h * 0.80,
		b1.lerp(b2, 0.30) + h * 0.80,
	]), ROOM_PICTURE_INNER, ROOM_WALL_Z + 6)


func _draw_baseboards(top: Vector2, left: Vector2, right: Vector2) -> void:
	_draw_line(PackedVector2Array([left, top, right]), ROOM_BASEBOARD, 8.0, -5)
	_draw_line(PackedVector2Array([left + Vector2(0.0, -4.0), top + Vector2(0.0, -4.0), right + Vector2(0.0, -4.0)]), ROOM_BASEBOARD_HI, 2.0, -4)


func _draw_poly(points: PackedVector2Array, color: Color, z: int) -> Polygon2D:
	var poly: Polygon2D = Polygon2D.new()
	poly.polygon = points
	poly.color = color
	poly.z_index = z
	poly.antialiased = true
	floor_node.add_child(poly)
	return poly


func _draw_line(points: PackedVector2Array, color: Color, width: float, z: int) -> Line2D:
	var line: Line2D = Line2D.new()
	line.points = points
	line.default_color = color
	line.width = width
	line.z_index = z
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	floor_node.add_child(line)
	return line


func _draw_small_diamond(center: Vector2, radius: float, color: Color, z: int) -> void:
	_draw_poly(PackedVector2Array([
		center + Vector2(0.0, -radius),
		center + Vector2(radius, 0.0),
		center + Vector2(0.0, radius),
		center + Vector2(-radius, 0.0),
	]), color, z)


func _draw_tile_edge_shadow(cell) -> void:
	var cp: Vector2 = grid_to_iso(cell)
	var tw: float = float(tile_width)
	var th: float = float(tile_height)
	var z: int = get_draw_z_index(cell) - 7

	# Right face shadow strip (bottom-right edge of tile)
	var right_shadow: Polygon2D = Polygon2D.new()
	right_shadow.polygon = PackedVector2Array([
		Vector2(tw * 0.5, 0.0),
		Vector2(0.0, th * 0.5),
		Vector2(0.0, th * 0.5 + 3.0),
		Vector2(tw * 0.5, 3.0)
	])
	right_shadow.position = cp
	right_shadow.color = VT.FLOOR_SHADOW
	right_shadow.z_index = z
	floor_node.add_child(right_shadow)

	# Left face shadow strip (bottom-left edge of tile)
	var left_shadow: Polygon2D = Polygon2D.new()
	left_shadow.polygon = PackedVector2Array([
		Vector2(-tw * 0.5, 0.0),
		Vector2(0.0, th * 0.5),
		Vector2(0.0, th * 0.5 + 3.0),
		Vector2(-tw * 0.5, 3.0)
	])
	left_shadow.position = cp
	left_shadow.color = Color(VT.FLOOR_SHADOW.r, VT.FLOOR_SHADOW.g, VT.FLOOR_SHADOW.b, VT.FLOOR_SHADOW.a * 0.65)
	left_shadow.z_index = z
	floor_node.add_child(left_shadow)


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
	outline.default_color = VT.FLOOR_OUTLINE
	outline.z_index = get_draw_z_index(cell) - 7
	floor_node.add_child(outline)
