extends RefCounted


const MAX_HISTORY_MESSAGES = 8

const IsoGridScript = preload("res://scripts/room/IsoGrid.gd")
const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const RoomDataScript = preload("res://scripts/room/RoomData.gd")
const PathfindingManagerScript = preload("res://scripts/room/PathfindingManager.gd")

const IsoGrid = IsoGridScript
const FurnitureData = FurnitureDataScript
const RoomData = RoomDataScript
const PathfindingManager = PathfindingManagerScript
const MAX_MESSAGE_LENGTH = 120

var player_name = "Invitado"
var _history: Array[String] = []



func set_player_name(new_name) :
	if new_name.strip_edges().is_empty():
		player_name = "Invitado"
	else:
		player_name = new_name.strip_edges()


func clear_history() :
	_history.clear()


func get_history() -> Array[String]:
	var history_copy: Array[String] = []
	for message in _history:
		history_copy.append(message)
	return history_copy


func add_raw_message(text: String) -> void:
	if text.is_empty():
		return
	_history.append(text)
	if _history.size() > MAX_HISTORY_MESSAGES:
		_history.remove_at(0)


func submit_message(raw_text) -> Dictionary:
	var trimmed_message = raw_text.strip_edges()

	if trimmed_message.is_empty():
		return {
			"sent": false,
			"reason": "empty",
			"message": ""
		}

	if trimmed_message.length() > MAX_MESSAGE_LENGTH:
		trimmed_message = trimmed_message.left(MAX_MESSAGE_LENGTH)

	var formatted_message = player_name + ": " + trimmed_message
	_history.append(formatted_message)

	if _history.size() > MAX_HISTORY_MESSAGES:
		_history.remove_at(0)

	return {
		"sent": true,
		"reason": "ok",
		"message": formatted_message
	}
