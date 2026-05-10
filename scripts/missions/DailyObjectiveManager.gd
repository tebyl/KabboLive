extends RefCounted

const SAVE_PATH: String = "user://daily_objectives_state.json"
const VALID_ROOM_IDS: Array[String] = ["lobby", "room_small", "room_large"]

var objectives: Array[Dictionary] = []
var visited_rooms: Dictionary = {}


func _init() -> void:
	_build_default_objectives()


func _build_default_objectives() -> void:
	objectives = [
		{
			"id": "decorate_room",
			"title": "Decora tu sala",
			"description": "Coloca 6 muebles en cualquier sala.",
			"current_progress": 0,
			"target_progress": 6,
			"reward_credits": 20,
			"completed": false,
			"reward_claimed": false,
		},
		{
			"id": "send_chat",
			"title": "Saluda en el chat",
			"description": "Envía 1 mensaje.",
			"current_progress": 0,
			"target_progress": 1,
			"reward_credits": 10,
			"completed": false,
			"reward_claimed": false,
		},
		{
			"id": "explore_rooms",
			"title": "Explora el hotel",
			"description": "Visita 3 salas distintas.",
			"current_progress": 0,
			"target_progress": 3,
			"reward_credits": 15,
			"completed": false,
			"reward_claimed": false,
		},
		{
			"id": "save_progress",
			"title": "Guarda tu progreso",
			"description": "Guarda tu sala 1 vez.",
			"current_progress": 0,
			"target_progress": 1,
			"reward_credits": 10,
			"completed": false,
			"reward_claimed": false,
		},
		{
			"id": "use_shop",
			"title": "Visita la tienda",
			"description": "Abre la tienda 1 vez.",
			"current_progress": 0,
			"target_progress": 1,
			"reward_credits": 5,
			"completed": false,
			"reward_claimed": false,
		},
	]


func load_state() -> void:
	_build_default_objectives()
	visited_rooms = {}
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var json_string: String = file.get_as_text()
	file.close()
	var json: JSON = JSON.new()
	if json.parse(json_string) != OK:
		return
	var data: Variant = json.data
	if not data is Dictionary:
		return
	var dict: Dictionary = data as Dictionary
	var state_objectives: Dictionary = dict.get("objectives", {}) as Dictionary
	var default_map: Dictionary = {}
	for objective: Dictionary in objectives:
		default_map[str(objective.get("id", ""))] = objective
	for objective_id: String in state_objectives.keys():
		if not default_map.has(objective_id):
			continue
		var state: Dictionary = state_objectives.get(objective_id, {}) as Dictionary
		var target_progress: int = int(default_map[objective_id].get("target_progress", 1))
		var current_progress: int = clampi(int(state.get("current_progress", 0)), 0, target_progress)
		default_map[objective_id]["current_progress"] = current_progress
		default_map[objective_id]["completed"] = bool(state.get("completed", false)) or current_progress >= target_progress
		default_map[objective_id]["reward_claimed"] = bool(state.get("reward_claimed", false))
		if default_map[objective_id]["completed"]:
			default_map[objective_id]["current_progress"] = target_progress
	visited_rooms = {}
	var visited_data: Dictionary = dict.get("visited_rooms", {}) as Dictionary
	for room_id: String in visited_data.keys():
		if VALID_ROOM_IDS.has(room_id) and bool(visited_data.get(room_id, false)):
			visited_rooms[room_id] = true
	if visited_rooms.size() > 0:
		_sync_explore_progress_from_visits()


func save_state() -> void:
	var objectives_state: Dictionary = {}
	for objective: Dictionary in objectives:
		var objective_id: String = str(objective.get("id", ""))
		objectives_state[objective_id] = {
			"current_progress": int(objective.get("current_progress", 0)),
			"completed": bool(objective.get("completed", false)),
			"reward_claimed": bool(objective.get("reward_claimed", false)),
		}
	var data: Dictionary = {
		"objectives": objectives_state,
		"visited_rooms": visited_rooms,
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data))
	file.close()


func get_objectives() -> Array[Dictionary]:
	var copy: Array[Dictionary] = []
	for objective: Dictionary in objectives:
		copy.append(objective.duplicate(true))
	return copy


func get_active_objective() -> Dictionary:
	for objective: Dictionary in objectives:
		if not bool(objective.get("completed", false)):
			return objective.duplicate(true)
	if objectives.is_empty():
		return {}
	return {
		"id": "daily_complete",
		"title": "Objetivos diarios completos",
		"description": "Vuelve pronto para más tareas.",
		"current_progress": 1,
		"target_progress": 1,
		"reward_credits": 0,
		"completed": true,
		"reward_claimed": true,
		"just_completed": false,
	}


func add_progress(objective_id: String, amount: int = 1) -> Dictionary:
	if amount <= 0:
		return {}
	var objective: Dictionary = _get_objective(objective_id)
	if objective.is_empty() or bool(objective.get("completed", false)):
		return {}
	var target_progress: int = max(1, int(objective.get("target_progress", 1)))
	var current_progress: int = int(objective.get("current_progress", 0))
	current_progress = clampi(current_progress + amount, 0, target_progress)
	objective["current_progress"] = current_progress
	var just_completed: bool = false
	if current_progress >= target_progress:
		if not bool(objective.get("completed", false)):
			just_completed = true
		objective["completed"] = true
		objective["current_progress"] = target_progress
		objective["reward_claimed"] = false
	_set_objective(objective)
	var result: Dictionary = objective.duplicate(true)
	result["just_completed"] = just_completed
	return result


func claim_reward(objective_id: String) -> bool:
	var objective: Dictionary = _get_objective(objective_id)
	if objective.is_empty() or not bool(objective.get("completed", false)):
		return false
	if bool(objective.get("reward_claimed", false)):
		return false
	objective["reward_claimed"] = true
	_set_objective(objective)
	return true


func visit_room(room_id: String) -> Dictionary:
	if not VALID_ROOM_IDS.has(room_id):
		return {}
	if bool(visited_rooms.get(room_id, false)):
		return {}
	visited_rooms[room_id] = true
	return _sync_explore_progress_from_visits()


func is_completed(objective_id: String) -> bool:
	var objective: Dictionary = _get_objective(objective_id)
	if objective.is_empty():
		return false
	return bool(objective.get("completed", false))


func reset_objectives() -> void:
	_build_default_objectives()
	visited_rooms = {}


func get_completed_count() -> int:
	var count: int = 0
	for objective: Dictionary in objectives:
		if bool(objective.get("completed", false)):
			count += 1
	return count


func get_total_count() -> int:
	return objectives.size()


func _sync_explore_progress_from_visits() -> Dictionary:
	var objective: Dictionary = _get_objective("explore_rooms")
	if objective.is_empty() or bool(objective.get("completed", false)):
		return {}
	var target_progress: int = max(1, int(objective.get("target_progress", 1)))
	var valid_count: int = visited_rooms.size()
	var current_progress: int = clampi(valid_count, 0, target_progress)
	objective["current_progress"] = current_progress
	var just_completed: bool = false
	if current_progress >= target_progress:
		if not bool(objective.get("completed", false)):
			just_completed = true
		objective["completed"] = true
		objective["current_progress"] = target_progress
		objective["reward_claimed"] = false
	_set_objective(objective)
	var result: Dictionary = objective.duplicate(true)
	result["just_completed"] = just_completed
	return result


func _get_objective(objective_id: String) -> Dictionary:
	for objective: Dictionary in objectives:
		if str(objective.get("id", "")) == objective_id:
			return objective
	return {}


func _set_objective(updated_objective: Dictionary) -> void:
	var objective_id: String = str(updated_objective.get("id", ""))
	for index in range(objectives.size()):
		if str(objectives[index].get("id", "")) == objective_id:
			objectives[index] = updated_objective.duplicate(true)
			return
