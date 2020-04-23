extends Node


onready var parent_node


func apply_effects() -> void:
	if Globals.player.get_ref() != null:
		parent_node = Globals.player.get_ref()
