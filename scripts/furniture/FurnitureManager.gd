extends RefCounted
class_name FurnitureManager

var iso_grid: IsoGrid
var pathfinding_manager: PathfindingManager
var player_controller: PlayerController
var visual_factory: FurnitureVisualFactory
var furniture_items: Array[FurnitureData]
var selected_furniture_index: int = -1
var is_move_mode: bool = false


func _init(
	p_iso_grid: IsoGrid,
	p_pathfinding_manager: PathfindingManager,
	p_player_controller: PlayerController,
	p_visual_factory: FurnitureVisualFactory,
	initial_items: Array[FurnitureData]
) -> void:
	iso_grid = p_iso_grid
	pathfinding_manager = p_pathfinding_manager
	player_controller = p_player_controller
	visual_factory = p_visual_factory
	furniture_items = []

	for item: FurnitureData in initial_items:
		furniture_items.append(item.duplicate_data())

	rebuild_solids()
	redraw()


func get_furniture_items() -> Array[FurnitureData]:
	var copied_items: Array[FurnitureData] = []

	for furniture: FurnitureData in furniture_items:
		copied_items.append(furniture.duplicate_data())

	return copied_items


func get_blocked_cells() -> Array[Vector2i]:
	var blocked_cells: Array[Vector2i] = []

	for furniture: FurnitureData in furniture_items:
		for cell: Vector2i in furniture.get_occupied_cells():
			blocked_cells.append(cell)

	return blocked_cells


func redraw() -> void:
	iso_grid.redraw_tiles(get_blocked_cells())
	visual_factory.redraw(furniture_items, selected_furniture_index)


func rebuild_solids() -> void:
	pathfinding_manager.clear_all_solids(iso_grid.grid_width, iso_grid.grid_height)

	for furniture: FurnitureData in furniture_items:
		pathfinding_manager.mark_furniture_solid(furniture, true)


func clear_selection() -> void:
	selected_furniture_index = -1
	is_move_mode = false
	redraw()


func has_selected_placed_furniture() -> bool:
	return selected_furniture_index >= 0 and selected_furniture_index < furniture_items.size()


func select_furniture_at_cell(cell: Vector2i) -> bool:
	var furniture_index: int = get_furniture_index_at_cell(cell)

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


func get_furniture_index_at_cell(cell: Vector2i) -> int:
	for index: int in range(furniture_items.size()):
		var furniture: FurnitureData = furniture_items[index]

		if furniture.get_occupied_cells().has(cell):
			return index

	return -1


func place_furniture(furniture: FurnitureData) -> bool:
	if not can_place_furniture(furniture, -1):
		return false

	furniture_items.append(furniture)
	pathfinding_manager.mark_furniture_solid(furniture, true)
	redraw()
	return true


func delete_selected_furniture() -> bool:
	if not has_selected_placed_furniture():
		return false

	var furniture: FurnitureData = furniture_items[selected_furniture_index]
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


func is_move_mode_active() -> bool:
	return is_move_mode


func move_selected_furniture(target_cell: Vector2i) -> bool:
	if not has_selected_placed_furniture():
		is_move_mode = false
		return false

	var furniture: FurnitureData = furniture_items[selected_furniture_index]
	var moved_furniture: FurnitureData = FurnitureData.new(target_cell, furniture.type, furniture.size)

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

	var furniture: FurnitureData = furniture_items[selected_furniture_index]
	var rotated_size: Vector2i = Vector2i(furniture.size.y, furniture.size.x)
	var rotated_furniture: FurnitureData = FurnitureData.new(furniture.cell, furniture.type, rotated_size)

	if not can_place_furniture(rotated_furniture, selected_furniture_index):
		return false

	pathfinding_manager.mark_furniture_solid(furniture, false)
	furniture.size = rotated_size
	pathfinding_manager.mark_furniture_solid(furniture, true)
	redraw()
	return true


func replace_furniture_items(items: Array[FurnitureData], warning_callback: Callable) -> void:
	selected_furniture_index = -1
	is_move_mode = false
	furniture_items.clear()
	pathfinding_manager.clear_all_solids(iso_grid.grid_width, iso_grid.grid_height)

	for furniture: FurnitureData in items:
		if not can_place_furniture(furniture, -1):
			warning_callback.call("Advertencia: mueble invalido saltado")
			continue

		furniture_items.append(furniture)
		pathfinding_manager.mark_furniture_solid(furniture, true)

	redraw()


func can_place_furniture(furniture: FurnitureData, ignored_furniture_index: int) -> bool:
	if furniture.size.x <= 0 or furniture.size.y <= 0:
		return false

	for cell: Vector2i in furniture.get_occupied_cells():
		if not iso_grid.is_valid_cell(cell):
			return false

		var blocking_furniture_index: int = get_furniture_index_at_cell(cell)

		if blocking_furniture_index != -1 and blocking_furniture_index != ignored_furniture_index:
			return false

		if cell == player_controller.get_player_cell():
			return false

		if pathfinding_manager.is_point_solid(cell) and blocking_furniture_index != ignored_furniture_index:
			return false

	return true
