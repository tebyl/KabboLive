extends RefCounted

const SAVE_PATH: String = "user://furniture_stock_state.json"

var stock: Dictionary = {}
var limited_types: Dictionary = {
	"blue_rug": true,
	"golden_plant": true,
	"lounge_chair": true,
}


func load_state() -> void:
	stock.clear()
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed
	var saved_stock: Variant = data.get("stock", {})
	if typeof(saved_stock) != TYPE_DICTIONARY:
		return
	for key: Variant in saved_stock.keys():
		var furniture_type: String = String(key)
		stock[furniture_type] = maxi(0, int(saved_stock[key]))


func save_state() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify({"stock": stock}, "\t"))
	file.close()


func is_limited(furniture_type: String) -> bool:
	return bool(limited_types.get(furniture_type, false))


func get_stock(furniture_type: String) -> int:
	return int(stock.get(furniture_type, 0))


func add_stock(furniture_type: String, amount: int = 1) -> void:
	if amount <= 0:
		return
	stock[furniture_type] = get_stock(furniture_type) + amount


func can_consume(furniture_type: String) -> bool:
	if not is_limited(furniture_type):
		return true
	return get_stock(furniture_type) > 0


func consume_stock(furniture_type: String) -> bool:
	if not is_limited(furniture_type):
		return true
	var current: int = get_stock(furniture_type)
	if current <= 0:
		return false
	stock[furniture_type] = current - 1
	return true


func return_stock(furniture_type: String) -> void:
	if not is_limited(furniture_type):
		return
	add_stock(furniture_type, 1)


func get_all_stock() -> Dictionary:
	return stock.duplicate(true)
