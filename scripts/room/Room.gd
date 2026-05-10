extends Node2D
## Room scene — esqueleto visual de una sala.
## Orquestación (switch_room, setup) sigue en Main.gd durante la migración incremental.
## Fase siguiente: mover lógica de sala aquí desde Main.gd.

# Señales para comunicar eventos de sala hacia el orquestador
signal room_ready(room_id: String)
signal player_moved(cell: Vector2i)

func get_floor_node() -> Node2D:
	return $Floor

func get_furniture_layer() -> Node2D:
	return $FurnitureLayer

func get_npc_layer() -> Node2D:
	return $NpcLayer

func get_player_node() -> Node2D:
	return $Player

# --- API pública (Fase 3 — implementación gradual) ---
# Estos métodos serán llenados cuando la lógica migre desde Main.gd.

func setup(_room_data: Dictionary, _profile_data: Dictionary) -> void:
	pass  # TODO Phase 3: mover lógica de switch_room aquí

func enter_room(_room_id: String) -> void:
	pass  # TODO Phase 3

func redraw_room() -> void:
	pass  # TODO Phase 3

func set_decoration_mode(_enabled: bool) -> void:
	pass  # TODO Phase 3
