extends Control


var _parent_node = null
var _confirm_node = null


func set_parent(new_parent) -> void:
	_parent_node = new_parent


func set_confirm(confirm_node) -> void:
	_confirm_node = confirm_node


func _on_Resume_pressed() -> void:
	get_parent().visible = false
	_parent_node.get_node("CanvasLayer/ColorRect3").visible = false
	get_tree().paused = false


func _on_MainMenu_pressed() -> void:
	visible = false
	_confirm_node.visible = true
