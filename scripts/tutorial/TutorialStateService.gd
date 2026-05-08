extends RefCounted

const SAVE_PATH := "user://tutorial_state.json"


func load_completed() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var json_text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(json_text)
	if not parsed is Dictionary:
		return false
	var data: Dictionary = parsed as Dictionary
	return bool(data.get("completed", false))


func save_completed(completed: bool) -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	var data: Dictionary = {
		"completed": completed
	}
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
