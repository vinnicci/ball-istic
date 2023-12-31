extends Node2D


var item: Node
var from_slot: String


func set_item(new_item: Node, new_from_slot: String) -> void:
	if has_node("SlotIcon") == true:
		remove_child($SlotIcon)
	if is_instance_valid(new_item) == false:
		item = null
	else:
		item = new_item
		var icon = item.get_node("SlotIcon").duplicate()
		icon.visible = true
		add_child(icon)
	from_slot = new_from_slot
