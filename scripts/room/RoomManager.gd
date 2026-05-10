extends RefCounted

const RoomDataScript = preload("res://scripts/room/RoomData.gd")
const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const RoomData = RoomDataScript
const FurnitureData = FurnitureDataScript

var rooms_by_id: Dictionary = {} # String (RefCounted)
var room_order: Array[String] = []
var current_room_id = ""


func _init() :
	register_initial_rooms()


func get_current_room():
	return get_room_by_id(current_room_id)


func switch_room(room_id) :
	if not rooms_by_id.has(room_id):
		return false

	current_room_id = room_id
	return true


func get_current_room_name() :
	var room = get_current_room()

	if room == null:
		return ""

	return room.display_name


func get_current_room_size() -> Vector2i:
	var room = get_current_room()

	if room == null:
		return Vector2i.ZERO

	return Vector2i(room.width, room.height)


func get_current_player_start_cell() -> Vector2i:
	var room = get_current_room()

	if room == null:
		return Vector2i.ZERO

	return room.player_start_cell


func get_current_furniture_items():
	var room = get_current_room()

	if room == null:
		return []

	return room.get_furniture_items_copy()


func set_current_furniture_items(items) :
	set_room_furniture_items(current_room_id, items)


func get_all_rooms():
	var rooms = []

	for room_id in room_order:
		var room = get_room_by_id(room_id)

		if room != null:
			if room is RefCounted and room.has_method("get_script"):
				rooms.append(room.get_script().new(room.id, room.display_name, room.width, room.height, room.player_start_cell, room.furniture_items, room.floor_type))
			else:
				rooms.append(room)

	return rooms


func set_room_furniture_items(room_id, items) :
	var room = get_room_by_id(room_id)

	if room == null:
		return

	room.furniture_items.clear()

	for furniture in items:
		if furniture is RefCounted and furniture.has_method("get_script"):
			room.furniture_items.append(furniture.get_script().new(furniture.cell, furniture.type, furniture.size))
		else:
			room.furniture_items.append(furniture)


func apply_saved_rooms(saved_rooms) :
	for saved_room in saved_rooms:
		var target_room = get_room_by_id(saved_room.id)

		if target_room == null:
			continue

		target_room.furniture_items.clear()
		var floor_type_variant: Variant = saved_room.get("floor_type")
		if floor_type_variant != null and str(floor_type_variant) != "":
			target_room.floor_type = str(floor_type_variant)

		for furniture in saved_room.furniture_items:
			if furniture is RefCounted and furniture.has_method("get_script"):
				target_room.furniture_items.append(furniture.get_script().new(furniture.cell, furniture.type, furniture.size))
			else:
				target_room.furniture_items.append(furniture)


func register_initial_rooms() :
	register_room(
		RoomDataScript.new(
			"lobby",
			"Lobby",
			10,
			10,
			Vector2i(1, 1),
			[
				# Alfombra de bienvenida — centro-izquierda
				FurnitureDataScript.new(Vector2i(2, 4), &"rug", Vector2i(2, 2)),
				# Zona de descanso: sofá + escritorio + silla
				FurnitureDataScript.new(Vector2i(7, 2), &"sofa", Vector2i(2, 1)),
				FurnitureDataScript.new(Vector2i(6, 4), &"chair", Vector2i(1, 1)),
				FurnitureDataScript.new(Vector2i(7, 5), &"desk", Vector2i(2, 1)),
				# Decoración: lámpara junto al escritorio, estantería en esquina
				FurnitureDataScript.new(Vector2i(6, 2), &"lamp", Vector2i(1, 1)),
				FurnitureDataScript.new(Vector2i(1, 3), &"bookshelf", Vector2i(1, 2)),
				# Plantas en esquinas
				FurnitureDataScript.new(Vector2i(8, 1), &"big_plant", Vector2i(1, 1)),
				FurnitureDataScript.new(Vector2i(1, 8), &"plant", Vector2i(1, 1)),
				FurnitureDataScript.new(Vector2i(8, 8), &"plant", Vector2i(1, 1)),
			]
		)
	)
	register_room(
		RoomDataScript.new(
			"room_small",
			"Sala pequeña",
			8,
			8,
			Vector2i(1, 1)
		)
	)
	register_room(
		RoomDataScript.new(
			"room_large",
			"Sala grande",
			14,
			10,
			Vector2i(2, 2)
		)
	)
	current_room_id = "lobby"


func register_room(room) :
	rooms_by_id[room.id] = room
	room_order.append(room.id)


func get_room_by_id(room_id):
	if not rooms_by_id.has(room_id):
		return null

	return rooms_by_id[room_id]
