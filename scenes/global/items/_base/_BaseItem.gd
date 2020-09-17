extends Node2D


var _parent_node: Node


func _ready() -> void:
	if _parent_node is Global.CLASS_PLAYER && $SlotIcon.texture == null:
		push_error(name + " has no inventory icon. Please add one.")


func set_parent(new_parent: Node):
	if new_parent == _parent_node:
		return
	_parent_node = new_parent

