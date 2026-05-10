extends RefCounted


var cell
var type
var size
var blocks_movement: bool = true
var layer: String = "furniture"

const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const FurnitureData = FurnitureDataScript
const DEFAULT_SIZES := {
	"chair": Vector2i(1, 1),
	"lounge_chair": Vector2i(1, 1),
	"plant": Vector2i(1, 1),
	"big_plant": Vector2i(1, 1),
	"golden_plant": Vector2i(1, 1),
	"lamp": Vector2i(1, 1),
	"poster": Vector2i(1, 1),
	"floor_tile": Vector2i(1, 1),
	"sofa": Vector2i(2, 1),
	"table": Vector2i(2, 1),
	"desk": Vector2i(2, 1),
	"bookshelf": Vector2i(1, 2),
	"bed": Vector2i(2, 2),
	"rug": Vector2i(2, 2),
	"red_rug": Vector2i(2, 2),
	"blue_rug": Vector2i(2, 2),
}


func _init(p_cell, p_type_name, p_size) -> void:
	cell = p_cell
	type = p_type_name
	var t: String = String(p_type_name)
	size = _sanitize_size(t, p_size)
	if t == "rug" or t == "blue_rug" or t == "red_rug" or t == "floor_tile":
		blocks_movement = false
		layer = "floor"
	elif t == "poster":
		blocks_movement = false
		layer = "decor"
	elif t == "plant" or t == "golden_plant" or t == "lamp" or t == "bookshelf" or t == "big_plant":
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


func _sanitize_size(furniture_type: String, requested_size: Variant) -> Vector2i:
	if requested_size is Vector2i and requested_size.x > 0 and requested_size.y > 0:
		return requested_size
	return DEFAULT_SIZES.get(furniture_type, Vector2i(1, 1)) as Vector2i
