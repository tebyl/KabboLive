extends RefCounted
class_name InventoryManager

var items: Array[FurnitureData]
var selected_index: int = -1


func _init() -> void:
	items = [
		FurnitureData.new(Vector2i.ZERO, &"chair", Vector2i(1, 1)),
		FurnitureData.new(Vector2i.ZERO, &"table", Vector2i(2, 1)),
		FurnitureData.new(Vector2i.ZERO, &"sofa", Vector2i(2, 1))
	]


func select_index(index: int) -> void:
	if index < 0 or index >= items.size():
		return

	selected_index = index


func cancel_selection() -> void:
	selected_index = -1


func has_selected_furniture() -> bool:
	return selected_index >= 0 and selected_index < items.size()


func get_selected_type_text() -> String:
	if not has_selected_furniture():
		return ""

	return str(items[selected_index].type)


func create_selected_furniture(target_cell: Vector2i) -> FurnitureData:
	var selected_item: FurnitureData = items[selected_index]
	return FurnitureData.new(target_cell, selected_item.type, selected_item.size)
