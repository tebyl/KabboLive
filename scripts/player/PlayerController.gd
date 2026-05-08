extends RefCounted


const PLAYER_STEP_DURATION = 0.18

const IsoGridScript = preload("res://scripts/room/IsoGrid.gd")
const IsoGrid = IsoGridScript
const VT = preload("res://scripts/visual/VisualTheme.gd")

var player_node: Sprite2D
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
var avatar_facing_sign = 1.0
var active_move_tween: Tween
var active_visual_tween: Tween


func _init(p_player_node: Sprite2D, p_iso_grid, start_cell) :
	player_node = p_player_node
	iso_grid = p_iso_grid
	player_cell = start_cell
	setup_player()


func setup_player() :
	player_node.position = iso_grid.grid_to_iso(player_cell)
	player_node.texture = null
	player_node.centered = true
	player_node.offset = Vector2.ZERO
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


func update_avatar_color(new_color: Color) :
	if avatar_body != null:
		avatar_body.color = new_color
	if avatar_left_arm != null:
		avatar_left_arm.color = new_color.darkened(0.20)
	if avatar_right_arm != null:
		avatar_right_arm.color = new_color.darkened(0.20)


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
	stop_active_tweens()
	active_move_tween = player_node.create_tween()
	active_move_tween.tween_property(player_node, "position", iso_grid.grid_to_iso(next_cell), PLAYER_STEP_DURATION)
	active_move_tween.finished.connect(finish_player_step)

	active_visual_tween = player_node.create_tween()
	animate_avatar_step(step_direction, PLAYER_STEP_DURATION, active_visual_tween)


func finish_player_step() :
	stop_active_tweens()
	set_avatar_idle_pose()
	move_next_step()


func setup_avatar_visual() :
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
	# Torso + shoulder span outline
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(38, 24)), VT.OUTLINE_DARK, Vector2(0, -28), 0
	))
	# Head outline
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(30, 28)), VT.OUTLINE_DARK, Vector2(0, -56), 0
	))
	# Legs outline
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
		get_rect_polygon(Vector2(8, 14)), VT.AVATAR_PANTS, Vector2(-5, -12), 2
	)
	avatar_root.add_child(avatar_left_leg)
	avatar_right_leg = create_avatar_part(
		get_rect_polygon(Vector2(8, 14)), VT.AVATAR_PANTS, Vector2(5, -12), 2
	)
	avatar_root.add_child(avatar_right_leg)

	# Arms (drawn before body; body overlaps at shoulder seam)
	avatar_left_arm = create_avatar_part(
		get_rect_polygon(Vector2(7, 15)), VT.AVATAR_SHIRT.darkened(0.20), Vector2(-14, -28), 2
	)
	avatar_root.add_child(avatar_left_arm)
	avatar_right_arm = create_avatar_part(
		get_rect_polygon(Vector2(7, 15)), VT.AVATAR_SHIRT.darkened(0.20), Vector2(14, -28), 2
	)
	avatar_root.add_child(avatar_right_arm)

	# Body / shirt
	avatar_body = create_avatar_part(
		get_rect_polygon(Vector2(20, 18)), VT.AVATAR_SHIRT, Vector2(0, -28), 3
	)
	avatar_root.add_child(avatar_body)

	# Shirt highlight stripe
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(14, 4)), VT.AVATAR_SHIRT_HI, Vector2(0, -33), 4
	))

	# Collar
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(10, 4)), VT.AVATAR_COLLAR, Vector2(0, -38), 4
	))

	# Head (square pixel-art chibi)
	avatar_head = create_avatar_part(
		get_rect_polygon(Vector2(26, 22)), VT.AVATAR_SKIN, Vector2(0, -56), 5
	)
	avatar_root.add_child(avatar_head)

	# Head top-edge highlight
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(20, 4)), Color(VT.AVATAR_SKIN_HI.r, VT.AVATAR_SKIN_HI.g, VT.AVATAR_SKIN_HI.b, 0.50), Vector2(0, -65), 6
	))

	# Cheek blush
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(5, 3)), Color(VT.AVATAR_CHEEK.r, VT.AVATAR_CHEEK.g, VT.AVATAR_CHEEK.b, 0.55), Vector2(-10, -52), 6
	))
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(5, 3)), Color(VT.AVATAR_CHEEK.r, VT.AVATAR_CHEEK.g, VT.AVATAR_CHEEK.b, 0.55), Vector2(10, -52), 6
	))

	# Mouth
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(8, 3)), VT.AVATAR_MOUTH, Vector2(0, -49), 6
	))

	# Hair — thick top block
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(28, 10)), VT.AVATAR_HAIR, Vector2(0, -67), 6
	))
	# Hair — left side
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(6, 12)), VT.AVATAR_HAIR, Vector2(-12, -61), 6
	))
	# Hair — front bang
	avatar_root.add_child(create_avatar_part(
		get_rect_polygon(Vector2(8, 6)), VT.AVATAR_HAIR, Vector2(7, -62), 6
	))

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
