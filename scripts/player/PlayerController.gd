extends RefCounted


const PLAYER_STEP_DURATION = 0.18

const IsoGridScript = preload("res://scripts/room/IsoGrid.gd")
const IsoGrid = IsoGridScript

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

	# Shadow
	avatar_shadow = create_avatar_part(
		PackedVector2Array([Vector2(0,-5), Vector2(20,0), Vector2(0,5), Vector2(-20,0)]),
		Color(0.04, 0.05, 0.06, 0.36), Vector2(0, 2), 0
	)
	player_node.add_child(avatar_shadow)

	# Boots
	var left_boot: Polygon2D = create_avatar_part(
		get_rect_polygon(Vector2(7, 5)), Color(0.22, 0.14, 0.08), Vector2(-5, -3), 1
	)
	avatar_root.add_child(left_boot)
	var right_boot: Polygon2D = create_avatar_part(
		get_rect_polygon(Vector2(7, 5)), Color(0.22, 0.14, 0.08), Vector2(5, -3), 1
	)
	avatar_root.add_child(right_boot)

	# Legs (pants)
	avatar_left_leg = create_avatar_part(
		get_rect_polygon(Vector2(7, 13)), Color(0.14, 0.16, 0.30), Vector2(-5, -11), 2
	)
	avatar_root.add_child(avatar_left_leg)
	avatar_right_leg = create_avatar_part(
		get_rect_polygon(Vector2(7, 13)), Color(0.14, 0.16, 0.30), Vector2(5, -11), 2
	)
	avatar_root.add_child(avatar_right_leg)

	# Body / shirt
	avatar_body = create_avatar_part(
		get_rect_polygon(Vector2(20, 20)), Color(0.14, 0.32, 0.72), Vector2(0, -28), 3
	)
	avatar_root.add_child(avatar_body)

	# Shirt pocket / highlight stripe
	var shirt_stripe: Polygon2D = create_avatar_part(
		get_rect_polygon(Vector2(14, 4)), Color(0.32, 0.58, 0.96), Vector2(0, -34), 4
	)
	avatar_root.add_child(shirt_stripe)

	# Collar
	var collar: Polygon2D = create_avatar_part(
		get_rect_polygon(Vector2(10, 4)), Color(0.90, 0.88, 0.84), Vector2(0, -39), 4
	)
	avatar_root.add_child(collar)

	# Head (chibi — big round)
	avatar_head = create_avatar_part(
		get_circle_polygon(13.0, 18), Color(0.82, 0.60, 0.42), Vector2(0, -56), 5
	)
	avatar_root.add_child(avatar_head)

	# Hair (top + sides)
	var hair_top: Polygon2D = create_avatar_part(
		get_rect_polygon(Vector2(24, 9)), Color(0.20, 0.12, 0.06), Vector2(0, -66), 6
	)
	avatar_root.add_child(hair_top)
	var hair_side: Polygon2D = create_avatar_part(
		get_rect_polygon(Vector2(6, 10)), Color(0.20, 0.12, 0.06), Vector2(-11, -60), 6
	)
	avatar_root.add_child(hair_side)

	# Eyes (bigger, pixel style)
	var left_eye: Polygon2D = create_avatar_part(
		get_rect_polygon(Vector2(5, 4)), Color(0.10, 0.08, 0.08), Vector2(-5, -56), 7
	)
	avatar_root.add_child(left_eye)
	var right_eye: Polygon2D = create_avatar_part(
		get_rect_polygon(Vector2(5, 4)), Color(0.10, 0.08, 0.08), Vector2(5, -56), 7
	)
	avatar_root.add_child(right_eye)

	# Eye shine
	var shine_l: Polygon2D = create_avatar_part(
		get_rect_polygon(Vector2(2, 2)), Color(1.0, 1.0, 1.0, 0.90), Vector2(-4, -57), 8
	)
	avatar_root.add_child(shine_l)
	var shine_r: Polygon2D = create_avatar_part(
		get_rect_polygon(Vector2(2, 2)), Color(1.0, 1.0, 1.0, 0.90), Vector2(6, -57), 8
	)
	avatar_root.add_child(shine_r)


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
	avatar_left_leg.position = Vector2(-5, -11)
	avatar_right_leg.position = Vector2(5, -11)
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
