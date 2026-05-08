extends RefCounted

const SAVE_PATH: String = "user://currency_state.json"

var credits: int = 0


func load_state() -> void:
	credits = 0
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
	credits = maxi(0, int(data.get("credits", 0)))


func save_state() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	var data: Dictionary = {
		"credits": credits
	}
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func get_credits() -> int:
	return credits


func add_credits(amount: int) -> int:
	if amount <= 0:
		return credits
	credits += amount
	return credits


func can_spend(amount: int) -> bool:
	return amount > 0 and credits >= amount


func spend_credits(amount: int) -> bool:
	if not can_spend(amount):
		return false
	credits -= amount
	return true


func set_credits(amount: int) -> void:
	credits = maxi(0, amount)


func reset() -> void:
	credits = 0
	save_state()
