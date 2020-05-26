extends Node2D


onready var _parent_node: = get_parent().get_parent() setget set_parent_node, get_parent_node


func _ready() -> void:
	if $SlotIcon.texture == null:
		push_error(name + " has no inventory icon. Please add one.")


func set_parent_node(new_parent: Node):
	_parent_node = new_parent


func get_parent_node():
	return _parent_node
