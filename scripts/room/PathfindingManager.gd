extends RefCounted


var astar: AStarGrid2D = AStarGrid2D.new()
const IsoGridScript = preload("res://scripts/room/IsoGrid.gd")
const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const RoomDataScript = preload("res://scripts/room/RoomData.gd")

const IsoGrid = IsoGridScript
const FurnitureData = FurnitureDataScript
const RoomData = RoomDataScript
var tile_width
var tile_height


func _init(grid_width, grid_height, p_tile_width, p_tile_height) :
	self.tile_width = p_tile_width
	self.tile_height = p_tile_height
	reconfigure_grid(grid_width, grid_height)


func reconfigure_grid(grid_width, grid_height) :
	astar.region = Rect2i(0, 0, grid_width, grid_height)
	astar.cell_size = Vector2(float(tile_width), float(tile_height))
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()


func get_path(from_cell, target_cell) -> Array[Vector2i]:
	return astar.get_id_path(from_cell, target_cell)


func is_point_solid(cell) :
	return astar.is_point_solid(cell)


func set_point_solid(cell, is_solid) :
	astar.set_point_solid(cell, is_solid)


func mark_furniture_solid(furniture, is_solid: bool) -> void:
	var bm: Variant = furniture.get("blocks_movement")
	if bm != null and not bool(bm):
		return
	for cell: Vector2i in furniture.get_occupied_cells():
		astar.set_point_solid(cell, is_solid)


func clear_all_solids(grid_width, grid_height) :
	for x in range(grid_width):
		for y in range(grid_height):
			astar.set_point_solid(Vector2i(x, y), false)
