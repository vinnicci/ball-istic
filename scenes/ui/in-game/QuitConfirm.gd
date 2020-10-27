extends Control


var _parent_node = null
var _buttons_node = null


func set_parent(new_parent) -> void:
	_parent_node = new_parent


func set_buttons(buttons_node) -> void:
	_buttons_node = buttons_node


func _on_Confirm_pressed() -> void:
	get_tree().paused = false
	_parent_node.emit_signal("scene_changed", "Menu")


func _on_Cancel_pressed() -> void:
	visible = false
	_buttons_node.visible = true
	
