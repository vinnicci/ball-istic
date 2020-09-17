extends TextureButton


export var from_slot: String
var item: Node


func set_item(new_item) -> void:
	if has_node("SlotIcon") == true:
		remove_child($SlotIcon)
	if new_item == null:
		item = null
	else:
		item = new_item
		var icon = item.get_node("SlotIcon").duplicate()
		icon.visible = true
		icon.position = Vector2(35, 35)
		add_child(icon)


func _on_Slot_mouse_entered() -> void:
	$Highlight.visible = true


func _on_Slot_mouse_exited() -> void:
	$Highlight.visible = false


func _on_Slot_hide() -> void:
	$Highlight.visible = false
