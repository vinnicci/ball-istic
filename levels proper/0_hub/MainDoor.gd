extends "res://scenes/level/tileset/brown/DoorBrown.gd"


var _level_node: Node


func set_level(lvl_node) -> void:
	_level_node = lvl_node


func open() -> void:
	if _level_node.keys.size() != 3:
		return
	.open()
