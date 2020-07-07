extends "res://scenes/level/_base/_BaseLevelObject.gd"

#be sure to extend
#and attach this to nav node
var _level: Node


func set_level(level) -> void:
	_level = level


func destroy() -> void:
	self.queue_free()
