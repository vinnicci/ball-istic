extends "res://scenes/bots/_ais/charger ai/ChargerAI.gd"


func _special() -> void:
	_parent_node.take_damage(100, Vector2(0,0))
