extends Node2D

const TILE_WIDTH: int = 64
const TILE_HEIGHT: int = 32
const ISO_OFFSET: Vector2 = Vector2(550, 180)

var floor_node: Node2D
var blocks_node: Node2D
var player_node: Sprite2D
var is_initialized: bool = false

var iso_grid: IsoGrid
var pathfinding_manager: PathfindingManager
var player_controller: PlayerController
var furniture_visual_factory: FurnitureVisualFactory
var furniture_manager: FurnitureManager
var inventory_manager: InventoryManager
var room_manager: RoomManager
var room_save_service: RoomSaveService
var game_ui: GameUI
var camera_controller: CameraController


func _ready() -> void:
	if not resolve_required_nodes():
		return

	room_manager = RoomManager.new()
	var initial_room_size: Vector2i = room_manager.get_current_room_size()
	iso_grid = IsoGrid.new(
		floor_node,
		initial_room_size.x,
		initial_room_size.y,
		TILE_WIDTH,
		TILE_HEIGHT,
		ISO_OFFSET
	)
	pathfinding_manager = PathfindingManager.new(initial_room_size.x, initial_room_size.y, TILE_WIDTH, TILE_HEIGHT)
	player_controller = PlayerController.new(player_node, iso_grid, room_manager.get_current_player_start_cell())
	furniture_visual_factory = FurnitureVisualFactory.new(blocks_node, iso_grid)
	inventory_manager = InventoryManager.new()
	room_save_service = RoomSaveService.new()
	game_ui = GameUI.new(self)
	camera_controller = CameraController.new(self, iso_grid)
	furniture_manager = FurnitureManager.new(
		iso_grid,
		pathfinding_manager,
		player_controller,
		furniture_visual_factory,
		room_manager.get_current_furniture_items()
	)
	game_ui.set_room_name(room_manager.get_current_room_name())
	game_ui.set_status_message("Sin seleccion")
	is_initialized = true


func _process(delta: float) -> void:
	if not is_initialized:
		return

	camera_controller.process(delta)


func _input(event: InputEvent) -> void:
	if not is_initialized:
		return

	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey

		if key_event.pressed and not key_event.echo:
			handle_key_press(key_event.keycode)

	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton

		if camera_controller.handle_mouse_button(mouse_event):
			return

		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			handle_left_click(mouse_event.position)


func handle_key_press(keycode: Key) -> void:
	match keycode:
		KEY_1:
			select_inventory_item(0)
		KEY_2:
			select_inventory_item(1)
		KEY_3:
			select_inventory_item(2)
		KEY_ESCAPE:
			cancel_selection()
		KEY_F1:
			switch_room("lobby")
		KEY_F2:
			switch_room("room_small")
		KEY_F3:
			switch_room("room_large")
		KEY_DELETE:
			if furniture_manager.delete_selected_furniture():
				game_ui.report_status("Mueble eliminado")
		KEY_M:
			if furniture_manager.start_move_selected_furniture():
				game_ui.report_status("Modo mover")
		KEY_R:
			if furniture_manager.rotate_selected_furniture():
				game_ui.report_status("Mueble rotado")
			elif furniture_manager.has_selected_placed_furniture():
				game_ui.report_status("No se puede rotar aqui")
		KEY_S:
			save_room()
		KEY_L:
			load_room()


func handle_left_click(screen_position: Vector2) -> void:
	var clicked_cell: Vector2i = iso_grid.iso_to_grid(camera_controller.screen_to_world(screen_position))

	if inventory_manager.has_selected_furniture():
		var furniture: FurnitureData = inventory_manager.create_selected_furniture(clicked_cell)

		if furniture_manager.place_furniture(furniture):
			game_ui.report_status("Mueble colocado en: " + str(clicked_cell))
		else:
			game_ui.report_status("No se puede colocar aqui")
		return

	if furniture_manager.is_move_mode_active():
		if furniture_manager.move_selected_furniture(clicked_cell):
			game_ui.report_status("Mueble movido a: " + str(clicked_cell))
		else:
			game_ui.report_status("No se puede colocar aqui")
		return

	if furniture_manager.select_furniture_at_cell(clicked_cell):
		game_ui.report_status("Mueble seleccionado en: " + str(furniture_manager.get_selected_cell()))
		return

	if not iso_grid.is_valid_cell(clicked_cell):
		game_ui.report_status("Fuera de la sala: " + str(clicked_cell))
		return

	if pathfinding_manager.is_point_solid(clicked_cell):
		game_ui.report_status("Ocupado por mueble")
		return

	var path: Array[Vector2i] = pathfinding_manager.get_path(player_controller.get_player_cell(), clicked_cell)

	if path.is_empty():
		game_ui.report_status("No hay camino disponible.")
		return

	player_controller.move_along_path(path)


func select_inventory_item(index: int) -> void:
	inventory_manager.select_index(index)
	furniture_manager.clear_selection()
	var selected_type: String = inventory_manager.get_selected_type_text()
	print("Mueble seleccionado: " + selected_type)
	game_ui.set_status_message("Modo colocar: " + selected_type)


func cancel_selection() -> void:
	inventory_manager.cancel_selection()
	furniture_manager.clear_selection()
	game_ui.report_status("Sin seleccion")


func save_room() -> void:
	sync_current_room_furniture()

	if room_save_service.save_rooms(room_manager.get_all_rooms()):
		game_ui.report_status("Sala guardada")
	else:
		game_ui.report_status("No se pudo guardar la sala")


func load_room() -> void:
	var load_result: Dictionary = room_save_service.load_rooms(Callable(game_ui, "report_status"))
	var status: StringName = StringName(load_result.get("status", ""))

	if status == &"missing" or status == &"legacy_missing_migration":
		game_ui.report_status("No hay sala guardada")
		return

	if status == &"invalid_file":
		game_ui.report_status("Advertencia: salas guardadas invalidas")
		return

	var loaded_rooms_variant: Variant = load_result.get("rooms", [])
	var loaded_rooms: Array[RoomData] = []

	if loaded_rooms_variant is Array:
		var loaded_rooms_array: Array = loaded_rooms_variant as Array

		for room_variant: Variant in loaded_rooms_array:
			if room_variant is RoomData:
				loaded_rooms.append(room_variant as RoomData)

	room_manager.apply_saved_rooms(loaded_rooms)
	apply_current_room_state()
	game_ui.report_status("Sala cargada")


func switch_room(room_id: String) -> void:
	if player_controller.is_currently_moving():
		game_ui.report_status("No se puede cambiar de sala mientras caminas")
		return

	if room_id == room_manager.current_room_id:
		game_ui.set_room_name(room_manager.get_current_room_name())
		return

	sync_current_room_furniture()

	if not room_manager.switch_room(room_id):
		game_ui.report_status("Sala invalida")
		return

	apply_current_room_state()
	game_ui.report_status("Sala actual: " + room_manager.get_current_room_name())


func sync_current_room_furniture() -> void:
	room_manager.set_current_furniture_items(furniture_manager.get_furniture_items())


func apply_current_room_state() -> void:
	var room_size: Vector2i = room_manager.get_current_room_size()
	var player_start_cell: Vector2i = room_manager.get_current_player_start_cell()
	var room_furniture_items: Array[FurnitureData] = room_manager.get_current_furniture_items()

	player_controller.stop_motion()
	inventory_manager.cancel_selection()
	furniture_manager.clear_selection()
	iso_grid.set_room_size(room_size.x, room_size.y)
	pathfinding_manager.reconfigure_grid(room_size.x, room_size.y)
	player_controller.teleport_to_cell(player_start_cell)
	furniture_manager.replace_furniture_items(room_furniture_items, Callable(game_ui, "report_status"))
	camera_controller.center_on_room()
	game_ui.set_room_name(room_manager.get_current_room_name())


func resolve_required_nodes() -> bool:
	var floor_node_candidate: Node = get_node_or_null("Floor")
	var blocks_node_candidate: Node = get_node_or_null("Blocks")
	var player_node_candidate: Node = get_node_or_null("Player")
	var is_valid: bool = true

	if floor_node_candidate is Node2D:
		floor_node = floor_node_candidate as Node2D
	else:
		push_error("Main.gd requiere un nodo hijo Node2D llamado 'Floor'.")
		is_valid = false

	if blocks_node_candidate is Node2D:
		blocks_node = blocks_node_candidate as Node2D
	else:
		push_error("Main.gd requiere un nodo hijo Node2D llamado 'Blocks'.")
		is_valid = false

	if player_node_candidate is Sprite2D:
		player_node = player_node_candidate as Sprite2D
	else:
		push_error("Main.gd requiere un nodo hijo Sprite2D llamado 'Player'.")
		is_valid = false

	return is_valid
