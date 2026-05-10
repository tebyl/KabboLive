extends RefCounted


const CAMERA_MOVE_SPEED = 420.0
const CAMERA_ZOOM_STEP = 0.1
const CAMERA_INITIAL_ZOOM = 0.90
const CAMERA_MIN_ZOOM = 0.6
const CAMERA_MAX_ZOOM = 1.8
const CAMERA_BOUNDS_MARGIN = 140.0
const CAMERA_VERTICAL_OFFSET = -40.0

var root: Node2D
var iso_grid
var room_camera: Camera2D
var camera_bounds: Rect2

const IsoGridScript = preload("res://scripts/room/IsoGrid.gd")
const IsoGrid = IsoGridScript


func _init(p_root: Node2D, p_iso_grid) :
	root = p_root
	iso_grid = p_iso_grid
	setup_camera()


func setup_camera() :
	var existing_camera: Node = root.get_node_or_null("Camera2D")

	if existing_camera is Camera2D:
		room_camera = existing_camera as Camera2D
	else:
		room_camera = Camera2D.new()
		room_camera.name = "Camera2D"
		root.add_child(room_camera)

	camera_bounds = iso_grid.get_room_bounds(CAMERA_BOUNDS_MARGIN)
	room_camera.position = camera_bounds.get_center() + Vector2(0.0, CAMERA_VERTICAL_OFFSET)
	room_camera.zoom = Vector2(CAMERA_INITIAL_ZOOM, CAMERA_INITIAL_ZOOM)
	room_camera.enabled = true
	room_camera.make_current()
	clamp_camera_position()


func process(delta) :
	if room_camera == null:
		return

	var direction = Vector2.ZERO

	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0

	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0

	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0

	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0

	if direction == Vector2.ZERO:
		return

	room_camera.position += direction.normalized() * CAMERA_MOVE_SPEED * delta / room_camera.zoom.x
	clamp_camera_position()


func handle_mouse_button(event: InputEventMouseButton) :
	if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		change_zoom(CAMERA_ZOOM_STEP)
		return true

	if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		change_zoom(-CAMERA_ZOOM_STEP)
		return true

	return false


func screen_to_world(screen_position) -> Vector2:
	var canvas_transform: Transform2D = root.get_viewport().get_canvas_transform()
	return canvas_transform.affine_inverse() * screen_position


func change_zoom(delta_zoom) :
	if room_camera == null:
		return

	var next_zoom = clampf(
		room_camera.zoom.x + delta_zoom,
		CAMERA_MIN_ZOOM,
		CAMERA_MAX_ZOOM
	)
	room_camera.zoom = Vector2(next_zoom, next_zoom)
	clamp_camera_position()


func center_on_room() :
	if room_camera == null:
		return

	refresh_bounds()
	room_camera.position = camera_bounds.get_center()
	clamp_camera_position()


func refresh_bounds() :
	camera_bounds = iso_grid.get_room_bounds(CAMERA_BOUNDS_MARGIN)


func clamp_camera_position() :
	if room_camera == null:
		return

	room_camera.position = Vector2(
		clampf(room_camera.position.x, camera_bounds.position.x, camera_bounds.end.x),
		clampf(room_camera.position.y, camera_bounds.position.y, camera_bounds.end.y)
	)
