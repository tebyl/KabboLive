extends Node2D

enum GameState { MAIN_MENU, ROOM_SELECT, IN_ROOM }

const TILE_WIDTH = 64
const TILE_HEIGHT = 32
const ISO_OFFSET = Vector2(550, 180)

# Preloads locales para evitar dependencias de class_name (Godot 4 global class shadowing errors)
const IsoGridScript = preload("res://scripts/room/IsoGrid.gd")
const PathfindingManagerScript = preload("res://scripts/room/PathfindingManager.gd")
const PlayerControllerScript = preload("res://scripts/player/PlayerController.gd")
const FurnitureVisualFactoryScript = preload("res://scripts/furniture/FurnitureVisualFactory.gd")
const FurnitureManagerScript = preload("res://scripts/furniture/FurnitureManager.gd")
const InventoryManagerScript = preload("res://scripts/inventory/InventoryManager.gd")
const RoomManagerScript = preload("res://scripts/room/RoomManager.gd")
const RoomSaveServiceScript = preload("res://scripts/save/RoomSaveService.gd")
const PlayerProfileManagerScript = preload("res://scripts/player/PlayerProfileManager.gd")
const ChatManagerScript = preload("res://scripts/chat/ChatManager.gd")
const GameUIScript = preload("res://scripts/ui/GameUI.gd")
const NpcManagerScript: GDScript = preload("res://scripts/npc/NpcManager.gd")
const CameraControllerScript = preload("res://scripts/camera/CameraController.gd")
const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const RoomDataScript = preload("res://scripts/room/RoomData.gd")

const IsoGrid = IsoGridScript
const PathfindingManager = PathfindingManagerScript
const PlayerController = PlayerControllerScript
const FurnitureVisualFactory = FurnitureVisualFactoryScript
const FurnitureManager = FurnitureManagerScript
const InventoryManager = InventoryManagerScript
const RoomManager = RoomManagerScript
const RoomSaveService = RoomSaveServiceScript
const PlayerProfileManager = PlayerProfileManagerScript
const ChatManager = ChatManagerScript
const GameUI = GameUIScript
const CameraController = CameraControllerScript
const FurnitureData = FurnitureDataScript
const RoomData = RoomDataScript

var floor_node: Node2D
var blocks_node: Node2D
var player_node: Sprite2D
var is_initialized = false
var current_state = GameState.MAIN_MENU

# Manager instances (se manejan como Variant por el ruido de símbolos en Godot)
var iso_grid
var pathfinding_manager
var player_controller
var furniture_visual_factory
var furniture_manager
var inventory_manager
var room_manager
var room_save_service
var player_profile_manager
var chat_manager
var game_ui
var camera_controller
var npc_manager
var npc_root: Node2D

func _ready():
	if not resolve_required_nodes():
		return

	room_manager = RoomManagerScript.new()
	var initial_room_size = room_manager.get_current_room_size()

	iso_grid = IsoGridScript.new(
		floor_node,
		initial_room_size.x,
		initial_room_size.y,
		TILE_WIDTH,
		TILE_HEIGHT,
		ISO_OFFSET
	)

	pathfinding_manager = PathfindingManagerScript.new(initial_room_size.x, initial_room_size.y, TILE_WIDTH, TILE_HEIGHT)
	player_profile_manager = PlayerProfileManagerScript.new()
	player_controller = PlayerControllerScript.new(player_node, iso_grid, room_manager.get_current_player_start_cell())
	player_controller.setup_avatar_visual()
	player_controller.update_avatar_color(player_profile_manager.avatar_color)
	furniture_visual_factory = FurnitureVisualFactoryScript.new(blocks_node, iso_grid)
	inventory_manager = InventoryManagerScript.new()
	room_save_service = RoomSaveServiceScript.new()
	chat_manager = ChatManagerScript.new()
	chat_manager.set_player_name(player_profile_manager.player_name)

	game_ui = GameUIScript.new(
		self,
		Callable(self, "on_enter_hotel"),
		Callable(self, "on_room_selected"),
		Callable(self, "on_back_to_rooms"),
		Callable(self, "on_save_profile"),
		Callable(self, "on_chat_submitted"),
		Callable(self, "on_catalog_selected")
	)

	game_ui.update_profile_ui(player_profile_manager.player_name, player_profile_manager.avatar_color)
	game_ui.setup_furniture_inspector_callbacks(
		Callable(self, "_on_inspector_move"),
		Callable(self, "_on_inspector_rotate"),
		Callable(self, "_on_inspector_delete"),
		Callable(self, "_on_inspector_close")
	)
	camera_controller = CameraControllerScript.new(self, iso_grid)

	furniture_manager = FurnitureManagerScript.new(
		iso_grid,
		pathfinding_manager,
		player_controller,
		furniture_visual_factory,
		room_manager.get_current_furniture_items()
	)

	npc_root = Node2D.new()
	npc_root.name = "Npcs"
	add_child(npc_root)
	npc_manager = NpcManagerScript.new(npc_root, iso_grid, pathfinding_manager, player_controller)

	is_initialized = true
	enter_state(GameState.MAIN_MENU)

func _process(delta):
	if not is_initialized:
		return
	if current_state == GameState.IN_ROOM:
		if not game_ui.is_chat_input_active() and not game_ui.is_profile_open():
			camera_controller.process(delta)
		game_ui.update_chat_bubble(player_node.global_position, delta)
		if npc_manager != null:
			npc_manager.process(delta)
			if npc_manager.is_active():
				game_ui.update_npc_bubble(npc_manager.get_world_position(), delta)

func _input(event):
	if not is_initialized:
		return
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if key_event.pressed and not key_event.echo:
			if current_state == GameState.IN_ROOM:
				if game_ui.is_profile_open():
					return
				if handle_chat_key_press(key_event.keycode):
					get_viewport().set_input_as_handled()
					return
				if game_ui.is_chat_input_active():
					return
			handle_key_press(key_event.keycode)
	elif event is InputEventMouseButton:
		if current_state == GameState.IN_ROOM:
			if game_ui.is_profile_open() or game_ui.is_chat_input_active():
				return
			var mouse_event = event as InputEventMouseButton
			camera_controller.handle_mouse_button(mouse_event)
			if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
				var world_pos = camera_controller.screen_to_world(mouse_event.position)
				var cell = iso_grid.iso_to_grid(world_pos)
				if furniture_manager.is_move_mode_active():
					if furniture_manager.move_selected_furniture(cell):
						var moved: Object = furniture_manager.get_selected_furniture()
						if moved != null:
							game_ui.update_furniture_inspector(moved)
						game_ui.set_status_message("Mueble movido — M mover | R rotar | Delete eliminar")
					else:
						game_ui.set_status_message("No se puede mover ahí")
				elif inventory_manager.has_selected_furniture():
					var new_furniture = inventory_manager.create_selected_furniture(cell)
					if new_furniture:
						if furniture_manager.place_furniture(new_furniture):
							game_ui.set_status_message("Mueble colocado")
						else:
							game_ui.set_status_message("No se puede colocar ahí")
				else:
					# Try to select furniture first
					if furniture_manager.select_furniture_at_cell(cell):
						var sel: Object = furniture_manager.get_selected_furniture()
						if sel != null:
							game_ui.show_furniture_inspector(sel)
						game_ui.set_status_message("Mueble seleccionado — M mover | R rotar | Delete eliminar")
					else:
						# If no furniture at cell, move player to cell
						if iso_grid.is_valid_cell(cell) and not pathfinding_manager.is_point_solid(cell):
							var player_cell = player_controller.get_player_cell()
							var path = pathfinding_manager.get_path(player_cell, cell)
							if path.size() > 0:
								if not player_controller.move_along_path(path):
									game_ui.set_status_message("El jugador ya se esta moviendo")

func resolve_required_nodes() -> bool:
	floor_node = get_node_or_null("Floor")
	blocks_node = get_node_or_null("Blocks")
	player_node = get_node_or_null("Player")
	return floor_node != null and blocks_node != null and player_node != null

func enter_state(new_state):
	current_state = new_state
	match current_state:
		GameState.MAIN_MENU:
			game_ui.show_main_menu()
		GameState.ROOM_SELECT:
			game_ui.show_room_selector(room_manager.get_all_rooms())
		GameState.IN_ROOM:
			game_ui.show_in_room()

func on_enter_hotel():
	enter_state(GameState.ROOM_SELECT)

func on_room_selected(room_id):
	switch_room(room_id)
	enter_state(GameState.IN_ROOM)

func on_back_to_rooms():
	enter_state(GameState.ROOM_SELECT)

func on_save_profile(new_name, new_color):
	player_profile_manager.update_profile(new_name, new_color)
	chat_manager.set_player_name(new_name)
	player_controller.update_avatar_color(new_color)

func handle_key_press(keycode):
	match keycode:
		KEY_ESCAPE:
			if current_state == GameState.IN_ROOM:
				if inventory_manager.has_selected_furniture():
					inventory_manager.cancel_selection()
					game_ui.set_catalog_selected_furniture("")
					game_ui.set_status_message("Sin seleccion")
				elif furniture_manager.has_selected_placed_furniture() or furniture_manager.is_move_mode_active():
					furniture_manager.clear_selection()
					game_ui.hide_furniture_inspector()
					game_ui.set_status_message("Sin seleccion")
				else:
					on_back_to_rooms()
			elif current_state == GameState.ROOM_SELECT:
				enter_state(GameState.MAIN_MENU)
		KEY_I:
			if current_state == GameState.IN_ROOM:
				game_ui.toggle_inventory(inventory_manager.items)
		KEY_P:
			if current_state == GameState.IN_ROOM:
				game_ui.toggle_profile()
		KEY_S:
			if current_state == GameState.IN_ROOM:
				save_current_room_state()
		KEY_L:
			if current_state == GameState.IN_ROOM:
				var loaded_rooms = room_save_service.load_rooms(Callable(game_ui, "report_status"))
				room_manager.apply_saved_rooms(loaded_rooms.get("rooms", []))
				var current_room = room_manager.get_current_room()
				if current_room:
					furniture_manager.replace_furniture_items(current_room.furniture_items, Callable(game_ui, "report_status"))
					game_ui.hide_furniture_inspector()
					if npc_manager != null:
						npc_manager.reapply_pathfinding_solid()
		KEY_1:
			if current_state == GameState.IN_ROOM:
				inventory_manager.select_index(0)
				var type1: String = inventory_manager.get_selected_type_text()
				game_ui.set_status_message("Modo colocar: " + _get_furniture_display_name(type1))
				game_ui.set_catalog_selected_furniture(type1)
				game_ui.hide_furniture_inspector()
		KEY_2:
			if current_state == GameState.IN_ROOM:
				inventory_manager.select_index(1)
				var type2: String = inventory_manager.get_selected_type_text()
				game_ui.set_status_message("Modo colocar: " + _get_furniture_display_name(type2))
				game_ui.set_catalog_selected_furniture(type2)
				game_ui.hide_furniture_inspector()
		KEY_3:
			if current_state == GameState.IN_ROOM:
				inventory_manager.select_index(2)
				var type3: String = inventory_manager.get_selected_type_text()
				game_ui.set_status_message("Modo colocar: " + _get_furniture_display_name(type3))
				game_ui.set_catalog_selected_furniture(type3)
				game_ui.hide_furniture_inspector()
		KEY_M:
			if current_state == GameState.IN_ROOM:
				if furniture_manager.has_selected_placed_furniture():
					furniture_manager.start_move_selected_furniture()
					game_ui.set_furniture_inspector_message("Modo mover — clic en destino")
					game_ui.set_status_message("Modo mover — clic en celda destino")
		KEY_R:
			if current_state == GameState.IN_ROOM:
				if furniture_manager.has_selected_placed_furniture():
					if furniture_manager.rotate_selected_furniture():
						var rotated: Object = furniture_manager.get_selected_furniture()
						if rotated != null:
							game_ui.update_furniture_inspector(rotated)
						game_ui.set_status_message("Mueble rotado")
					else:
						game_ui.set_furniture_inspector_message("No se puede rotar aquí")
						game_ui.set_status_message("No se puede rotar aquí")
		KEY_DELETE:
			if current_state == GameState.IN_ROOM:
				if furniture_manager.has_selected_placed_furniture():
					if furniture_manager.delete_selected_furniture():
						game_ui.hide_furniture_inspector()
						game_ui.set_status_message("Mueble eliminado")
		KEY_F1:
			if current_state == GameState.IN_ROOM:
				switch_room("lobby")
		KEY_F2:
			if current_state == GameState.IN_ROOM:
				switch_room("room_small")
		KEY_F3:
			if current_state == GameState.IN_ROOM:
				switch_room("room_large")

func _get_furniture_display_name(furniture_type: String) -> String:
	match furniture_type:
		"chair": return "Silla"
		"table": return "Mesa"
		"sofa": return "Sofá"
	return furniture_type


func on_catalog_selected(furniture_type: String) -> void:
	var type_to_index: Dictionary = {"chair": 0, "table": 1, "sofa": 2}
	var idx: int = type_to_index.get(furniture_type, -1)
	if idx < 0:
		return
	inventory_manager.select_index(idx)
	game_ui.set_status_message("Modo colocar: " + _get_furniture_display_name(furniture_type))
	game_ui.set_catalog_selected_furniture(furniture_type)
	game_ui.hide_furniture_inspector()


func _on_inspector_move() -> void:
	if furniture_manager.has_selected_placed_furniture():
		furniture_manager.start_move_selected_furniture()
		game_ui.set_furniture_inspector_message("Modo mover — clic en destino")
		game_ui.set_status_message("Modo mover — clic en celda destino")


func _on_inspector_rotate() -> void:
	if furniture_manager.has_selected_placed_furniture():
		if furniture_manager.rotate_selected_furniture():
			var rotated: Object = furniture_manager.get_selected_furniture()
			if rotated != null:
				game_ui.update_furniture_inspector(rotated)
			game_ui.set_status_message("Mueble rotado")
		else:
			game_ui.set_furniture_inspector_message("No se puede rotar aquí")
			game_ui.set_status_message("No se puede rotar aquí")


func _on_inspector_delete() -> void:
	if furniture_manager.has_selected_placed_furniture():
		if furniture_manager.delete_selected_furniture():
			game_ui.hide_furniture_inspector()
			game_ui.set_status_message("Mueble eliminado")


func _on_inspector_close() -> void:
	game_ui.hide_furniture_inspector()


func on_chat_submitted(message: String) -> void:
	var trimmed: String = message.strip_edges()
	if trimmed.is_empty():
		return
	var result: Dictionary = chat_manager.submit_message(trimmed)
	if not result.get("sent", false):
		return
	game_ui.update_chat_history(chat_manager.get_history())
	game_ui.show_chat_bubble(result.get("message", ""), player_node.global_position)
	if npc_manager != null and npc_manager.is_active():
		var response: String = npc_manager.get_response(trimmed)
		if not response.is_empty():
			chat_manager.add_raw_message(response)
			game_ui.update_chat_history(chat_manager.get_history())
			game_ui.show_npc_bubble(response, npc_manager.get_world_position())


func handle_chat_key_press(keycode: int) -> bool:
	if keycode == KEY_ENTER:
		if not game_ui.is_chat_input_active():
			game_ui.open_chat_input()
			return true
		return false
	if keycode == KEY_ESCAPE and game_ui.is_chat_input_active():
		game_ui.close_chat_input(true)
		return true
	return false

func save_current_room_state():
	var current_room = room_manager.get_current_room()
	if current_room:
		current_room.furniture_items = furniture_manager.get_furniture_items()
		room_save_service.save_rooms(room_manager.get_all_rooms())

func switch_room(room_id):
	var old_room = room_manager.get_current_room()
	if old_room:
		old_room.furniture_items = furniture_manager.get_furniture_items()

	if room_manager.switch_room(room_id):
		var new_room = room_manager.get_current_room()
		var room_size = Vector2i(new_room.width, new_room.height)
		iso_grid.set_room_size(room_size.x, room_size.y)
		pathfinding_manager.reconfigure_grid(room_size.x, room_size.y)
		furniture_manager.replace_furniture_items(new_room.furniture_items, Callable(game_ui, "report_status"))
		player_controller.teleport_to_cell(new_room.player_start_cell)
		camera_controller.center_on_room()
		game_ui.set_room_name(new_room.display_name)
		if npc_manager != null:
			if room_id == "lobby":
				npc_manager.activate()
			else:
				npc_manager.deactivate()
			npc_manager.reapply_pathfinding_solid()
