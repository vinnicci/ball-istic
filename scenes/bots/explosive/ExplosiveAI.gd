extends "res://scenes/bots/_ais/charger ai/ChargerAI.gd"


var _exploded: bool = false


func _special() -> void:
	if _exploded == false:
		_parent_node.take_damage(100, Vector2(0,0))
		_exploded = true
