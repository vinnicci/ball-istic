extends Node


onready var parent_node: = get_parent().get_parent()


func apply_effects() -> void:
	pass


func get_new_parent(new_parent: Node) -> void:
	parent_node.get_node("Items").remove_child(self)
	parent_node = new_parent
	parent_node.add_child(self)
	parent_node = parent_node.get_parent()
