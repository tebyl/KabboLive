extends RefCounted

const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const FurnitureData = FurnitureDataScript


var id
var display_name
var width
var height
var player_start_cell
var furniture_items = []


func _init(
	p_id,
	p_display_name,
	p_width,
	p_height,
	p_player_start_cell,
	p_furniture_items: Array = []
) :
	id = p_id
	display_name = p_display_name
	width = p_width
	height = p_height
	player_start_cell = p_player_start_cell
	furniture_items = []

	for furniture in p_furniture_items:
		if furniture is RefCounted and furniture.has_method("get_script"):
			furniture_items.append(furniture.get_script().new(furniture.cell, furniture.type, furniture.size))
		else:
			furniture_items.append(furniture)


func duplicate_data():
	return get_script().new(id, display_name, width, height, player_start_cell, furniture_items)


func get_furniture_items_copy():
	var copied_items = []

	for furniture in furniture_items:
		if furniture is RefCounted and furniture.has_method("get_script"):
			copied_items.append(furniture.get_script().new(furniture.cell, furniture.type, furniture.size))
		else:
			copied_items.append(furniture)

	return copied_items
