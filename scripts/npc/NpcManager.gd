extends RefCounted

const NPC_NAME: String = "Bot Guía"
const HOME_CELL: Vector2i = Vector2i(5, 5)
const LOBBY_ROOM_ID: String = "lobby"
const NPC_BODY_COLOR: Color = Color(0.80, 0.38, 0.12)
const NPC_HAIR_COLOR: Color = Color(0.05, 0.20, 0.45)

var _npc_root: Node2D
var _iso_grid
var _pathfinding_manager
var _npc_node: Node2D
var _npc_cell: Vector2i
var _is_active: bool = false


func _init(p_npc_root: Node2D, p_iso_grid, p_pathfinding_manager) -> void:
	_npc_root = p_npc_root
	_iso_grid = p_iso_grid
	_pathfinding_manager = p_pathfinding_manager
	_npc_cell = HOME_CELL
	_build_visual()
	_npc_node.visible = false


func activate() -> void:
	_is_active = true
	_npc_cell = HOME_CELL
	_npc_node.position = _iso_grid.grid_to_iso(_npc_cell)
	_update_z_index()
	_npc_node.visible = true
	_pathfinding_manager.set_point_solid(_npc_cell, true)


func deactivate() -> void:
	if not _is_active:
		return
	_pathfinding_manager.set_point_solid(_npc_cell, false)
	_is_active = false
	_npc_node.visible = false


func is_active() -> bool:
	return _is_active


func get_world_position() -> Vector2:
	if _npc_node == null:
		return Vector2.ZERO
	return _npc_node.global_position


func reapply_pathfinding_solid() -> void:
	if _is_active:
		_pathfinding_manager.set_point_solid(_npc_cell, true)


func get_response(player_message: String) -> String:
	var lower: String = player_message.to_lower()
	if "hola" in lower:
		return NPC_NAME + ": ¡Hola! Bienvenido a Kabbo Hotel."
	if "ayuda" in lower:
		return NPC_NAME + ": Usa 1, 2 y 3 para colocar muebles. Enter abre el chat."
	if "salas" in lower:
		return NPC_NAME + ": Puedes cambiar de sala con F1, F2 y F3."
	return ""


func _build_visual() -> void:
	_npc_node = Node2D.new()
	_npc_node.name = "BotGuia"
	_npc_root.add_child(_npc_node)

	var shadow: Polygon2D = Polygon2D.new()
	shadow.polygon = PackedVector2Array([
		Vector2(0.0, -4.0), Vector2(18.0, 0.0), Vector2(0.0, 4.0), Vector2(-18.0, 0.0)
	])
	shadow.color = Color(0.04, 0.05, 0.06, 0.34)
	shadow.position = Vector2(0.0, 1.0)
	shadow.z_index = 0
	_npc_node.add_child(shadow)

	_npc_node.add_child(_make_rect_part(Vector2(6.0, 12.0), Color(0.08, 0.10, 0.18), Vector2(-5.0, -8.0), 1))
	_npc_node.add_child(_make_rect_part(Vector2(6.0, 12.0), Color(0.08, 0.10, 0.18), Vector2(5.0, -8.0), 1))
	_npc_node.add_child(_make_rect_part(Vector2(18.0, 22.0), NPC_BODY_COLOR, Vector2(0.0, -22.0), 2))
	_npc_node.add_child(_make_rect_part(Vector2(12.0, 4.0), NPC_BODY_COLOR.lightened(0.3), Vector2(0.0, -31.0), 3))
	_npc_node.add_child(_make_circle_part(10.0, 14, Color(0.78, 0.54, 0.38), Vector2(0.0, -44.0), 4))
	_npc_node.add_child(_make_rect_part(Vector2(18.0, 6.0), NPC_HAIR_COLOR, Vector2(0.0, -52.0), 5))
	_npc_node.add_child(_make_rect_part(Vector2(3.0, 2.0), Color(0.08, 0.08, 0.08), Vector2(-4.0, -45.0), 6))
	_npc_node.add_child(_make_rect_part(Vector2(3.0, 2.0), Color(0.08, 0.08, 0.08), Vector2(5.0, -45.0), 6))

	var name_label: Label = Label.new()
	name_label.text = NPC_NAME
	name_label.position = Vector2(-30.0, -72.0)
	name_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.95))
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.z_index = 10
	_npc_node.add_child(name_label)


func _update_z_index() -> void:
	_npc_node.z_index = _iso_grid.get_draw_z_index(_npc_cell) + 5


func _make_rect_part(size: Vector2, color: Color, pos: Vector2, z_idx: int) -> Polygon2D:
	var half: Vector2 = size / 2.0
	var poly: Polygon2D = Polygon2D.new()
	poly.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y)
	])
	poly.color = color
	poly.position = pos
	poly.z_index = z_idx
	return poly


func _make_circle_part(radius: float, point_count: int, color: Color, pos: Vector2, z_idx: int) -> Polygon2D:
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in range(point_count):
		var angle: float = TAU * float(i) / float(point_count)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	var poly: Polygon2D = Polygon2D.new()
	poly.polygon = points
	poly.color = color
	poly.position = pos
	poly.z_index = z_idx
	return poly
