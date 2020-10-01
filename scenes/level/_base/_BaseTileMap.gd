extends "res://scenes/level/_base/_BaseLevelObject.gd"

#be sure to extend
#and attach this to nav node
#commonly linked to a secret path
var _level_node: Node
var _secret_path: TileMap


func set_level(new_level: Node) -> void:
	_level_node = new_level


func set_secret(new_secret_path: TileMap) -> void:
	_secret_path = new_secret_path


func destroy() -> void:
	if _secret_path != null:
		_secret_path.visible = true
		_level_node.emit_signal("secret_found", _level_node, self)
	queue_free()
