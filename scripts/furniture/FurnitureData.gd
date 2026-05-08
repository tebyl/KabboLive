extends RefCounted


var cell
var type
var size

const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const FurnitureData = FurnitureDataScript


func _init(p_cell, p_typeName, p_size) :
	cell = p_cell
	type = p_typeName
	size = p_size


func duplicate_data():
	return get_script().new(cell, type, size)


func get_occupied_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []

	for x in range(size.x):
		for y in range(size.y):
			cells.append(cell + Vector2i(x, y))

	return cells
