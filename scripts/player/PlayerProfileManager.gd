extends RefCounted


const SAVE_PATH = "user://player_profile.json"
const DEFAULT_NAME = "Invitado"
const DEFAULT_COLOR: Color = Color(0.14, 0.32, 0.72) # Azul

const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const RoomDataScript = preload("res://scripts/room/RoomData.gd")
const IsoGridScript = preload("res://scripts/room/IsoGrid.gd")

const FurnitureData = FurnitureDataScript
const RoomData = RoomDataScript
const IsoGrid = IsoGridScript

var player_name = DEFAULT_NAME
var avatar_color: Color = DEFAULT_COLOR


func _init() :
	load_profile()


func save_profile() :
	var data: Dictionary = {
		"player_name": player_name,
		"avatar_color": avatar_color.to_html()
	}

	var json_string = JSON.stringify(data)
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		return false

	file.store_string(json_string)
	file.close()
	return true


func load_profile() :
	if not FileAccess.file_exists(SAVE_PATH):
		set_defaults()
		return

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		set_defaults()
		return

	var json_string = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var error: Error = json.parse(json_string)
	if error != OK:
		set_defaults()
		return

	var data: Variant = json.data
	if not data is Dictionary:
		set_defaults()
		return

	var dict: Dictionary = data as Dictionary
	player_name = str(dict.get("player_name", DEFAULT_NAME))
	if player_name.strip_edges().is_empty():
		player_name = DEFAULT_NAME

	var color_html = str(dict.get("avatar_color", DEFAULT_COLOR.to_html()))
	avatar_color = Color.from_string(color_html, DEFAULT_COLOR)


func set_defaults() :
	player_name = DEFAULT_NAME
	avatar_color = DEFAULT_COLOR


func validate_name(new_name) :
	var trimmed = new_name.strip_edges()
	return not trimmed.is_empty() and trimmed.length() <= 16


func update_profile(new_name, new_color: Color) :
	if not validate_name(new_name):
		return false

	player_name = new_name.strip_edges()
	avatar_color = new_color
	return save_profile()
