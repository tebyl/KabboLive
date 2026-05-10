extends RefCounted


const PLAYER_STEP_DURATION = 0.18

const IsoGridScript = preload("res://scripts/room/IsoGrid.gd")
const IsoGrid = IsoGridScript
const VT = preload("res://scripts/visual/VisualTheme.gd")

var player_node: Node2D
var iso_grid
var player_cell
var current_path: Array[Vector2i] = []
var is_moving = false
var avatar_root: Node2D
var avatar_shadow: Polygon2D
var avatar_body: Polygon2D
var avatar_head: Polygon2D
var avatar_left_leg: Polygon2D
var avatar_right_leg: Polygon2D
var avatar_left_arm: Polygon2D
var avatar_right_arm: Polygon2D
var avatar_shirt_hi: Polygon2D
var avatar_skin_hi: Polygon2D
var avatar_cheek_l: Polygon2D
var avatar_cheek_r: Polygon2D
var avatar_hair_root: Node2D
var _current_shirt_color: Color
var _current_pants_color: Color
var _current_hair_color: Color
var _current_skin_tone: Color
var _current_hair_style: String = "short"
var avatar_facing_sign = 1.0
var active_move_tween: Tween
var active_visual_tween: Tween


func _init(p_player_node: Node2D, p_iso_grid, start_cell) :
	player_node = p_player_node
	iso_grid = p_iso_grid
	player_cell = start_cell
	setup_player()


func setup_player() :
	player_node.position = iso_grid.grid_to_iso(player_cell)
	if player_node.has_method("set_direction"):
		Callable(player_node, "set_direction").call("south")
	elif player_node is Sprite2D:
		var sprite := player_node as Sprite2D
		sprite.texture = null
		sprite.centered = true
		sprite.offset = Vector2.ZERO
	setup_avatar_visual()
	set_avatar_idle_pose()
	update_z_index()


func get_player_cell() -> Vector2i:
	return player_cell


func teleport_to_cell(target_cell) :
	stop_motion()
	player_cell = target_cell
	player_node.position = iso_grid.grid_to_iso(player_cell)
	update_z_index()
	set_avatar_idle_pose()


func update_avatar_color(new_color: Color) -> void:
	_current_shirt_color = new_color
	if avatar_body != null:
		avatar_body.color = new_color
	if avatar_left_arm != null:
		avatar_left_arm.color = new_color.darkened(0.20)
	if avatar_right_arm != null:
		avatar_right_arm.color = new_color.darkened(0.20)
	if avatar_shirt_hi != null:
		avatar_shirt_hi.color = new_color.lightened(0.35)


func is_currently_moving() :
	return is_moving


func update_z_index() :
	player_node.z_index = iso_grid.get_draw_z_index(player_cell) + 5


func stop_motion() :
	stop_active_tweens()
	player_node.position = iso_grid.grid_to_iso(player_cell)
	current_path.clear()
	is_moving = false
	set_avatar_idle_pose()


func move_along_path(path: Array[Vector2i]) :
	if is_moving:
		return false

	if path.is_empty():
		return false

	current_path.clear()

	for point in path:
		current_path.append(point)

	if current_path.size() > 0:
		current_path.remove_at(0)

	move_next_step()
	return true


func move_next_step() :
	if current_path.is_empty():
		stop_active_tweens()
		is_moving = false
		set_avatar_idle_pose()
		return

	is_moving = true

	var previous_cell = player_cell
	var next_cell = current_path[0]
	current_path.remove_at(0)
	player_cell = next_cell
	update_z_index()

	var step_direction = next_cell - previous_cell
	if player_node.has_method("set_iso_direction_from_grid_delta"):
		Callable(player_node, "set_iso_direction_from_grid_delta").call(step_direction)
	stop_active_tweens()
	active_move_tween = player_node.create_tween()
	active_move_tween.tween_property(player_node, "position", iso_grid.grid_to_iso(next_cell), PLAYER_STEP_DURATION)
	active_move_tween.finished.connect(finish_player_step)

	if not player_node.has_method("set_direction"):
		active_visual_tween = player_node.create_tween()
		animate_avatar_step(step_direction, PLAYER_STEP_DURATION, active_visual_tween)


func finish_player_step() :
	stop_active_tweens()
	set_avatar_idle_pose()
	move_next_step()


func setup_avatar_visual() -> void:
	if player_node.has_method("set_direction"):
		return

	_current_shirt_color = VT.AVATAR_SHIRT
	_current_pants_color = VT.AVATAR_PANTS
	_current_hair_color = VT.AVATAR_HAIR
	_current_skin_tone = VT.AVATAR_SKIN
	_current_hair_style = "short"

	clear_children(player_node)

	avatar_root = Node2D.new()
	avatar_root.name = "AvatarRoot"
	player_node.add_child(avatar_root)

	# Shadow — wide flat diamond below feet, outside avatar_root so it doesn't lean
	avatar_shadow = create_avatar_part(
		PackedVector2Array([Vector2(0, -7), Vector2(26, 0), Vector2(0, 7), Vector2(-26, 0)]),
		VT.SHADOW_MED, Vector2(0, 5), 0
	)
	player_node.add_child(avatar_shadow)

	# ── Outline underlays (z=0, rendered behind everything at z≥1) ──
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(38, 24)), VT.OUTLINE_DARK, Vector2(0, -28), 0
	))
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(30, 28)), VT.OUTLINE_DARK, Vector2(0, -56), 0
	))
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(22, 22)), VT.OUTLINE_DARK, Vector2(0, -13), 0
	))

	# Boots
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(9, 6)), VT.AVATAR_BOOTS, Vector2(-5, -4), 1
	))
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(9, 6)), VT.AVATAR_BOOTS, Vector2(5, -4), 1
	))

	# Legs (pants)
	avatar_left_leg = create_avatar_part(
		get_rect_polygon(Vector2(8, 14)), _current_pants_color, Vector2(-5, -12), 2
	)
	avatar_root.add_child(avatar_left_leg)
	avatar_right_leg = create_avatar_part(
		get_rect_polygon(Vector2(8, 14)), _current_pants_color, Vector2(5, -12), 2
	)
	avatar_root.add_child(avatar_right_leg)

	# Arms (drawn before body; body overlaps at shoulder seam)
	avatar_left_arm = create_avatar_part(
		get_rect_polygon(Vector2(7, 15)), _current_shirt_color.darkened(0.20), Vector2(-14, -28), 2
	)
	avatar_root.add_child(avatar_left_arm)
	avatar_right_arm = create_avatar_part(
		get_rect_polygon(Vector2(7, 15)), _current_shirt_color.darkened(0.20), Vector2(14, -28), 2
	)
	avatar_root.add_child(avatar_right_arm)

	# Body / shirt
	avatar_body = create_avatar_part(
		get_rect_polygon(Vector2(20, 18)), _current_shirt_color, Vector2(0, -28), 3
	)
	avatar_root.add_child(avatar_body)

	# Shirt highlight stripe
	avatar_shirt_hi = create_avatar_part(
		get_rect_polygon(Vector2(14, 4)), _current_shirt_color.lightened(0.35), Vector2(0, -33), 4
	)
	avatar_root.add_child(avatar_shirt_hi)

	# Collar
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(10, 4)), VT.AVATAR_COLLAR, Vector2(0, -38), 4
	))

	# Head
	avatar_head = create_avatar_part(
		get_rect_polygon(Vector2(26, 22)), _current_skin_tone, Vector2(0, -56), 5
	)
	avatar_root.add_child(avatar_head)

	# Head top-edge highlight
	var shi: Color = Color(
		min(_current_skin_tone.r + 0.10, 1.0),
		min(_current_skin_tone.g + 0.12, 1.0),
		min(_current_skin_tone.b + 0.12, 1.0), 0.50)
	avatar_skin_hi = create_avatar_part(
		get_rect_polygon(Vector2(20, 4)), shi, Vector2(0, -65), 6
	)
	avatar_root.add_child(avatar_skin_hi)

	# Cheek blush
	var cheek: Color = Color(VT.AVATAR_CHEEK.r, VT.AVATAR_CHEEK.g, VT.AVATAR_CHEEK.b, 0.55)
	avatar_cheek_l = create_avatar_part(get_rect_polygon(Vector2(5, 3)), cheek, Vector2(-10, -52), 6)
	avatar_root.add_child(avatar_cheek_l)
	avatar_cheek_r = create_avatar_part(get_rect_polygon(Vector2(5, 3)), cheek, Vector2(10, -52), 6)
	avatar_root.add_child(avatar_cheek_r)

	# Mouth
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(8, 3)), VT.AVATAR_MOUTH, Vector2(0, -49), 6
	))

	# Hair — managed in avatar_hair_root for dynamic rebuilding
	avatar_hair_root = Node2D.new()
	avatar_hair_root.name = "HairRoot"
	avatar_root.add_child(avatar_hair_root)
	_rebuild_hair(_current_hair_color, _current_hair_style)

	# Eyes
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(5, 5)), VT.AVATAR_EYE, Vector2(-6, -56), 7
	))
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(5, 5)), VT.AVATAR_EYE, Vector2(6, -56), 7
	))

	# Eye shine
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(2, 2)), VT.AVATAR_SHINE, Vector2(-5, -57), 8
	))
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(2, 2)), VT.AVATAR_SHINE, Vector2(7, -57), 8
	))


func _rebuild_hair(hc: Color, hs: String) -> void:
	if avatar_hair_root == null:
		return
	clear_children(avatar_hair_root)
	match hs:
		"short":
			avatar_hair_root.add_child(create_avatar_part(get_rect_polygon(Vector2(28, 10)), hc, Vector2(0, -67), 6))
			avatar_hair_root.add_child(create_avatar_part(get_rect_polygon(Vector2(6, 12)), hc, Vector2(-12, -61), 6))
			avatar_hair_root.add_child(create_avatar_part(get_rect_polygon(Vector2(8, 6)), hc, Vector2(7, -62), 6))
		"long":
			avatar_hair_root.add_child(create_avatar_part(get_rect_polygon(Vector2(28, 10)), hc, Vector2(0, -67), 6))
			avatar_hair_root.add_child(create_avatar_part(get_rect_polygon(Vector2(6, 22)), hc, Vector2(-14, -65), 6))
			avatar_hair_root.add_child(create_avatar_part(get_rect_polygon(Vector2(6, 22)), hc, Vector2(14, -65), 6))
			avatar_hair_root.add_child(create_avatar_part(get_rect_polygon(Vector2(8, 6)), hc, Vector2(7, -62), 6))
		"bald":
			pass


func apply_profile(profile_data: Dictionary) -> void:
	var sc: Color = profile_data.get("shirt_color", VT.AVATAR_SHIRT)
	var pc: Color = profile_data.get("pants_color", VT.AVATAR_PANTS)
	var hc: Color = profile_data.get("hair_color", VT.AVATAR_HAIR)
	var st: Color = profile_data.get("skin_tone", VT.AVATAR_SKIN)
	var hs: String = str(profile_data.get("hair_style", "short"))
	_current_shirt_color = sc
	_current_pants_color = pc
	_current_hair_color = hc
	_current_skin_tone = st
	_current_hair_style = hs
	if avatar_body != null:
		avatar_body.color = sc
	if avatar_left_arm != null:
		avatar_left_arm.color = sc.darkened(0.20)
	if avatar_right_arm != null:
		avatar_right_arm.color = sc.darkened(0.20)
	if avatar_shirt_hi != null:
		avatar_shirt_hi.color = sc.lightened(0.35)
	if avatar_left_leg != null:
		avatar_left_leg.color = pc
	if avatar_right_leg != null:
		avatar_right_leg.color = pc
	if avatar_head != null:
		avatar_head.color = st
	if avatar_skin_hi != null:
		avatar_skin_hi.color = Color(
			min(st.r + 0.10, 1.0), min(st.g + 0.12, 1.0), min(st.b + 0.12, 1.0), 0.50)
	_rebuild_hair(hc, hs)


func create_avatar_part(polygon: PackedVector2Array, color: Color, position, z_index) -> Polygon2D:
	var part: Polygon2D = Polygon2D.new()
	part.polygon = polygon
	part.color = color
	part.position = position
	part.z_index = z_index
	return part


func get_rect_polygon(size) -> PackedVector2Array:
	var half_size = size / 2.0

	return PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(half_size.x, half_size.y),
		Vector2(-half_size.x, half_size.y)
	])


func get_circle_polygon(radius, point_count) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()

	for index in range(point_count):
		var angle = TAU * float(index) / float(point_count)
		points.append(Vector2(cos(angle), sin(angle)) * radius)

	return points


func set_avatar_idle_pose() :
	if avatar_root == null:
		return

	avatar_root.position = Vector2.ZERO
	avatar_root.rotation = 0.0
	avatar_root.scale = Vector2(avatar_facing_sign, 1.0)
	avatar_left_leg.position = Vector2(-5, -12)
	avatar_right_leg.position = Vector2(5, -12)
	avatar_left_leg.rotation = 0.0
	avatar_right_leg.rotation = 0.0
	avatar_shadow.scale = Vector2.ONE
	avatar_body.position = Vector2(0, -28)
	avatar_head.position = Vector2(0, -56)


func animate_avatar_step(step_direction, step_duration, tween: Tween) :
	if avatar_root == null:
		return

	set_avatar_facing(step_direction)
	var lean: float = get_avatar_direction_lean(step_direction)
	var half_duration: float = step_duration / 2.0

	tween.set_parallel(true)
	tween.tween_property(avatar_root, "position", Vector2(0, -5), half_duration)
	tween.tween_property(avatar_root, "rotation", lean, half_duration)
	tween.tween_property(avatar_shadow, "scale", Vector2(0.82, 0.82), half_duration)
	tween.tween_property(avatar_left_leg, "rotation", -0.34, half_duration)
	tween.tween_property(avatar_right_leg, "rotation", 0.34, half_duration)
	tween.tween_property(avatar_body, "position", Vector2(0, -30), half_duration)
	tween.tween_property(avatar_head, "position", Vector2(2 * avatar_facing_sign, -58), half_duration)
	tween.chain()
	tween.set_parallel(true)
	tween.tween_property(avatar_root, "position", Vector2.ZERO, half_duration)
	tween.tween_property(avatar_root, "rotation", 0.0, half_duration)
	tween.tween_property(avatar_shadow, "scale", Vector2.ONE, half_duration)
	tween.tween_property(avatar_left_leg, "rotation", 0.22, half_duration)
	tween.tween_property(avatar_right_leg, "rotation", -0.22, half_duration)
	tween.tween_property(avatar_body, "position", Vector2(0, -28), half_duration)
	tween.tween_property(avatar_head, "position", Vector2(0, -56), half_duration)


func get_avatar_direction_lean(step_direction) -> float:
	if step_direction.x > 0 or step_direction.y < 0:
		return 0.08

	if step_direction.x < 0 or step_direction.y > 0:
		return -0.08

	return 0.0


func set_avatar_facing(step_direction) :
	if step_direction.x > 0 or step_direction.y < 0:
		avatar_facing_sign = 1.0
	elif step_direction.x < 0 or step_direction.y > 0:
		avatar_facing_sign = -1.0

	avatar_root.scale = Vector2(avatar_facing_sign, 1.0)


func clear_children(parent: Node) :
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()


func stop_active_tweens() :
	if active_move_tween != null and active_move_tween.is_valid():
		active_move_tween.kill()

	if active_visual_tween != null and active_visual_tween.is_valid():
		active_visual_tween.kill()

	active_move_tween = null
	active_visual_tween = null
