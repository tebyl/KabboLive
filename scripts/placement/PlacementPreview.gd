extends RefCounted

const VT = preload("res://scripts/visual/VisualTheme.gd")

var preview_root: Node2D
var iso_grid
var current_nodes: Array[Node2D] = []


func setup(parent: Node2D, p_iso_grid) -> void:
	preview_root = Node2D.new()
	preview_root.name = "PlacementPreview"
	preview_root.z_as_relative = false
	parent.add_child(preview_root)
	iso_grid = p_iso_grid


func show_preview(cells: Array[Vector2i], is_valid: bool) -> void:
	if preview_root == null or iso_grid == null:
		return
	clear_preview()
	var color: Color = VT.PLACEMENT_VALID if is_valid else VT.PLACEMENT_INVALID
	for cell: Vector2i in cells:
		if not iso_grid.is_valid_cell(cell):
			continue
		var tile: Polygon2D = create_preview_tile(cell, color)
		preview_root.add_child(tile)
		current_nodes.append(tile)


func hide_preview() -> void:
	clear_preview()


func clear_preview() -> void:
	for node: Node2D in current_nodes:
		if node == null:
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.queue_free()
	current_nodes.clear()


func create_preview_tile(cell: Vector2i, color: Color) -> Polygon2D:
	var tile: Polygon2D = Polygon2D.new()
	tile.polygon = iso_grid.get_iso_diamond_polygon()
	tile.position = iso_grid.grid_to_iso(cell)
	tile.color = color
	tile.z_index = iso_grid.get_draw_z_index(cell) + 4
	tile.z_as_relative = false
	return tile
