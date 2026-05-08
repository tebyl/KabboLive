extends RefCounted

const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")

const FURNITURE_CATALOG: Dictionary = {
	"chair": {"display_name": "Silla",    "category": "Asientos",   "size": Vector2i(1, 1), "shortcut": KEY_1, "blocks_movement": true,  "layer": "furniture"},
	"table": {"display_name": "Mesa",     "category": "Mesas",      "size": Vector2i(2, 1), "shortcut": KEY_2, "blocks_movement": true,  "layer": "furniture"},
	"sofa":  {"display_name": "Sofá",     "category": "Asientos",   "size": Vector2i(2, 1), "shortcut": KEY_3, "blocks_movement": true,  "layer": "furniture"},
	"plant": {"display_name": "Planta",   "category": "Decoración", "size": Vector2i(1, 1), "shortcut": 0,     "blocks_movement": true,  "layer": "decor"},
	"rug":   {"display_name": "Alfombra", "category": "Decoración", "size": Vector2i(2, 2), "shortcut": 0,     "blocks_movement": false, "layer": "floor"},
}

var items: Array = []  # kept for API compat (toggle_inventory)
var _selected_type: String = ""


func _init() -> void:
	items = []


func get_catalog() -> Dictionary:
	return FURNITURE_CATALOG


func select_type(furniture_type: String) -> void:
	if FURNITURE_CATALOG.has(furniture_type):
		_selected_type = furniture_type


func select_index(index: int) -> void:
	var shortcut_types: Array[String] = ["chair", "table", "sofa"]
	if index >= 0 and index < shortcut_types.size():
		_selected_type = shortcut_types[index]


func cancel_selection() -> void:
	_selected_type = ""


func has_selected_furniture() -> bool:
	return _selected_type != "" and FURNITURE_CATALOG.has(_selected_type)


func get_selected_type_text() -> String:
	return _selected_type


func get_selected_display_name() -> String:
	if not has_selected_furniture():
		return ""
	return FURNITURE_CATALOG[_selected_type].get("display_name", _selected_type)


func create_selected_furniture(target_cell) -> Object:
	if not has_selected_furniture():
		return null
	var info: Dictionary = FURNITURE_CATALOG[_selected_type]
	var f: RefCounted = FurnitureDataScript.new(target_cell, StringName(_selected_type), info["size"])
	f.blocks_movement = info.get("blocks_movement", true)
	f.layer = info.get("layer", "furniture")
	return f
