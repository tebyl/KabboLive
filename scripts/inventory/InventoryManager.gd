extends RefCounted


const FurnitureDataScript = preload("res://scripts/furniture/FurnitureData.gd")
const FurnitureData = FurnitureDataScript

var items = []
var selected_index = -1


func _init() :
	items = [
		FurnitureDataScript.new(Vector2i.ZERO, &"chair", Vector2i(1, 1)),
		FurnitureDataScript.new(Vector2i.ZERO, &"table", Vector2i(2, 1)),
		FurnitureDataScript.new(Vector2i.ZERO, &"sofa", Vector2i(2, 1))
	]


func select_index(index) :
	if index < 0 or index >= items.size():
		return

	selected_index = index


func cancel_selection() :
	selected_index = -1


func has_selected_furniture() :
	return selected_index >= 0 and selected_index < items.size()


func get_selected_type_text() :
	if not has_selected_furniture():
		return ""

	return str(items[selected_index].type)


func create_selected_furniture(target_cell):
	var selected_item = items[selected_index]
	return FurnitureDataScript.new(target_cell, selected_item.type, selected_item.size)
