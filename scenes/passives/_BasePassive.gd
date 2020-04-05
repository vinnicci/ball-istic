extends Node


onready var parent_node: = get_parent().get_parent()


func get_effects() -> void:
	parent_node.reset_bot_vars()
	_apply_passive_effects()


func _apply_passive_effects() -> void:
	pass
