extends RefCounted
class_name RoomSaveService

const ROOMS_SAVE_PATH: String = "user://rooms_save.json"
const LEGACY_ROOM_SAVE_PATH: String = "user://room_save.json"


func save_rooms(rooms: Array[RoomData]) -> bool:
	var rooms_data: Array[Dictionary] = []

	for room: RoomData in rooms:
		rooms_data.append({
			"id": room.id,
			"display_name": room.display_name,
			"width": room.width,
			"height": room.height,
			"player_start_cell": {
				"x": room.player_start_cell.x,
				"y": room.player_start_cell.y
			},
			"furniture": get_furniture_save_items(room.furniture_items)
		})

	var save_data: Dictionary = {
		"rooms": rooms_data
	}
	var file: FileAccess = FileAccess.open(ROOMS_SAVE_PATH, FileAccess.WRITE)

	if file == null:
		return false

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	return true


func load_rooms(warning_callback: Callable) -> Dictionary:
	if not FileAccess.file_exists(ROOMS_SAVE_PATH):
		if FileAccess.file_exists(LEGACY_ROOM_SAVE_PATH):
			return {
				"status": &"legacy_missing_migration",
				"rooms": []
			}

		return {
			"status": &"missing",
			"rooms": []
		}

	var file: FileAccess = FileAccess.open(ROOMS_SAVE_PATH, FileAccess.READ)

	if file == null:
		return {
			"status": &"missing",
			"rooms": []
		}

	var json_text: String = file.get_as_text()
	file.close()

	var parsed_data: Variant = JSON.parse_string(json_text)

	if not parsed_data is Dictionary:
		return {
			"status": &"invalid_file",
			"rooms": []
		}

	var save_data: Dictionary = parsed_data as Dictionary
	var rooms_data_variant: Variant = save_data.get("rooms", [])

	if not rooms_data_variant is Array:
		return {
			"status": &"invalid_file",
			"rooms": []
		}

	var loaded_rooms: Array[RoomData] = []
	var rooms_data: Array = rooms_data_variant as Array

	for room_variant: Variant in rooms_data:
		if not room_variant is Dictionary:
			warning_callback.call("Advertencia: sala invalida saltada")
			continue

		var room_data: Dictionary = room_variant as Dictionary
		var room: RoomData = create_room_from_save_data(room_data, warning_callback)

		if room != null:
			loaded_rooms.append(room)

	return {
		"status": &"ok",
		"rooms": loaded_rooms
	}


func create_room_from_save_data(room_data: Dictionary, warning_callback: Callable) -> RoomData:
	var room_id: String = String(room_data.get("id", ""))
	var display_name: String = String(room_data.get("display_name", ""))
	var width: int = int(room_data.get("width", 0))
	var height: int = int(room_data.get("height", 0))
	var start_cell_variant: Variant = room_data.get("player_start_cell", {})
	var furniture_data_variant: Variant = room_data.get("furniture", [])

	if room_id.is_empty() or width <= 0 or height <= 0:
		return null

	if not start_cell_variant is Dictionary or not furniture_data_variant is Array:
		return null

	var start_cell_data: Dictionary = start_cell_variant as Dictionary
	var player_start_cell: Vector2i = Vector2i(
		int(start_cell_data.get("x", -1)),
		int(start_cell_data.get("y", -1))
	)

	if player_start_cell.x < 0 or player_start_cell.x >= width or player_start_cell.y < 0 or player_start_cell.y >= height:
		return null

	var room: RoomData = RoomData.new(room_id, display_name, width, height, player_start_cell)
	var furniture_data: Array = furniture_data_variant as Array

	for item_variant: Variant in furniture_data:
		if not item_variant is Dictionary:
			warning_callback.call("Advertencia: mueble invalido saltado")
			continue

		var item_data: Dictionary = item_variant as Dictionary
		var furniture: FurnitureData = create_furniture_from_save_data(item_data)

		if not is_save_furniture_valid(furniture):
			warning_callback.call("Advertencia: mueble invalido saltado")
			continue

		if not is_room_furniture_valid(room, furniture):
			warning_callback.call("Advertencia: mueble invalido saltado")
			continue

		room.furniture_items.append(furniture)

	return room


func get_furniture_save_items(furniture_items: Array[FurnitureData]) -> Array[Dictionary]:
	var save_items: Array[Dictionary] = []

	for furniture: FurnitureData in furniture_items:
		var save_item: Dictionary = {
			"type": str(furniture.type),
			"cell": {
				"x": furniture.cell.x,
				"y": furniture.cell.y
			},
			"size": {
				"x": furniture.size.x,
				"y": furniture.size.y
			}
		}
		save_items.append(save_item)

	return save_items


func create_furniture_from_save_data(item_data: Dictionary) -> FurnitureData:
	var type_text: String = String(item_data.get("type", ""))
	var cell_data_variant: Variant = item_data.get("cell", {})
	var size_data_variant: Variant = item_data.get("size", {})

	if not cell_data_variant is Dictionary or not size_data_variant is Dictionary:
		return FurnitureData.new(Vector2i(-1, -1), &"", Vector2i.ZERO)

	var cell_data: Dictionary = cell_data_variant as Dictionary
	var size_data: Dictionary = size_data_variant as Dictionary
	var cell: Vector2i = Vector2i(
		int(cell_data.get("x", -1)),
		int(cell_data.get("y", -1))
	)
	var size: Vector2i = Vector2i(
		int(size_data.get("x", 0)),
		int(size_data.get("y", 0))
	)

	return FurnitureData.new(cell, StringName(type_text), size)


func is_save_furniture_valid(furniture: FurnitureData) -> bool:
	return (
		furniture.type != &""
		and furniture.size.x > 0
		and furniture.size.y > 0
	)


func is_room_furniture_valid(room: RoomData, furniture: FurnitureData) -> bool:
	for cell: Vector2i in furniture.get_occupied_cells():
		if cell.x < 0 or cell.x >= room.width or cell.y < 0 or cell.y >= room.height:
			return false

		if cell == room.player_start_cell:
			return false

		for existing_furniture: FurnitureData in room.furniture_items:
			if existing_furniture.get_occupied_cells().has(cell):
				return false

	return true
