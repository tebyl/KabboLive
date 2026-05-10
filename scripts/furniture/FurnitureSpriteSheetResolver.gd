extends RefCounted

const SPRITESHEET_PATH := "res://assets/sprites/furniture/furniture_spritesheet.png"
const COLUMNS := 4
const ROWS := 4

const SPRITE_COORDS := {
	"chair": Vector2i(0, 0),
	"lounge_chair": Vector2i(1, 0),
	"plant": Vector2i(2, 0),
	"big_plant": Vector2i(3, 0),
	"golden_plant": Vector2i(0, 1),
	"lamp": Vector2i(1, 1),
	"poster": Vector2i(2, 1),
	"floor_tile": Vector2i(3, 1),
	"sofa": Vector2i(0, 2),
	"table": Vector2i(1, 2),
	"desk": Vector2i(2, 2),
	"bookshelf": Vector2i(3, 2),
	"bed": Vector2i(0, 3),
	"rug": Vector2i(1, 3),
	"red_rug": Vector2i(2, 3),
	"blue_rug": Vector2i(3, 3),
}


static func has_sprite(furniture_type: String) -> bool:
	return ResourceLoader.exists(SPRITESHEET_PATH) and SPRITE_COORDS.has(furniture_type)


static func get_atlas_texture(furniture_type: String) -> Texture2D:
	if not ResourceLoader.exists(SPRITESHEET_PATH):
		return null
	if not SPRITE_COORDS.has(furniture_type):
		return null

	var base_texture := load(SPRITESHEET_PATH) as Texture2D
	if base_texture == null:
		return null
	if base_texture.get_width() <= 0 or base_texture.get_height() <= 0:
		return null

	var cell_width := float(base_texture.get_width()) / float(COLUMNS)
	var cell_height := float(base_texture.get_height()) / float(ROWS)
	var coord := SPRITE_COORDS[furniture_type] as Vector2i
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = base_texture
	atlas_texture.region = Rect2(
		float(coord.x) * cell_width,
		float(coord.y) * cell_height,
		cell_width,
		cell_height
	)
	return atlas_texture
