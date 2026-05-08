extends RefCounted

const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const FurnitureData = FurnitureDataScript
const PathfindingManagerScript = preload("res://scripts/room/PathfindingManager.gd")
const IsoGridScript = preload("res://scripts/room/IsoGrid.gd")
const VisualFactoryScript = preload("res://scripts/furniture/FurnitureVisualFactory.gd")

var iso_grid
var pathfinding_manager
var player_controller
var visual_factory
var furniture_items: Array[RefCounted] = []
var selected_furniture_index: int = -1
var is_move_mode: bool = false


func _init(
	p_iso_grid,
	p_pathfinding_manager,
	p_player_controller,
	p_visual_factory,
	initial_items: Array
) -> void:
	iso_grid = p_iso_grid
	pathfinding_manager = p_pathfinding_manager
	player_controller = p_player_controller
	visual_factory = p_visual_factory
	furniture_items = []

	for item in initial_items:
		if item is RefCounted and item.has_method("duplicate_data"):
			furniture_items.append(item.duplicate_data())
		else:
			furniture_items.append(item)

	rebuild_solids()
	redraw()


func get_furniture_items() -> Array:
	var copied_items: Array = []
	for furniture in furniture_items:
		if furniture is RefCounted and furniture.has_method("duplicate_data"):
			copied_items.append(furniture.duplicate_data())
		else:
			copied_items.append(furniture)
	return copied_items


func get_blocked_cells() -> Array[Vector2i]:
	var blocked_cells: Array[Vector2i] = []
	for furniture in furniture_items:
		if _get_layer(furniture) == "floor":
			continue
		for cell: Vector2i in furniture.get_occupied_cells():
			blocked_cells.append(cell)
	return blocked_cells


func redraw() -> void:
	iso_grid.redraw_tiles(get_blocked_cells())
	visual_factory.redraw(furniture_items, selected_furniture_index)


func rebuild_solids() -> void:
	pathfinding_manager.clear_all_solids(iso_grid.grid_width, iso_grid.grid_height)
	for furniture in furniture_items:
		pathfinding_manager.mark_furniture_solid(furniture, true)


func clear_selection() -> void:
	selected_furniture_index = -1
	is_move_mode = false
	redraw()


func has_selected_placed_furniture() -> bool:
	return selected_furniture_index >= 0 and selected_furniture_index < furniture_items.size()


func get_selected_furniture() -> RefCounted:
	if not has_selected_placed_furniture():
		return null
	return furniture_items[selected_furniture_index]


func get_selected_furniture_index() -> int:
	return selected_furniture_index


func get_furniture_items_at_cell(cell: Vector2i) -> Array:
	var found: Array = []
	for f: RefCounted in furniture_items:
		if f.get_occupied_cells().has(cell):
			found.append(f)
	found.sort_custom(func(a: RefCounted, b: RefCounted) -> bool:
		return _layer_priority(_get_layer(a)) > _layer_priority(_get_layer(b))
	)
	return found


func select_furniture_item(furniture: RefCounted) -> void:
	for i: int in range(furniture_items.size()):
		if furniture_items[i] == furniture:
			selected_furniture_index = i
			is_move_mode = false
			redraw()
			return


func select_furniture_at_cell(cell: Vector2i) -> bool:
	var best_index: int = -1
	var best_priority: int = -1
	for i: int in range(furniture_items.size()):
		var f: RefCounted = furniture_items[i]
		if not f.get_occupied_cells().has(cell):
			continue
		var p: int = _layer_priority(_get_layer(f))
		if p > best_priority:
			best_priority = p
			best_index = i
	if best_index == -1:
		return false
	selected_furniture_index = best_index
	is_move_mode = false
	redraw()
	return true


func get_selected_cell() -> Vector2i:
	if not has_selected_placed_furniture():
		return Vector2i(-1, -1)
	return furniture_items[selected_furniture_index].cell


func place_furniture(furniture: RefCounted) -> bool:
	if not can_place_furniture(furniture, -1):
		return false
	furniture_items.append(furniture)
	pathfinding_manager.mark_furniture_solid(furniture, true)
	redraw()
	if visual_factory != null and visual_factory.has_method("play_place_pop"):
		visual_factory.play_place_pop(furniture)
	return true


func delete_selected_furniture() -> bool:
	if not has_selected_placed_furniture():
		return false
	var furniture: RefCounted = furniture_items[selected_furniture_index]
	pathfinding_manager.mark_furniture_solid(furniture, false)
	furniture_items.remove_at(selected_furniture_index)
	selected_furniture_index = -1
	is_move_mode = false
	redraw()
	return true


func start_move_selected_furniture() -> bool:
	if not has_selected_placed_furniture():
		return false
	is_move_mode = true
	return true


func cancel_move_mode() -> void:
	is_move_mode = false
	redraw()


func is_move_mode_active() -> bool:
	return is_move_mode


func can_move_selected_furniture_to(target_cell: Vector2i) -> bool:
	if not has_selected_placed_furniture():
		return false
	var furniture: RefCounted = furniture_items[selected_furniture_index]
	var moved_furniture: RefCounted = _make_moved_furniture(furniture, target_cell)
	return can_place_furniture(moved_furniture, selected_furniture_index)


func create_selected_move_preview(target_cell: Vector2i) -> RefCounted:
	if not has_selected_placed_furniture():
		return null
	return _make_moved_furniture(furniture_items[selected_furniture_index], target_cell)


func move_selected_furniture(target_cell: Vector2i) -> bool:
	if not has_selected_placed_furniture():
		is_move_mode = false
		return false
	var furniture: RefCounted = furniture_items[selected_furniture_index]
	var moved_furniture: RefCounted = _make_moved_furniture(furniture, target_cell)
	if not can_place_furniture(moved_furniture, selected_furniture_index):
		return false
	pathfinding_manager.mark_furniture_solid(furniture, false)
	furniture.cell = target_cell
	pathfinding_manager.mark_furniture_solid(furniture, true)
	is_move_mode = false
	redraw()
	return true


func rotate_selected_furniture() -> bool:
	if not has_selected_placed_furniture():
		return false
	var furniture: RefCounted = furniture_items[selected_furniture_index]
	var rotated_size: Vector2i = Vector2i(furniture.size.y, furniture.size.x)
	var rotated_furniture: RefCounted = furniture.get_script().new(furniture.cell, furniture.type, rotated_size)
	rotated_furniture.blocks_movement = furniture.blocks_movement
	rotated_furniture.layer = furniture.layer
	if not can_place_furniture(rotated_furniture, selected_furniture_index):
		return false
	pathfinding_manager.mark_furniture_solid(furniture, false)
	furniture.size = rotated_size
	pathfinding_manager.mark_furniture_solid(furniture, true)
	redraw()
	return true


func replace_furniture_items(items: Array, warning_callback: Callable) -> void:
	selected_furniture_index = -1
	is_move_mode = false
	furniture_items.clear()
	pathfinding_manager.clear_all_solids(iso_grid.grid_width, iso_grid.grid_height)

	for furniture in items:
		if not can_place_furniture(furniture, -1):
			warning_callback.call("Advertencia: mueble invalido saltado")
			continue
		furniture_items.append(furniture)
		pathfinding_manager.mark_furniture_solid(furniture, true)

	redraw()


func can_place_furniture(furniture: RefCounted, ignored_index: int) -> bool:
	if furniture.size.x <= 0 or furniture.size.y <= 0:
		return false

	var incoming_layer: String = _get_layer(furniture)
	var ignored_cells: Array[Vector2i] = []
	if ignored_index >= 0 and ignored_index < furniture_items.size():
		ignored_cells = furniture_items[ignored_index].get_occupied_cells()

	for cell: Vector2i in furniture.get_occupied_cells():
		if not iso_grid.is_valid_cell(cell):
			return false

		# Player cell: only block furniture/decor, not floor items
		if incoming_layer != "floor" and cell == player_controller.get_player_cell():
			return false

		# Check all existing furniture at this cell
		var cell_has_blocking_furniture: bool = false
		for i: int in range(furniture_items.size()):
			if i == ignored_index:
				continue
			var existing: RefCounted = furniture_items[i]
			if not existing.get_occupied_cells().has(cell):
				continue
			var existing_layer: String = _get_layer(existing)
			if not _layers_can_overlap(existing_layer, incoming_layer):
				return false
			var bm: Variant = existing.get("blocks_movement")
			if bm == null or bool(bm):
				cell_has_blocking_furniture = true

		# For non-floor: check pathfinding solid (catches NPC, etc.)
		# Only when no furniture at cell explains the solid (e.g. NPC is sole reason)
		if incoming_layer != "floor" and not cell_has_blocking_furniture:
			if pathfinding_manager.is_point_solid(cell) and not ignored_cells.has(cell):
				return false

	return true


func _make_moved_furniture(furniture: RefCounted, target_cell: Vector2i) -> RefCounted:
	var moved_furniture: RefCounted = furniture.get_script().new(target_cell, furniture.type, furniture.size)
	moved_furniture.blocks_movement = furniture.blocks_movement
	moved_furniture.layer = furniture.layer
	return moved_furniture


func _get_layer(furniture: RefCounted) -> String:
	var l: Variant = furniture.get("layer")
	if l != null and str(l) != "":
		return str(l)
	var t: String = str(furniture.get("type"))
	if t == "rug" or t == "blue_rug": return "floor"
	if t == "plant" or t == "golden_plant": return "decor"
	return "furniture"


func _layer_priority(layer: String) -> int:
	match layer:
		"decor": return 3
		"furniture": return 2
		"floor": return 1
	return 2


func _layers_can_overlap(layer_a: String, layer_b: String) -> bool:
	return (layer_a == "floor") != (layer_b == "floor")
