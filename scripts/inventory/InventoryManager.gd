extends RefCounted

const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")

const FURNITURE_CATALOG: Dictionary = {
	"chair": {"display_name": "Silla", "category": "Asientos", "size": Vector2i(1, 1), "shortcut": KEY_1, "blocks_movement": true, "layer": "furniture", "is_shop_item": false},
	"table": {"display_name": "Mesa", "category": "Mesas", "size": Vector2i(2, 1), "shortcut": KEY_2, "blocks_movement": true, "layer": "furniture", "is_shop_item": false},
	"sofa": {"display_name": "Sofá", "category": "Asientos", "size": Vector2i(2, 1), "shortcut": KEY_3, "blocks_movement": true, "layer": "furniture", "is_shop_item": false},
	"plant": {"display_name": "Planta", "category": "Decoración", "size": Vector2i(1, 1), "shortcut": 0, "blocks_movement": true, "layer": "decor", "is_shop_item": false},
	"rug": {"display_name": "Alfombra", "category": "Decoración", "size": Vector2i(2, 2), "shortcut": 0, "blocks_movement": false, "layer": "floor", "is_shop_item": false},
	"blue_rug": {"display_name": "Alfombra Azul", "category": "Decoración", "size": Vector2i(2, 2), "shortcut": 0, "blocks_movement": false, "layer": "floor", "is_shop_item": true, "price": 15},
	"golden_plant": {"display_name": "Planta Dorada", "category": "Decoración", "size": Vector2i(1, 1), "shortcut": 0, "blocks_movement": true, "layer": "decor", "is_shop_item": true, "price": 20},
	"lounge_chair": {"display_name": "Sillón Lounge", "category": "Asientos", "size": Vector2i(1, 1), "shortcut": 0, "blocks_movement": true, "layer": "furniture", "is_shop_item": true, "price": 25},
}

var items: Array = []  # kept for API compat (toggle_inventory)
var _selected_type: String = ""
var _available_catalog: Dictionary = {}


func _init() -> void:
	items = []
	_available_catalog = get_available_catalog({})


func get_catalog() -> Dictionary:
	return _available_catalog


func get_base_catalog() -> Dictionary:
	var result: Dictionary = {}
	for type: String in FURNITURE_CATALOG:
		var info: Dictionary = FURNITURE_CATALOG[type]
		if not bool(info.get("is_shop_item", false)):
			result[type] = info.duplicate(true)
	return result


func get_available_catalog(owned_items: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for type: String in FURNITURE_CATALOG:
		var info: Dictionary = FURNITURE_CATALOG[type]
		if bool(info.get("is_shop_item", false)) and not bool(owned_items.get(type, false)):
			continue
		result[type] = info.duplicate(true)
	return result


func set_available_catalog(owned_items: Dictionary) -> void:
	_available_catalog = get_available_catalog(owned_items)
	if _selected_type != "" and not _available_catalog.has(_selected_type):
		_selected_type = ""


func select_type(furniture_type: String) -> void:
	if _available_catalog.has(furniture_type):
		_selected_type = furniture_type


func select_index(index: int) -> void:
	var shortcut_types: Array[String] = ["chair", "table", "sofa"]
	if index >= 0 and index < shortcut_types.size():
		_selected_type = shortcut_types[index]


func cancel_selection() -> void:
	_selected_type = ""


func has_selected_furniture() -> bool:
	return _selected_type != "" and _available_catalog.has(_selected_type)


func has_furniture_type(type: String) -> bool:
	return _available_catalog.has(type)


func get_selected_type_text() -> String:
	return _selected_type


func get_selected_furniture_type() -> String:
	return _selected_type


func get_selected_display_name() -> String:
	if not has_selected_furniture():
		return ""
	return _available_catalog[_selected_type].get("display_name", _selected_type)


func create_selected_furniture(target_cell: Vector2i) -> Object:
	return create_selected_furniture_at(target_cell)


func create_selected_furniture_at(target_cell: Vector2i) -> RefCounted:
	if not has_selected_furniture():
		return null
	var info: Dictionary = _available_catalog[_selected_type]
	var f: RefCounted = FurnitureDataScript.new(target_cell, StringName(_selected_type), info["size"])
	f.blocks_movement = info.get("blocks_movement", true)
	f.layer = info.get("layer", "furniture")
	return f
