extends RefCounted
class_name RoomData

var id: String
var display_name: String
var width: int
var height: int
var player_start_cell: Vector2i
var furniture_items: Array[FurnitureData]


func _init(
	p_id: String,
	p_display_name: String,
	p_width: int,
	p_height: int,
	p_player_start_cell: Vector2i,
	p_furniture_items: Array[FurnitureData] = []
) -> void:
	id = p_id
	display_name = p_display_name
	width = p_width
	height = p_height
	player_start_cell = p_player_start_cell
	furniture_items = []

	for furniture: FurnitureData in p_furniture_items:
		furniture_items.append(furniture.duplicate_data())


func duplicate_data() -> RoomData:
	return RoomData.new(
		id,
		display_name,
		width,
		height,
		player_start_cell,
		furniture_items
	)


func get_furniture_items_copy() -> Array[FurnitureData]:
	var copied_items: Array[FurnitureData] = []

	for furniture: FurnitureData in furniture_items:
		copied_items.append(furniture.duplicate_data())

	return copied_items
