extends Node2D

const DIRECTION_TEXTURES: Dictionary = {
	"east": preload("res://assets/sprites/player/east.png"),
	"north": preload("res://assets/sprites/player/north.png"),
	"north-east": preload("res://assets/sprites/player/north-east.png"),
	"north-west": preload("res://assets/sprites/player/north-west.png"),
	"south": preload("res://assets/sprites/player/south.png"),
	"south-east": preload("res://assets/sprites/player/south-east.png"),
	"south-west": preload("res://assets/sprites/player/south-west.png"),
	"west": preload("res://assets/sprites/player/west.png"),
}

const ISO_DIRECTIONS: Dictionary = {
	Vector2i(1, 0): "south-east",
	Vector2i(-1, 0): "north-west",
	Vector2i(0, 1): "south-west",
	Vector2i(0, -1): "north-east",
	Vector2i(1, 1): "south",
	Vector2i(-1, -1): "north",
	Vector2i(1, -1): "east",
	Vector2i(-1, 1): "west",
}

const VECTOR_DIRECTIONS: Dictionary = {
	Vector2i(1, 0): "east",
	Vector2i(-1, 0): "west",
	Vector2i(0, 1): "south",
	Vector2i(0, -1): "north",
	Vector2i(1, 1): "south-east",
	Vector2i(-1, 1): "south-west",
	Vector2i(1, -1): "north-east",
	Vector2i(-1, -1): "north-west",
}

@export var sprite_scale: Vector2 = Vector2(1.5, 1.5)
@export var foot_offset: Vector2 = Vector2(0.0, -27.0)

var current_direction: String = "south"


func _ready() -> void:
	_setup_sprite()
	_apply_direction()


func set_direction(direction: String) -> void:
	if not DIRECTION_TEXTURES.has(direction):
		return

	current_direction = direction
	_apply_direction()


func set_direction_from_vector(direction: Vector2) -> void:
	var normalized_direction := Vector2i(_sign_as_int(direction.x), _sign_as_int(direction.y))
	if not VECTOR_DIRECTIONS.has(normalized_direction):
		return

	set_direction(VECTOR_DIRECTIONS[normalized_direction] as String)


func set_iso_direction_from_grid_delta(delta: Vector2i) -> void:
	if not ISO_DIRECTIONS.has(delta):
		return

	set_direction(ISO_DIRECTIONS[delta] as String)


func _apply_direction() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null or not DIRECTION_TEXTURES.has(current_direction):
		return

	sprite.texture = DIRECTION_TEXTURES[current_direction] as Texture2D


func _setup_sprite() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		return

	sprite.centered = true
	sprite.offset = foot_offset
	sprite.scale = sprite_scale


func _sign_as_int(value: float) -> int:
	if value > 0.0:
		return 1
	if value < 0.0:
		return -1
	return 0
