extends RefCounted

const FLOOR_SPRITESHEET_PATH := "res://assets/sprites/room/room_floor_spritesheet.png"
const COLUMNS := 4
const ROWS := 4

const TILE_COORDS := {
	"beige_basic": Vector2i(0, 0),
	"beige_dark": Vector2i(1, 0),
	"cream_basic": Vector2i(2, 0),
	"brown_basic": Vector2i(3, 0),
	"beige_border": Vector2i(0, 1),
	"beige_diagonal": Vector2i(1, 1),
	"beige_center": Vector2i(2, 1),
	"beige_worn": Vector2i(3, 1),
	"dark_tile": Vector2i(0, 2),
	"blue_tile": Vector2i(1, 2),
	"red_tile": Vector2i(2, 2),
	"green_tile": Vector2i(3, 2),
	"marble_tile": Vector2i(0, 3),
	"wood_parquet": Vector2i(1, 3),
	"checker_tile": Vector2i(2, 3),
	"premium_gold_tile": Vector2i(3, 3),
}


static func has_floor_spritesheet() -> bool:
	return ResourceLoader.exists(FLOOR_SPRITESHEET_PATH)


static func has_tile(tile_type: String) -> bool:
	return has_floor_spritesheet() and TILE_COORDS.has(tile_type)


static func get_floor_tile(tile_type: String) -> Texture2D:
	if not ResourceLoader.exists(FLOOR_SPRITESHEET_PATH):
		return null
	if not TILE_COORDS.has(tile_type):
		return null

	var base_texture := load(FLOOR_SPRITESHEET_PATH) as Texture2D
	if base_texture == null:
		return null
	if base_texture.get_width() <= 0 or base_texture.get_height() <= 0:
		return null

	var cell_width := float(base_texture.get_width()) / float(COLUMNS)
	var cell_height := float(base_texture.get_height()) / float(ROWS)
	var coord := TILE_COORDS[tile_type] as Vector2i
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = base_texture
	atlas_texture.region = Rect2(
		float(coord.x) * cell_width,
		float(coord.y) * cell_height,
		cell_width,
		cell_height
	)
	return atlas_texture
