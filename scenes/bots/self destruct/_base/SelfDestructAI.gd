extends "res://scenes/bots/_ais/charger ai/ChargerAI.gd"


var _exploded: bool = false


func _special() -> void:
	if _exploded == false:
		_parent_node.current_health = 0
		_exploded = true
