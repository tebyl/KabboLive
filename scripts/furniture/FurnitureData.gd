extends RefCounted


var cell
var type
var size
var blocks_movement: bool = true
var layer: String = "furniture"

const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const FurnitureData = FurnitureDataScript


func _init(p_cell, p_type_name, p_size) -> void:
	cell = p_cell
	type = p_type_name
	size = p_size
	var t: String = String(p_type_name)
	if t == "rug" or t == "blue_rug":
		blocks_movement = false
		layer = "floor"
	elif t == "plant" or t == "golden_plant":
		blocks_movement = true
		layer = "decor"
	else:
		blocks_movement = true
		layer = "furniture"


func duplicate_data() -> RefCounted:
	var copy: RefCounted = get_script().new(cell, type, size)
	copy.blocks_movement = blocks_movement
	copy.layer = layer
	return copy


func get_occupied_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x: int in range(size.x):
		for y: int in range(size.y):
			cells.append(cell + Vector2i(x, y))
	return cells
