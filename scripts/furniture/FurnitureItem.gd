extends Node2D

const FurnitureSpriteSheetResolver = preload("res://scripts/furniture/FurnitureSpriteSheetResolver.gd")

const SPRITE_OFFSETS := {
	"chair": Vector2(0, -18),
	"lounge_chair": Vector2(0, -20),
	"plant": Vector2(0, -24),
	"big_plant": Vector2(0, -34),
	"golden_plant": Vector2(0, -28),
	"lamp": Vector2(0, -30),
	"poster": Vector2(0, -36),
	"floor_tile": Vector2(0, -4),
	"sofa": Vector2(0, -24),
	"table": Vector2(0, -18),
	"desk": Vector2(0, -22),
	"bookshelf": Vector2(0, -38),
	"bed": Vector2(0, -24),
	"rug": Vector2(0, 4),
	"red_rug": Vector2(0, 4),
	"blue_rug": Vector2(0, 4),
}

const SPRITE_SCALES := {
	"chair": Vector2.ONE,
	"lounge_chair": Vector2.ONE,
	"plant": Vector2.ONE,
	"big_plant": Vector2.ONE,
	"golden_plant": Vector2.ONE,
	"lamp": Vector2.ONE,
	"poster": Vector2.ONE,
	"floor_tile": Vector2(1.0667, 0.6275),
	"sofa": Vector2.ONE,
	"table": Vector2.ONE,
	"desk": Vector2.ONE,
	"bookshelf": Vector2.ONE,
	"bed": Vector2.ONE,
	"rug": Vector2(1.05, 0.72),
	"red_rug": Vector2(1.05, 0.72),
	"blue_rug": Vector2(1.05, 0.72),
}

var furniture_data
var iso_grid
var selected: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var fallback_visual: Node2D = $FallbackVisual


func setup(p_furniture_data) -> void:
	furniture_data = p_furniture_data
	update_visual()


func configure(p_iso_grid, p_selected: bool = false) -> void:
	iso_grid = p_iso_grid
	selected = p_selected


func update_visual() -> void:
	var furniture_type := _get_furniture_type()
	var texture := FurnitureSpriteSheetResolver.get_atlas_texture(furniture_type)
	if texture != null:
		use_sprite_visual(texture)
	else:
		use_fallback_visual()


func set_selected(enabled: bool) -> void:
	selected = enabled
	modulate = Color(1.12, 1.10, 0.82) if selected else Color.WHITE


func use_sprite_visual(texture: Texture2D) -> void:
	var furniture_type := _get_furniture_type()
	position = _get_anchor_position()
	z_index = _get_draw_z_index()
	z_as_relative = false
	sprite.visible = true
	sprite.texture = texture
	# TODO: when directional spritesheets are available, map rotation to directional AtlasTexture.
	sprite.centered = true
	sprite.position = SPRITE_OFFSETS.get(furniture_type, Vector2.ZERO) as Vector2
	sprite.scale = SPRITE_SCALES.get(furniture_type, Vector2.ONE) as Vector2
	sprite.z_index = 0
	sprite.z_as_relative = true
	fallback_visual.visible = false
	_clear_children(fallback_visual)


func use_fallback_visual() -> void:
	position = Vector2.ZERO
	z_index = 0
	z_as_relative = true
	sprite.visible = false
	sprite.texture = null
	fallback_visual.visible = true
	_clear_children(fallback_visual)
	if iso_grid == null or furniture_data == null:
		return

	var visual_factory_script := load("res://scripts/furniture/FurnitureVisualFactory.gd")
	if visual_factory_script == null:
		return

	var fallback_factory = visual_factory_script.new(fallback_visual, iso_grid)
	fallback_factory.set("use_sprites", false)
	fallback_factory.draw_furniture(furniture_data)


func _get_anchor_position() -> Vector2:
	if iso_grid == null or furniture_data == null:
		return Vector2.ZERO
	var cell := _get_furniture_cell()
	return iso_grid.grid_to_iso(cell) + _get_footprint_offset()


func _get_draw_z_index() -> int:
	if iso_grid == null or furniture_data == null:
		return int(global_position.y)
	var cell := _get_sort_cell()
	var z_offset := 0
	if _get_furniture_layer() == "floor":
		z_offset = -8
	return iso_grid.get_draw_z_index(cell) + z_offset + 4


func _get_footprint_offset() -> Vector2:
	if iso_grid == null:
		return Vector2.ZERO
	var size := _get_furniture_size()
	if size.x <= 1 and size.y <= 1:
		return Vector2.ZERO

	var origin := _get_furniture_cell()
	var center := Vector2.ZERO
	var count := 0
	for x: int in range(size.x):
		for y: int in range(size.y):
			center += iso_grid.grid_to_iso(origin + Vector2i(x, y))
			count += 1
	if count == 0:
		return Vector2.ZERO
	return center / float(count) - iso_grid.grid_to_iso(origin)


func _get_sort_cell() -> Vector2i:
	var origin := _get_furniture_cell()
	var size := _get_furniture_size()
	return origin + Vector2i(maxi(size.x - 1, 0), maxi(size.y - 1, 0))


func _get_furniture_type() -> String:
	if furniture_data == null:
		return ""
	if furniture_data is Dictionary:
		return str(furniture_data.get("type", ""))
	var value: Variant = furniture_data.get("type")
	return str(value) if value != null else ""


func _get_furniture_cell() -> Vector2i:
	if furniture_data == null:
		return Vector2i.ZERO
	if furniture_data is Dictionary:
		var dictionary_cell: Variant = furniture_data.get("cell", Vector2i.ZERO)
		return dictionary_cell if dictionary_cell is Vector2i else Vector2i.ZERO
	var value: Variant = furniture_data.get("cell")
	return value if value is Vector2i else Vector2i.ZERO


func _get_furniture_size() -> Vector2i:
	if furniture_data == null:
		return Vector2i.ONE
	if furniture_data is Dictionary:
		var dictionary_size: Variant = furniture_data.get("size", Vector2i.ONE)
		return dictionary_size if dictionary_size is Vector2i else Vector2i.ONE
	var value: Variant = furniture_data.get("size")
	return value if value is Vector2i else Vector2i.ONE


func _get_furniture_layer() -> String:
	if furniture_data == null:
		return "furniture"
	if furniture_data is Dictionary:
		return str(furniture_data.get("layer", "furniture"))
	var value: Variant = furniture_data.get("layer")
	return str(value) if value != null else "furniture"


func _clear_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
