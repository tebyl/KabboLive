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
const PlacementPreviewScript: GDScript = preload("res://scripts/placement/PlacementPreview.gd")

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
var _overlap_pending_items: Array = []

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
var placement_preview
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
	game_ui.build_furniture_catalog(inventory_manager.get_catalog())
	game_ui.setup_furniture_inspector_callbacks(
		Callable(self, "_on_inspector_move"),
		Callable(self, "_on_inspector_rotate"),
		Callable(self, "_on_inspector_delete"),
		Callable(self, "_on_inspector_close")
	)
	game_ui.setup_overlap_selector_callbacks(
		Callable(self, "_on_overlap_item_selected"),
		Callable(self, "_on_overlap_selector_closed")
	)
	camera_controller = CameraControllerScript.new(self, iso_grid)

	furniture_manager = FurnitureManagerScript.new(
		iso_grid,
		pathfinding_manager,
		player_controller,
		furniture_visual_factory,
		room_manager.get_current_furniture_items()
	)

	placement_preview = PlacementPreviewScript.new()
	placement_preview.setup(self, iso_grid)

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
		update_placement_preview()
	else:
		hide_placement_preview()

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
				hide_placement_preview()
				return
			var mouse_event = event as InputEventMouseButton
			if get_viewport().gui_get_hovered_control() != null:
				hide_placement_preview()
				return
			camera_controller.handle_mouse_button(mouse_event)
			if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
				var world_pos = camera_controller.screen_to_world(mouse_event.position)
				var cell = iso_grid.iso_to_grid(world_pos)
				if furniture_manager.is_move_mode_active():
					if furniture_manager.can_move_selected_furniture_to(cell) and furniture_manager.move_selected_furniture(cell):
						var moved: Object = furniture_manager.get_selected_furniture()
						if moved != null:
							game_ui.update_furniture_inspector(moved)
						hide_placement_preview()
						game_ui.set_status_message("Mueble movido")
						_show_toast("Mueble movido", "success")
					else:
						update_placement_preview()
						_show_toast("No se puede mover aquí", "error")
						game_ui.set_status_message("No se puede mover ahí")
				elif inventory_manager.has_selected_furniture():
					var new_furniture: RefCounted = inventory_manager.create_selected_furniture_at(cell)
					if new_furniture:
						if furniture_manager.can_place_furniture(new_furniture, -1) and furniture_manager.place_furniture(new_furniture):
							game_ui.set_status_message("Mueble colocado")
							_show_toast(_get_furniture_placed_message(str(new_furniture.get("type"))), "success")
							update_placement_preview()
						else:
							update_placement_preview()
							_show_toast("No se puede colocar aquí", "error")
							game_ui.set_status_message("No se puede colocar ahí")
				else:
					var items_at_cell: Array = furniture_manager.get_furniture_items_at_cell(cell)
					if items_at_cell.size() == 0:
						# No furniture — move player
						if iso_grid.is_valid_cell(cell) and not pathfinding_manager.is_point_solid(cell):
							var player_cell: Vector2i = player_controller.get_player_cell()
							var path: Array = pathfinding_manager.get_path(player_cell, cell)
							if path.size() > 0:
								if not player_controller.move_along_path(path):
									game_ui.set_status_message("El jugador ya se esta moviendo")
					elif items_at_cell.size() == 1:
						furniture_manager.select_furniture_item(items_at_cell[0])
						hide_placement_preview()
						game_ui.show_furniture_inspector(items_at_cell[0])
						game_ui.set_status_message("Mueble seleccionado — M mover | R rotar | Delete eliminar")
					else:
						_overlap_pending_items = items_at_cell
						hide_placement_preview()
						game_ui.hide_furniture_inspector()
						game_ui.show_overlap_selector(_overlap_pending_items)

func resolve_required_nodes() -> bool:
	floor_node = get_node_or_null("Floor")
	blocks_node = get_node_or_null("Blocks")
	player_node = get_node_or_null("Player")
	return floor_node != null and blocks_node != null and player_node != null

func enter_state(new_state):
	hide_placement_preview()
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
	if player_profile_manager.update_profile(new_name, new_color):
		chat_manager.set_player_name(player_profile_manager.player_name)
		player_controller.update_avatar_color(player_profile_manager.avatar_color)
		_show_toast("Perfil guardado", "success")
	else:
		_show_toast("Nombre inválido", "error")

func handle_key_press(keycode):
	match keycode:
		KEY_ESCAPE:
			if current_state == GameState.IN_ROOM:
				if game_ui.is_overlap_selector_visible():
					game_ui.hide_overlap_selector()
					_overlap_pending_items = []
				elif furniture_manager.is_move_mode_active():
					furniture_manager.cancel_move_mode()
					hide_placement_preview()
					game_ui.set_furniture_inspector_message("Seleccionado")
					game_ui.set_status_message("Modo mover cancelado")
				elif inventory_manager.has_selected_furniture():
					inventory_manager.cancel_selection()
					game_ui.set_catalog_selected_furniture("")
					hide_placement_preview()
					game_ui.set_status_message("Sin seleccion")
				elif furniture_manager.has_selected_placed_furniture() or furniture_manager.is_move_mode_active():
					furniture_manager.clear_selection()
					game_ui.hide_furniture_inspector()
					hide_placement_preview()
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
				hide_placement_preview()
		KEY_S:
			if current_state == GameState.IN_ROOM:
				save_current_room_state()
		KEY_L:
			if current_state == GameState.IN_ROOM:
				var loaded_rooms = room_save_service.load_rooms(Callable(game_ui, "report_status"))
				room_manager.apply_saved_rooms(loaded_rooms.get("rooms", []))
				var load_status: StringName = StringName(loaded_rooms.get("status", &"missing"))
				var current_room = room_manager.get_current_room()
				if current_room:
					furniture_manager.replace_furniture_items(current_room.furniture_items, Callable(game_ui, "report_status"))
					game_ui.hide_furniture_inspector()
					hide_placement_preview()
					if npc_manager != null:
						npc_manager.reapply_pathfinding_solid()
				if load_status == &"ok":
					_show_toast("Sala cargada", "success")
				elif load_status == &"missing":
					_show_toast("No hay sala guardada", "warning")
				else:
					_show_toast("No se pudo cargar", "error")
		KEY_1:
			if current_state == GameState.IN_ROOM:
				inventory_manager.select_type("chair")
				furniture_manager.clear_selection()
				game_ui.set_status_message("Modo colocar: Silla")
				game_ui.set_catalog_selected_furniture("chair")
				game_ui.hide_furniture_inspector()
				update_placement_preview()
		KEY_2:
			if current_state == GameState.IN_ROOM:
				inventory_manager.select_type("table")
				furniture_manager.clear_selection()
				game_ui.set_status_message("Modo colocar: Mesa")
				game_ui.set_catalog_selected_furniture("table")
				game_ui.hide_furniture_inspector()
				update_placement_preview()
		KEY_3:
			if current_state == GameState.IN_ROOM:
				inventory_manager.select_type("sofa")
				furniture_manager.clear_selection()
				game_ui.set_status_message("Modo colocar: Sofá")
				game_ui.set_catalog_selected_furniture("sofa")
				game_ui.hide_furniture_inspector()
				update_placement_preview()
		KEY_M:
			if current_state == GameState.IN_ROOM:
				if furniture_manager.has_selected_placed_furniture():
					furniture_manager.start_move_selected_furniture()
					inventory_manager.cancel_selection()
					game_ui.set_catalog_selected_furniture("")
					update_placement_preview()
					game_ui.set_status_message("Modo mover: selecciona destino")
					game_ui.set_furniture_inspector_message("Modo mover — clic en destino")
					game_ui.set_status_message("Modo mover: selecciona destino")
		KEY_R:
			if current_state == GameState.IN_ROOM:
				if furniture_manager.has_selected_placed_furniture():
					if furniture_manager.rotate_selected_furniture():
						var rotated: Object = furniture_manager.get_selected_furniture()
						if rotated != null:
							game_ui.update_furniture_inspector(rotated)
						game_ui.set_status_message("Mueble rotado")
						_show_toast("Mueble rotado", "success")
					else:
						game_ui.set_furniture_inspector_message("No se puede rotar aquí")
						game_ui.set_status_message("No se puede rotar aquí")
						_show_toast("No se puede rotar aquí", "error")
		KEY_DELETE:
			if current_state == GameState.IN_ROOM:
				if furniture_manager.has_selected_placed_furniture():
					if furniture_manager.delete_selected_furniture():
						game_ui.hide_furniture_inspector()
						game_ui.set_status_message("Mueble eliminado")
						_show_toast("Mueble eliminado", "success")
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
		"sofa":  return "Sofá"
		"plant": return "Planta"
		"rug":   return "Alfombra"
	return furniture_type


func _get_furniture_placed_message(furniture_type: String) -> String:
	match furniture_type:
		"chair": return "Silla colocada"
		"table": return "Mesa colocada"
		"sofa": return "Sofá colocado"
		"plant": return "Planta colocada"
		"rug": return "Alfombra colocada"
	return _get_furniture_display_name(furniture_type) + " colocado"


func _show_toast(message: String, kind: String = "info") -> void:
	if game_ui != null and game_ui.has_method("show_toast"):
		game_ui.show_toast(message, kind)


func on_catalog_selected(furniture_type: String) -> void:
	inventory_manager.select_type(furniture_type)
	game_ui.set_status_message("Modo colocar: " + _get_furniture_display_name(furniture_type))
	game_ui.set_catalog_selected_furniture(furniture_type)
	game_ui.hide_furniture_inspector()
	furniture_manager.clear_selection()
	update_placement_preview()


func _on_inspector_move() -> void:
	if furniture_manager.has_selected_placed_furniture():
		furniture_manager.start_move_selected_furniture()
		inventory_manager.cancel_selection()
		game_ui.set_catalog_selected_furniture("")
		update_placement_preview()
		game_ui.set_status_message("Modo mover: selecciona destino")
		game_ui.set_furniture_inspector_message("Modo mover — clic en destino")
		game_ui.set_status_message("Modo mover: selecciona destino")


func _on_inspector_rotate() -> void:
	if furniture_manager.has_selected_placed_furniture():
		if furniture_manager.rotate_selected_furniture():
			var rotated: Object = furniture_manager.get_selected_furniture()
			if rotated != null:
				game_ui.update_furniture_inspector(rotated)
			game_ui.set_status_message("Mueble rotado")
			_show_toast("Mueble rotado", "success")
		else:
			game_ui.set_furniture_inspector_message("No se puede rotar aquí")
			game_ui.set_status_message("No se puede rotar aquí")
			_show_toast("No se puede rotar aquí", "error")


func _on_inspector_delete() -> void:
	if furniture_manager.has_selected_placed_furniture():
		if furniture_manager.delete_selected_furniture():
			game_ui.hide_furniture_inspector()
			game_ui.set_status_message("Mueble eliminado")
			_show_toast("Mueble eliminado", "success")


func _on_inspector_close() -> void:
	game_ui.hide_furniture_inspector()


func _on_overlap_item_selected(index: int) -> void:
	if index < 0 or index >= _overlap_pending_items.size():
		return
	var furniture: RefCounted = _overlap_pending_items[index]
	_overlap_pending_items = []
	furniture_manager.select_furniture_item(furniture)
	hide_placement_preview()
	game_ui.show_furniture_inspector(furniture)
	game_ui.set_status_message("Mueble seleccionado — M mover | R rotar | Delete eliminar")


func _on_overlap_selector_closed() -> void:
	_overlap_pending_items = []


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
			hide_placement_preview()
			return true
		return false
	if keycode == KEY_ESCAPE and game_ui.is_chat_input_active():
		game_ui.close_chat_input(true)
		update_placement_preview()
		return true
	return false


func update_placement_preview() -> void:
	if placement_preview == null:
		return
	if _can_show_move_preview():
		update_move_preview()
		return
	if _can_show_placement_preview():
		update_new_furniture_preview()
		return
	hide_placement_preview()


func update_new_furniture_preview() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var world_pos: Vector2 = camera_controller.screen_to_world(mouse_position)
	var cell: Vector2i = iso_grid.iso_to_grid(world_pos)
	if not iso_grid.is_valid_cell(cell):
		hide_placement_preview()
		return
	var preview_furniture: RefCounted = inventory_manager.create_selected_furniture_at(cell)
	if preview_furniture == null:
		hide_placement_preview()
		return
	show_furniture_preview(preview_furniture, -1)


func update_move_preview() -> void:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var world_pos: Vector2 = camera_controller.screen_to_world(mouse_position)
	var cell: Vector2i = iso_grid.iso_to_grid(world_pos)
	if not iso_grid.is_valid_cell(cell):
		hide_placement_preview()
		return
	var preview_furniture: RefCounted = furniture_manager.create_selected_move_preview(cell)
	if preview_furniture == null:
		hide_placement_preview()
		return
	show_furniture_preview(preview_furniture, furniture_manager.get_selected_furniture_index())


func show_furniture_preview(preview_furniture: RefCounted, ignored_index: int) -> void:
	var occupied_cells: Array[Vector2i] = preview_furniture.get_occupied_cells()
	var is_valid: bool = furniture_manager.can_place_furniture(preview_furniture, ignored_index)
	placement_preview.show_preview(occupied_cells, is_valid)


func hide_placement_preview() -> void:
	if placement_preview != null:
		placement_preview.hide_preview()


func _can_show_placement_preview() -> bool:
	if not _can_show_any_preview():
		return false
	if not inventory_manager.has_selected_furniture():
		return false
	if furniture_manager.is_move_mode_active():
		return false
	if game_ui.is_furniture_inspector_visible():
		return false
	return true


func _can_show_move_preview() -> bool:
	if not _can_show_any_preview():
		return false
	if not furniture_manager.is_move_mode_active():
		return false
	if not furniture_manager.has_selected_placed_furniture():
		return false
	return true


func _can_show_any_preview() -> bool:
	if current_state != GameState.IN_ROOM:
		return false
	if game_ui.is_chat_input_active() or game_ui.is_profile_open():
		return false
	if game_ui.is_overlap_selector_visible():
		return false
	var hovered_control: Control = get_viewport().gui_get_hovered_control()
	if hovered_control != null:
		return false
	return true


func save_current_room_state():
	hide_placement_preview()
	var current_room = room_manager.get_current_room()
	if current_room:
		current_room.furniture_items = furniture_manager.get_furniture_items()
		if room_save_service.save_rooms(room_manager.get_all_rooms()):
			_show_toast("Sala guardada", "success")
		else:
			_show_toast("No se pudo guardar", "error")

func switch_room(room_id):
	hide_placement_preview()
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
