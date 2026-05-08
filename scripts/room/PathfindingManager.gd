extends RefCounted
class_name PathfindingManager

var astar: AStarGrid2D = AStarGrid2D.new()
var tile_width: int
var tile_height: int


func _init(grid_width: int, grid_height: int, tile_width: int, tile_height: int) -> void:
	self.tile_width = tile_width
	self.tile_height = tile_height
	reconfigure_grid(grid_width, grid_height)


func reconfigure_grid(grid_width: int, grid_height: int) -> void:
	astar.region = Rect2i(0, 0, grid_width, grid_height)
	astar.cell_size = Vector2(float(tile_width), float(tile_height))
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()


func get_path(from_cell: Vector2i, target_cell: Vector2i) -> Array[Vector2i]:
	return astar.get_id_path(from_cell, target_cell)


func is_point_solid(cell: Vector2i) -> bool:
	return astar.is_point_solid(cell)


func set_point_solid(cell: Vector2i, is_solid: bool) -> void:
	astar.set_point_solid(cell, is_solid)


func mark_furniture_solid(furniture: FurnitureData, is_solid: bool) -> void:
	for cell: Vector2i in furniture.get_occupied_cells():
		astar.set_point_solid(cell, is_solid)


func clear_all_solids(grid_width: int, grid_height: int) -> void:
	for x: int in range(grid_width):
		for y: int in range(grid_height):
			astar.set_point_solid(Vector2i(x, y), false)
