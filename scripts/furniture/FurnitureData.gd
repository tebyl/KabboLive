extends RefCounted
class_name FurnitureData

var cell: Vector2i
var type: StringName
var size: Vector2i


func _init(p_cell: Vector2i, p_type: StringName, p_size: Vector2i) -> void:
	cell = p_cell
	type = p_type
	size = p_size


func duplicate_data() -> FurnitureData:
	return FurnitureData.new(cell, type, size)


func get_occupied_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []

	for x: int in range(size.x):
		for y: int in range(size.y):
			cells.append(cell + Vector2i(x, y))

	return cells
