extends RefCounted

const SAVE_PATH: String = "user://settings_state.json"
const DEFAULT_AUTOSAVE_ENABLED: bool = true
const DEFAULT_AUTOSAVE_INTERVAL: float = 60.0
const DEFAULT_SHOW_MISSIONS: bool = true

var autosave_enabled: bool = DEFAULT_AUTOSAVE_ENABLED
var autosave_interval: float = DEFAULT_AUTOSAVE_INTERVAL
var show_missions: bool = DEFAULT_SHOW_MISSIONS


func _reset_defaults() -> void:
	autosave_enabled = DEFAULT_AUTOSAVE_ENABLED
	autosave_interval = DEFAULT_AUTOSAVE_INTERVAL
	show_missions = DEFAULT_SHOW_MISSIONS


func load_state() -> void:
	_reset_defaults()
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
	autosave_enabled = bool(data.get("autosave_enabled", DEFAULT_AUTOSAVE_ENABLED))
	autosave_interval = _sanitize_interval(float(data.get("autosave_interval", DEFAULT_AUTOSAVE_INTERVAL)))
	show_missions = bool(data.get("show_missions", DEFAULT_SHOW_MISSIONS))


func save_state() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(get_settings_data(), "\t"))
	file.close()


func _sanitize_interval(value: float) -> float:
	if is_equal_approx(value, 30.0):
		return 30.0
	if is_equal_approx(value, 120.0):
		return 120.0
	return 60.0


func get_autosave_enabled() -> bool:
	return autosave_enabled


func set_autosave_enabled(value: bool) -> void:
	autosave_enabled = value


func get_autosave_interval() -> float:
	return autosave_interval


func set_autosave_interval(seconds: float) -> void:
	autosave_interval = _sanitize_interval(seconds)


func get_show_missions() -> bool:
	return show_missions


func set_show_missions(value: bool) -> void:
	show_missions = value


func get_settings_data() -> Dictionary:
	return {
		"autosave_enabled": autosave_enabled,
		"autosave_interval": autosave_interval,
		"show_missions": show_missions,
	}
