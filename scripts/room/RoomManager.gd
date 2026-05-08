extends RefCounted
class_name RoomManager

var rooms_by_id: Dictionary[String, RoomData] = {}
var room_order: Array[String] = []
var current_room_id: String = ""


func _init() -> void:
	register_initial_rooms()


func get_current_room() -> RoomData:
	return get_room_by_id(current_room_id)


func switch_room(room_id: String) -> bool:
	if not rooms_by_id.has(room_id):
		return false

	current_room_id = room_id
	return true


func get_current_room_name() -> String:
	var room: RoomData = get_current_room()

	if room == null:
		return ""

	return room.display_name


func get_current_room_size() -> Vector2i:
	var room: RoomData = get_current_room()

	if room == null:
		return Vector2i.ZERO

	return Vector2i(room.width, room.height)


func get_current_player_start_cell() -> Vector2i:
	var room: RoomData = get_current_room()

	if room == null:
		return Vector2i.ZERO

	return room.player_start_cell


func get_current_furniture_items() -> Array[FurnitureData]:
	var room: RoomData = get_current_room()

	if room == null:
		return []

	return room.get_furniture_items_copy()


func set_current_furniture_items(items: Array[FurnitureData]) -> void:
	set_room_furniture_items(current_room_id, items)


func get_all_rooms() -> Array[RoomData]:
	var rooms: Array[RoomData] = []

	for room_id: String in room_order:
		var room: RoomData = get_room_by_id(room_id)

		if room != null:
			rooms.append(room.duplicate_data())

	return rooms


func set_room_furniture_items(room_id: String, items: Array[FurnitureData]) -> void:
	var room: RoomData = get_room_by_id(room_id)

	if room == null:
		return

	room.furniture_items.clear()

	for furniture: FurnitureData in items:
		room.furniture_items.append(furniture.duplicate_data())


func apply_saved_rooms(saved_rooms: Array[RoomData]) -> void:
	for saved_room: RoomData in saved_rooms:
		var target_room: RoomData = get_room_by_id(saved_room.id)

		if target_room == null:
			continue

		target_room.furniture_items.clear()

		for furniture: FurnitureData in saved_room.furniture_items:
			target_room.furniture_items.append(furniture.duplicate_data())


func register_initial_rooms() -> void:
	register_room(
		RoomData.new(
			"lobby",
			"Lobby",
			10,
			10,
			Vector2i(1, 1),
			[
				FurnitureData.new(Vector2i(3, 3), &"chair", Vector2i(1, 1)),
				FurnitureData.new(Vector2i(3, 4), &"table", Vector2i(2, 1)),
				FurnitureData.new(Vector2i(6, 2), &"sofa", Vector2i(1, 2)),
				FurnitureData.new(Vector2i(7, 3), &"plant", Vector2i(1, 1))
			]
		)
	)
	register_room(
		RoomData.new(
			"room_small",
			"Sala pequeña",
			8,
			8,
			Vector2i(1, 1)
		)
	)
	register_room(
		RoomData.new(
			"room_large",
			"Sala grande",
			14,
			10,
			Vector2i(2, 2)
		)
	)
	current_room_id = "lobby"


func register_room(room: RoomData) -> void:
	rooms_by_id[room.id] = room
	room_order.append(room.id)


func get_room_by_id(room_id: String) -> RoomData:
	if not rooms_by_id.has(room_id):
		return null

	return rooms_by_id[room_id]
