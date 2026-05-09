extends RefCounted

const SAVE_PATH: String = "user://shop_state.json"

var owned_items: Dictionary = {}
var shop_items: Array[Dictionary] = [
	{
		"id": "blue_rug",
		"type": "blue_rug",
		"display_name": "Alfombra Azul",
		"category": "Decoración",
		"price": 15,
		"size": Vector2i(2, 2),
		"layer": "floor",
		"blocks_movement": false,
		"shortcut": 0,
		"is_shop_item": true
	},
	{
		"id": "golden_plant",
		"type": "golden_plant",
		"display_name": "Planta Dorada",
		"category": "Decoración",
		"price": 20,
		"size": Vector2i(1, 1),
		"layer": "decor",
		"blocks_movement": true,
		"shortcut": 0,
		"is_shop_item": true
	},
	{
		"id": "lounge_chair",
		"type": "lounge_chair",
		"display_name": "Sillón Lounge",
		"category": "Asientos",
		"price": 25,
		"size": Vector2i(1, 1),
		"layer": "furniture",
		"blocks_movement": true,
		"shortcut": 0,
		"is_shop_item": true
	},
]


func load_state() -> void:
	owned_items.clear()
	for item: Dictionary in shop_items:
		owned_items[str(item.get("id", ""))] = false
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var json_text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(json_text)
	if not parsed is Dictionary:
		return
	var data: Dictionary = parsed as Dictionary
	var owned_variant: Variant = data.get("owned_items", {})
	if not owned_variant is Dictionary:
		return
	var saved_owned: Dictionary = owned_variant as Dictionary
	for item_id: String in owned_items.keys():
		owned_items[item_id] = bool(saved_owned.get(item_id, false))


func save_state() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	var data: Dictionary = {
		"owned_items": owned_items
	}
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func get_owned_items() -> Dictionary:
	return owned_items.duplicate(true)


func get_shop_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item: Dictionary in shop_items:
		var copy: Dictionary = item.duplicate(true)
		var item_id: String = str(copy.get("id", ""))
		copy["owned"] = is_owned(item_id)
		result.append(copy)
	return result


func is_owned(item_id: String) -> bool:
	return bool(owned_items.get(item_id, false))


func buy_item(item_id: String, available_credits: int) -> Dictionary:
	var item: Dictionary = get_item(item_id)
	if item.is_empty():
		return _buy_result(false, "not_found", 0, item_id, "")
	var price: int = int(item.get("price", 0))
	if available_credits < price:
		return _buy_result(false, "not_enough_credits", price, item_id, str(item.get("display_name", "")))
	return _buy_result(true, "ok", price, item_id, str(item.get("display_name", "")))


func mark_owned(item_id: String) -> bool:
	if get_item(item_id).is_empty():
		return false
	owned_items[item_id] = true
	return true


func get_item(item_id: String) -> Dictionary:
	for item: Dictionary in shop_items:
		if str(item.get("id", "")) == item_id:
			return item.duplicate(true)
	return {}


func _buy_result(success: bool, reason: String, price: int, item_id: String, display_name: String) -> Dictionary:
	return {
		"success": success,
		"reason": reason,
		"price": price,
		"item_id": item_id,
		"display_name": display_name
	}
