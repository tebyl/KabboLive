extends RefCounted


const SAVE_PATH = "user://player_profile.json"
const DEFAULT_NAME: String = "Invitado"
const DEFAULT_SHIRT_COLOR: Color = Color(0.14, 0.32, 0.72)
const DEFAULT_PANTS_COLOR: Color = Color(0.14, 0.16, 0.30)
const DEFAULT_HAIR_COLOR: Color = Color(0.18, 0.10, 0.06)
const DEFAULT_SKIN_TONE: Color = Color(0.84, 0.62, 0.44)
const DEFAULT_HAIR_STYLE: String = "short"
# Legacy compat alias
const DEFAULT_COLOR: Color = DEFAULT_SHIRT_COLOR

const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const RoomDataScript = preload("res://scripts/room/RoomData.gd")
const IsoGridScript = preload("res://scripts/room/IsoGrid.gd")
const FurnitureData = FurnitureDataScript
const RoomData = RoomDataScript
const IsoGrid = IsoGridScript

var player_name: String = DEFAULT_NAME
var shirt_color: Color = DEFAULT_SHIRT_COLOR
var pants_color: Color = DEFAULT_PANTS_COLOR
var hair_color: Color = DEFAULT_HAIR_COLOR
var skin_tone: Color = DEFAULT_SKIN_TONE
var hair_style: String = DEFAULT_HAIR_STYLE

# Legacy compat alias — reads/writes shirt_color
var avatar_color: Color:
	get: return shirt_color
	set(v): shirt_color = v


func _init() -> void:
	load_profile()


func save_profile() -> bool:
	var data: Dictionary = {
		"player_name": player_name,
		"shirt_color": shirt_color.to_html(),
		"pants_color": pants_color.to_html(),
		"hair_color": hair_color.to_html(),
		"skin_tone": skin_tone.to_html(),
		"hair_style": hair_style,
		"avatar_color": shirt_color.to_html()
	}
	var json_string: String = JSON.stringify(data)
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		return false
	file.store_string(json_string)
	file.close()
	return true


func load_profile() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		set_defaults()
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		set_defaults()
		return
	var json_string: String = file.get_as_text()
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
	# shirt_color: try new key first, fall back to legacy avatar_color
	if dict.has("shirt_color"):
		shirt_color = _color_from_html(dict.get("shirt_color"), DEFAULT_SHIRT_COLOR)
	elif dict.has("avatar_color"):
		shirt_color = _color_from_html(dict.get("avatar_color"), DEFAULT_SHIRT_COLOR)
	else:
		shirt_color = DEFAULT_SHIRT_COLOR
	pants_color = _color_from_html(dict.get("pants_color", ""), DEFAULT_PANTS_COLOR)
	hair_color = _color_from_html(dict.get("hair_color", ""), DEFAULT_HAIR_COLOR)
	skin_tone = _color_from_html(dict.get("skin_tone", ""), DEFAULT_SKIN_TONE)
	hair_style = _sanitize_hair_style(str(dict.get("hair_style", DEFAULT_HAIR_STYLE)))


func set_defaults() -> void:
	player_name = DEFAULT_NAME
	shirt_color = DEFAULT_SHIRT_COLOR
	pants_color = DEFAULT_PANTS_COLOR
	hair_color = DEFAULT_HAIR_COLOR
	skin_tone = DEFAULT_SKIN_TONE
	hair_style = DEFAULT_HAIR_STYLE


func get_profile_data() -> Dictionary:
	return {
		"player_name": player_name,
		"shirt_color": shirt_color,
		"pants_color": pants_color,
		"hair_color": hair_color,
		"skin_tone": skin_tone,
		"hair_style": hair_style
	}


func validate_name(new_name: Variant) -> bool:
	var trimmed: String = str(new_name).strip_edges()
	return not trimmed.is_empty() and trimmed.length() <= 16


func update_profile(profile_data: Dictionary) -> bool:
	var new_name: Variant = profile_data.get("player_name", player_name)
	if not validate_name(new_name):
		return false
	player_name = str(new_name).strip_edges()
	if profile_data.has("shirt_color"):
		shirt_color = profile_data["shirt_color"] as Color
	if profile_data.has("pants_color"):
		pants_color = profile_data["pants_color"] as Color
	if profile_data.has("hair_color"):
		hair_color = profile_data["hair_color"] as Color
	if profile_data.has("skin_tone"):
		skin_tone = profile_data["skin_tone"] as Color
	if profile_data.has("hair_style"):
		hair_style = _sanitize_hair_style(str(profile_data["hair_style"]))
	return save_profile()


func _color_from_html(value: Variant, fallback: Color) -> Color:
	if value == null:
		return fallback
	var s: String = str(value)
	if s.is_empty():
		return fallback
	return Color.from_string(s, fallback)


func _sanitize_hair_style(value: String) -> String:
	if value == "short" or value == "long" or value == "bald":
		return value
	return DEFAULT_HAIR_STYLE
