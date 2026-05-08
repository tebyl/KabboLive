extends RefCounted

const NPC_NAME: String = "Bot Guía"
const HOME_CELL: Vector2i = Vector2i(5, 5)
const VT = preload("res://scripts/visual/VisualTheme.gd")
const NPC_BODY_COLOR: Color = Color(0.80, 0.38, 0.12)
const NPC_HAIR_COLOR: Color = Color(0.05, 0.20, 0.45)
const MOVE_STEP_DURATION: float = 0.40
const MOVE_DELAY_MIN: float = 4.0
const MOVE_DELAY_MAX: float = 7.0

var _npc_root: Node2D
var _iso_grid
var _pathfinding_manager
var _player_controller
var _npc_node: Node2D
var _npc_cell: Vector2i
var _is_active: bool = false
var _is_moving: bool = false
var _move_timer: float = 0.0
var _next_move_delay: float = 0.0
var _active_tween: Tween
var _rng: RandomNumberGenerator


func _init(p_npc_root: Node2D, p_iso_grid, p_pathfinding_manager, p_player_controller) -> void:
	_npc_root = p_npc_root
	_iso_grid = p_iso_grid
	_pathfinding_manager = p_pathfinding_manager
	_player_controller = p_player_controller
	_npc_cell = HOME_CELL
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	_build_visual()
	_npc_node.visible = false


func activate() -> void:
	_is_active = true
	_npc_cell = HOME_CELL
	_npc_node.position = _iso_grid.grid_to_iso(_npc_cell)
	_update_z_index()
	_npc_node.visible = true
	_pathfinding_manager.set_point_solid(_npc_cell, true)
	_schedule_next_move()


func deactivate() -> void:
	if not _is_active:
		return
	_stop_motion()
	_pathfinding_manager.set_point_solid(_npc_cell, false)
	_is_active = false
	_npc_node.visible = false
	_move_timer = 0.0
	_next_move_delay = 0.0


func is_active() -> bool:
	return _is_active


func get_world_position() -> Vector2:
	if _npc_node == null:
		return Vector2.ZERO
	return _npc_node.global_position


func reapply_pathfinding_solid() -> void:
	if _is_active:
		_pathfinding_manager.set_point_solid(_npc_cell, true)


func process(delta: float) -> void:
	if not _is_active or _is_moving:
		return
	_move_timer += delta
	if _move_timer >= _next_move_delay:
		_move_timer = 0.0
		_try_move_randomly()


func get_response(player_message: String) -> String:
	var lower: String = player_message.to_lower()
	if "hola" in lower:
		return NPC_NAME + ": ¡Hola! Bienvenido a Kabbo Hotel."
	if "ayuda" in lower:
		return NPC_NAME + ": Usa 1, 2 y 3 para colocar muebles. Enter abre el chat."
	if "salas" in lower:
		return NPC_NAME + ": Puedes cambiar de sala con F1, F2 y F3."
	return ""


func _schedule_next_move() -> void:
	_move_timer = 0.0
	_next_move_delay = _rng.randf_range(MOVE_DELAY_MIN, MOVE_DELAY_MAX)


func _try_move_randomly() -> void:
	var candidates: Array[Vector2i] = _get_candidate_cells()
	if candidates.is_empty():
		_schedule_next_move()
		return
	var start: int = _rng.randi() % candidates.size()
	for i: int in range(candidates.size()):
		var cell: Vector2i = candidates[(start + i) % candidates.size()]
		if _can_npc_move_to(cell):
			_move_to_cell(cell)
			return
	_schedule_next_move()


func _get_candidate_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var directions: Array[Vector2i] = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)
	]
	for dir: Vector2i in directions:
		result.append(_npc_cell + dir)
	return result


func _can_npc_move_to(cell: Vector2i) -> bool:
	if not _iso_grid.is_valid_cell(cell):
		return false
	if _pathfinding_manager.is_point_solid(cell):
		return false
	if _player_controller != null and cell == _player_controller.get_player_cell():
		return false
	return true


func _move_to_cell(cell: Vector2i) -> void:
	_pathfinding_manager.set_point_solid(_npc_cell, false)
	_npc_cell = cell
	_pathfinding_manager.set_point_solid(_npc_cell, true)
	_is_moving = true
	_update_z_index()

	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()

	_active_tween = _npc_node.create_tween()
	_active_tween.tween_property(_npc_node, "position", _iso_grid.grid_to_iso(_npc_cell), MOVE_STEP_DURATION)
	_active_tween.finished.connect(_on_move_finished)


func _on_move_finished() -> void:
	_is_moving = false
	_schedule_next_move()


func _stop_motion() -> void:
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null
	_is_moving = false
	if _npc_node != null:
		_npc_node.position = _iso_grid.grid_to_iso(_npc_cell)


func _build_visual() -> void:
	_npc_node = Node2D.new()
	_npc_node.name = "BotGuia"
	_npc_root.add_child(_npc_node)

	# Shadow
	var shadow: Polygon2D = Polygon2D.new()
	shadow.polygon = PackedVector2Array([
		Vector2(0.0, -7.0), Vector2(26.0, 0.0), Vector2(0.0, 7.0), Vector2(-26.0, 0.0)
	])
	shadow.color = VT.SHADOW_MED
	shadow.position = Vector2(0.0, 5.0)
	shadow.z_index = 0
	_npc_node.add_child(shadow)

	# ── Outline underlays (z=0, behind all parts at z≥1) ──
	_npc_node.add_child(_make_rect_part(Vector2(38.0, 24.0), VT.OUTLINE_DARK, Vector2(0.0, -28.0), 0))
	_npc_node.add_child(_make_rect_part(Vector2(30.0, 28.0), VT.OUTLINE_DARK, Vector2(0.0, -56.0), 0))
	_npc_node.add_child(_make_rect_part(Vector2(22.0, 22.0), VT.OUTLINE_DARK, Vector2(0.0, -13.0), 0))

	# Boots (slate)
	_npc_node.add_child(_make_rect_part(Vector2(9.0, 6.0), VT.NPC_BOOTS, Vector2(-5.0, -4.0), 1))
	_npc_node.add_child(_make_rect_part(Vector2(9.0, 6.0), VT.NPC_BOOTS, Vector2(5.0, -4.0), 1))

	# Legs (dark slate trousers)
	_npc_node.add_child(_make_rect_part(Vector2(8.0, 14.0), VT.NPC_PANTS, Vector2(-5.0, -12.0), 2))
	_npc_node.add_child(_make_rect_part(Vector2(8.0, 14.0), VT.NPC_PANTS, Vector2(5.0, -12.0), 2))

	# Arms
	_npc_node.add_child(_make_rect_part(Vector2(7.0, 15.0), VT.NPC_BODY.darkened(0.18), Vector2(-14.0, -28.0), 2))
	_npc_node.add_child(_make_rect_part(Vector2(7.0, 15.0), VT.NPC_BODY.darkened(0.18), Vector2(14.0, -28.0), 2))

	# Body / shirt (amber — distinct from player)
	_npc_node.add_child(_make_rect_part(Vector2(20.0, 18.0), VT.NPC_BODY, Vector2(0.0, -28.0), 3))

	# Bot badge — cyan square on chest
	_npc_node.add_child(_make_rect_part(Vector2(6.0, 6.0), VT.NPC_BADGE, Vector2(0.0, -30.0), 4))
	_npc_node.add_child(_make_rect_part(Vector2(3.0, 3.0), VT.NPC_BADGE_DK, Vector2(0.0, -30.0), 5))

	# Collar
	_npc_node.add_child(_make_rect_part(Vector2(10.0, 4.0), VT.AVATAR_COLLAR, Vector2(0.0, -38.0), 4))

	# Head (square chibi)
	_npc_node.add_child(_make_rect_part(Vector2(26.0, 22.0), VT.AVATAR_SKIN, Vector2(0.0, -56.0), 5))

	# Head top highlight
	_npc_node.add_child(_make_rect_part(Vector2(20.0, 4.0), Color(VT.AVATAR_SKIN_HI.r, VT.AVATAR_SKIN_HI.g, VT.AVATAR_SKIN_HI.b, 0.50), Vector2(0.0, -65.0), 6))

	# Cheek blush
	_npc_node.add_child(_make_rect_part(Vector2(5.0, 3.0), Color(VT.AVATAR_CHEEK.r, VT.AVATAR_CHEEK.g, VT.AVATAR_CHEEK.b, 0.55), Vector2(-10.0, -52.0), 6))
	_npc_node.add_child(_make_rect_part(Vector2(5.0, 3.0), Color(VT.AVATAR_CHEEK.r, VT.AVATAR_CHEEK.g, VT.AVATAR_CHEEK.b, 0.55), Vector2(10.0, -52.0), 6))

	# Mouth
	_npc_node.add_child(_make_rect_part(Vector2(8.0, 3.0), VT.AVATAR_MOUTH, Vector2(0.0, -49.0), 6))

	# Hair — flat top (navy, bot style)
	_npc_node.add_child(_make_rect_part(Vector2(26.0, 9.0), VT.NPC_HAIR, Vector2(0.0, -67.0), 6))
	# Hair — right side
	_npc_node.add_child(_make_rect_part(Vector2(6.0, 10.0), VT.NPC_HAIR, Vector2(11.0, -61.0), 6))
	# Hair — front fringe (flat bot cut)
	_npc_node.add_child(_make_rect_part(Vector2(10.0, 5.0), VT.NPC_HAIR, Vector2(0.0, -62.0), 6))

	# Eyes (blue-tinted — bot glow)
	_npc_node.add_child(_make_rect_part(Vector2(5.0, 5.0), VT.NPC_EYE, Vector2(-6.0, -56.0), 7))
	_npc_node.add_child(_make_rect_part(Vector2(5.0, 5.0), VT.NPC_EYE, Vector2(6.0, -56.0), 7))

	# Eye shine (cyan glow)
	_npc_node.add_child(_make_rect_part(Vector2(3.0, 3.0), Color(VT.NPC_SHINE.r, VT.NPC_SHINE.g, VT.NPC_SHINE.b, 0.95), Vector2(-5.0, -57.0), 8))
	_npc_node.add_child(_make_rect_part(Vector2(3.0, 3.0), Color(VT.NPC_SHINE.r, VT.NPC_SHINE.g, VT.NPC_SHINE.b, 0.95), Vector2(7.0, -57.0), 8))

	var name_label: Label = Label.new()
	name_label.text = NPC_NAME
	name_label.position = Vector2(-32.0, -86.0)
	name_label.add_theme_color_override("font_color", VT.NPC_LABEL)
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
