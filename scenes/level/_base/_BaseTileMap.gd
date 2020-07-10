extends "res://scenes/level/_base/_BaseLevelObject.gd"

#be sure to extend
#and attach this to nav node
var _level_node: Node


func set_level(new_level) -> void:
	_level_node = new_level


func destroy() -> void:
	queue_free()
