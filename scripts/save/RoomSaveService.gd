extends RefCounted

const RoomDataScript = preload("res://scripts/room/RoomData.gd")
const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const RoomData = RoomDataScript
const FurnitureData = FurnitureDataScript

const ROOMS_SAVE_PATH = "user://rooms_save.json"
const LEGACY_ROOM_SAVE_PATH = "user://room_save.json"


func save_rooms(rooms: Array) :
	var rooms_data: Array[Dictionary] = []

	for room in rooms:
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

	var json_text = file.get_as_text()
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

	var loaded_rooms = []
	var rooms_data: Array = rooms_data_variant as Array

	for room_variant: Variant in rooms_data:
		if not room_variant is Dictionary:
			warning_callback.call("Advertencia: sala invalida saltada")
			continue

		var room_data: Dictionary = room_variant as Dictionary
		var room = create_room_from_save_data(room_data, warning_callback)

		if room != null:
			loaded_rooms.append(room)

	return {
		"status": &"ok",
		"rooms": loaded_rooms
	}


func create_room_from_save_data(room_data: Dictionary, warning_callback: Callable):
	var room_id = String(room_data.get("id", ""))
	var display_name = String(room_data.get("display_name", ""))
	var width = int(room_data.get("width", 0))
	var height = int(room_data.get("height", 0))
	var start_cell_variant: Variant = room_data.get("player_start_cell", {})
	var furniture_data_variant: Variant = room_data.get("furniture", [])

	if room_id.is_empty() or width <= 0 or height <= 0:
		return null

	if not start_cell_variant is Dictionary or not furniture_data_variant is Array:
		return null

	var start_cell_data: Dictionary = start_cell_variant as Dictionary
	var player_start_cell = Vector2i(
		int(start_cell_data.get("x", -1)),
		int(start_cell_data.get("y", -1))
	)

	if player_start_cell.x < 0 or player_start_cell.x >= width or player_start_cell.y < 0 or player_start_cell.y >= height:
		return null

	var room = RoomDataScript.new(room_id, display_name, width, height, player_start_cell)
	var furniture_data: Array = furniture_data_variant as Array

	for item_variant: Variant in furniture_data:
		if not item_variant is Dictionary:
			warning_callback.call("Advertencia: mueble invalido saltado")
			continue

		var item_data: Dictionary = item_variant as Dictionary
		var furniture = create_furniture_from_save_data(item_data)

		if not is_save_furniture_valid(furniture):
			warning_callback.call("Advertencia: mueble invalido saltado")
			continue

		if not is_room_furniture_valid(room, furniture):
			warning_callback.call("Advertencia: mueble invalido saltado")
			continue

		room.furniture_items.append(furniture)

	return room


func get_furniture_save_items(furniture_items) -> Array[Dictionary]:
	var save_items: Array[Dictionary] = []

	for furniture in furniture_items:
		var save_item: Dictionary = {
			"type": str(furniture.type),
			"cell": {"x": furniture.cell.x, "y": furniture.cell.y},
			"size": {"x": furniture.size.x, "y": furniture.size.y},
			"blocks_movement": furniture.blocks_movement,
			"layer": str(furniture.layer)
		}
		save_items.append(save_item)

	return save_items


func create_furniture_from_save_data(item_data: Dictionary):
	var type_text = String(item_data.get("type", ""))
	var cell_data_variant: Variant = item_data.get("cell", {})
	var size_data_variant: Variant = item_data.get("size", {})

	if not cell_data_variant is Dictionary or not size_data_variant is Dictionary:
		return FurnitureDataScript.new(Vector2i(-1, -1), &"", Vector2i.ZERO)

	var cell_data: Dictionary = cell_data_variant as Dictionary
	var size_data: Dictionary = size_data_variant as Dictionary
	var cell = Vector2i(
		int(cell_data.get("x", -1)),
		int(cell_data.get("y", -1))
	)
	var size = Vector2i(
		int(size_data.get("x", 0)),
		int(size_data.get("y", 0))
	)

	var f: RefCounted = FurnitureDataScript.new(cell, StringName(type_text), size)
	if item_data.has("blocks_movement"):
		f.blocks_movement = bool(item_data["blocks_movement"])
	else:
		f.blocks_movement = type_text != "rug"
	if item_data.has("layer"):
		f.layer = str(item_data["layer"])
	else:
		if type_text == "rug":
			f.layer = "floor"
		elif type_text == "plant":
			f.layer = "decor"
		else:
			f.layer = "furniture"
	return f


func is_save_furniture_valid(furniture) :
	return (
		furniture.type != &""
		and furniture.size.x > 0
		and furniture.size.y > 0
	)


func is_room_furniture_valid(room, furniture) :
	for cell in furniture.get_occupied_cells():
		if cell.x < 0 or cell.x >= room.width or cell.y < 0 or cell.y >= room.height:
			return false

		if cell == room.player_start_cell:
			return false

		for existing_furniture in room.furniture_items:
			if existing_furniture.get_occupied_cells().has(cell):
				return false

	return true
