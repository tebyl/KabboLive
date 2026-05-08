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
var selected_furniture_index = -1
var is_move_mode = false


func _init(
	p_iso_grid,
	p_pathfinding_manager,
	p_player_controller,
	p_visual_factory,
	initial_items: Array
) :
	iso_grid = p_iso_grid
	pathfinding_manager = p_pathfinding_manager
	player_controller = p_player_controller
	visual_factory = p_visual_factory
	furniture_items = []

	for item in initial_items:
		if item is RefCounted and item.has_method("get_script"):
			furniture_items.append(item.get_script().new(item.cell, item.type, item.size))
		else:
			furniture_items.append(item)

	rebuild_solids()
	redraw()


func get_furniture_items():
	var copied_items = []

	for furniture in furniture_items:
		if furniture is RefCounted and furniture.has_method("get_script"):
			copied_items.append(furniture.get_script().new(furniture.cell, furniture.type, furniture.size))
		else:
			copied_items.append(furniture)

	return copied_items


func get_blocked_cells() -> Array[Vector2i]:
	var blocked_cells: Array[Vector2i] = []

	for furniture in furniture_items:
		for cell in furniture.get_occupied_cells():
			blocked_cells.append(cell)

	return blocked_cells


func redraw() :
	iso_grid.redraw_tiles(get_blocked_cells())
	visual_factory.redraw(furniture_items, selected_furniture_index)


func rebuild_solids() :
	pathfinding_manager.clear_all_solids(iso_grid.grid_width, iso_grid.grid_height)

	for furniture in furniture_items:
		pathfinding_manager.mark_furniture_solid(furniture, true)


func clear_selection() :
	selected_furniture_index = -1
	is_move_mode = false
	redraw()


func has_selected_placed_furniture() :
	return selected_furniture_index >= 0 and selected_furniture_index < furniture_items.size()


func get_selected_furniture():
	if not has_selected_placed_furniture():
		return null
	return furniture_items[selected_furniture_index]


func select_furniture_at_cell(cell) :
	var furniture_index = get_furniture_index_at_cell(cell)

	if furniture_index == -1:
		return false

	selected_furniture_index = furniture_index
	is_move_mode = false
	redraw()
	return true


func get_selected_cell() -> Vector2i:
	if not has_selected_placed_furniture():
		return Vector2i(-1, -1)

	return furniture_items[selected_furniture_index].cell


func get_furniture_index_at_cell(cell) :
	for index in range(furniture_items.size()):
		var furniture = furniture_items[index]

		if furniture.get_occupied_cells().has(cell):
			return index

	return -1


func place_furniture(furniture) :
	if not can_place_furniture(furniture, -1):
		return false

	furniture_items.append(furniture)
	pathfinding_manager.mark_furniture_solid(furniture, true)
	redraw()
	return true


func delete_selected_furniture() :
	if not has_selected_placed_furniture():
		return false

	var furniture = furniture_items[selected_furniture_index]
	pathfinding_manager.mark_furniture_solid(furniture, false)
	furniture_items.remove_at(selected_furniture_index)
	selected_furniture_index = -1
	is_move_mode = false
	redraw()
	return true


func start_move_selected_furniture() :
	if not has_selected_placed_furniture():
		return false

	is_move_mode = true
	return true


func is_move_mode_active() :
	return is_move_mode


func move_selected_furniture(target_cell) :
	if not has_selected_placed_furniture():
		is_move_mode = false
		return false

	var furniture = furniture_items[selected_furniture_index]
	var moved_furniture = furniture.get_script().new(target_cell, furniture.type, furniture.size)

	if not can_place_furniture(moved_furniture, selected_furniture_index):
		return false

	pathfinding_manager.mark_furniture_solid(furniture, false)
	furniture.cell = target_cell
	pathfinding_manager.mark_furniture_solid(furniture, true)
	is_move_mode = false
	redraw()
	return true


func rotate_selected_furniture() :
	if not has_selected_placed_furniture():
		return false

	var furniture = furniture_items[selected_furniture_index]
	var rotated_size = Vector2i(furniture.size.y, furniture.size.x)
	var rotated_furniture = furniture.get_script().new(furniture.cell, furniture.type, rotated_size)

	if not can_place_furniture(rotated_furniture, selected_furniture_index):
		return false

	pathfinding_manager.mark_furniture_solid(furniture, false)
	furniture.size = rotated_size
	pathfinding_manager.mark_furniture_solid(furniture, true)
	redraw()
	return true


func replace_furniture_items(items, warning_callback: Callable) :
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


func can_place_furniture(furniture, ignored_furniture_index) :
	if furniture.size.x <= 0 or furniture.size.y <= 0:
		return false

	for cell in furniture.get_occupied_cells():
		if not iso_grid.is_valid_cell(cell):
			return false

		var blocking_furniture_index = get_furniture_index_at_cell(cell)

		if blocking_furniture_index != -1 and blocking_furniture_index != ignored_furniture_index:
			return false

		if cell == player_controller.get_player_cell():
			return false

		if pathfinding_manager.is_point_solid(cell) and blocking_furniture_index != ignored_furniture_index:
			return false

	return true
