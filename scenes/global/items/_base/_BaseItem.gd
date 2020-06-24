extends Node2D


var _parent_node = null


func _ready() -> void:
	if $SlotIcon.texture == null:
		push_error(name + " has no inventory icon. Please add one.")


func set_parent(new_parent: Node):
	_parent_node = new_parent


func get_parent_node():
	return _parent_node
