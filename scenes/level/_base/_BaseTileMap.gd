extends "res://scenes/level/_base/_BaseLevelObject.gd"

#be sure to extend
#and attach this to nav node
#commonly linked to a secret path
var _level_node: Node
var _hidden_path: TileMap


func set_level(new_level: Node) -> void:
	_level_node = new_level


func set_hidden(new_hidden_path: TileMap) -> void:
	_hidden_path = new_hidden_path


signal path_found


func destroy() -> void:
	if _hidden_path != null:
		_hidden_path.visible = true
		emit_signal("path_found")
	queue_free()
