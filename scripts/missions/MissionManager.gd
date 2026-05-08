extends RefCounted

const SAVE_PATH: String = "user://missions_state.json"

var missions: Array[Dictionary] = []


func _init() -> void:
	_build_default_missions()


func _build_default_missions() -> void:
	missions = [
		{
			"id": "first_walk",
			"title": "Da tu primer paso",
			"description": "Haz click en un tile libre para caminar.",
			"completed": false,
			"reward_credits": 5,
			"reward_claimed": false
		},
		{
			"id": "place_first_furniture",
			"title": "Decora tu sala",
			"description": "Coloca tu primer mueble desde el catálogo.",
			"completed": false,
			"reward_credits": 10,
			"reward_claimed": false
		},
		{
			"id": "inspect_first_furniture",
			"title": "Inspecciona un mueble",
			"description": "Haz click sobre un mueble para abrir el inspector.",
			"completed": false,
			"reward_credits": 5,
			"reward_claimed": false
		},
		{
			"id": "send_first_chat",
			"title": "Saluda en el chat",
			"description": "Presiona Enter y envía tu primer mensaje.",
			"completed": false,
			"reward_credits": 10,
			"reward_claimed": false
		},
		{
			"id": "save_room",
			"title": "Guarda tu progreso",
			"description": "Presiona S para guardar tus salas.",
			"completed": false,
			"reward_credits": 15,
			"reward_claimed": false
		},
	]


func load_state() -> void:
	_build_default_missions()
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
	if data.has("missions"):
		_load_new_format(data)
		return
	_load_legacy_format(data)


func _load_new_format(data: Dictionary) -> void:
	var missions_variant: Variant = data.get("missions", {})
	if not missions_variant is Dictionary:
		return
	var saved_missions: Dictionary = missions_variant as Dictionary
	for i: int in range(missions.size()):
		var mission: Dictionary = missions[i]
		var mission_id: String = str(mission.get("id", ""))
		var saved_variant: Variant = saved_missions.get(mission_id, {})
		if saved_variant is Dictionary:
			var saved: Dictionary = saved_variant as Dictionary
			mission["completed"] = bool(saved.get("completed", false))
			mission["reward_claimed"] = bool(saved.get("reward_claimed", bool(mission.get("completed", false))))
		missions[i] = mission


func _load_legacy_format(data: Dictionary) -> void:
	var completed_variant: Variant = data.get("completed", {})
	if not completed_variant is Dictionary:
		return
	var completed: Dictionary = completed_variant as Dictionary
	for i: int in range(missions.size()):
		var mission: Dictionary = missions[i]
		var mission_id: String = str(mission.get("id", ""))
		var is_done: bool = bool(completed.get(mission_id, false))
		mission["completed"] = is_done
		mission["reward_claimed"] = is_done
		missions[i] = mission


func save_state() -> void:
	var saved_missions: Dictionary = {}
	for mission: Dictionary in missions:
		saved_missions[str(mission.get("id", ""))] = {
			"completed": bool(mission.get("completed", false)),
			"reward_claimed": bool(mission.get("reward_claimed", false))
		}
	var data: Dictionary = {
		"missions": saved_missions
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func get_missions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for mission: Dictionary in missions:
		result.append(mission.duplicate(true))
	return result


func complete_mission(mission_id: String) -> Dictionary:
	for i: int in range(missions.size()):
		var mission: Dictionary = missions[i]
		if str(mission.get("id", "")) != mission_id:
			continue
		if bool(mission.get("completed", false)):
			return {}
		mission["completed"] = true
		mission["reward_claimed"] = true
		missions[i] = mission
		return mission.duplicate(true)
	return {}


func is_completed(mission_id: String) -> bool:
	for mission: Dictionary in missions:
		if str(mission.get("id", "")) == mission_id:
			return bool(mission.get("completed", false))
	return false


func reset_missions() -> void:
	_build_default_missions()
	save_state()
