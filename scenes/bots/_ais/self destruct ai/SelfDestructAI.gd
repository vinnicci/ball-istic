extends "res://scenes/bots/_ais/_base/_BaseAI.gd"


var _exploded: bool = false


func _special() -> void:
	if _exploded == false:
		_parent_node.take_damage(999, Vector2(0,0))
		_exploded = true
