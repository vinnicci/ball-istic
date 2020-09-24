extends Node2D


export var description: String

var _parent_node: Node
var _level_node: Node


func parent_node():
	return _parent_node


func _ready() -> void:
	if _parent_node is Global.CLASS_PLAYER && $SlotIcon.texture == null:
		push_error(name + " has no inventory icon. Please add one.")


func set_parent(new_parent: Node):
	if new_parent == _parent_node:
		return
	_parent_node = new_parent


func set_level(new_level: Node):
	_level_node = new_level


func get_description() -> String:
	return description
