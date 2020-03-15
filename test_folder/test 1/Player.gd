extends "res://scenes/bots/Player.gd"


func _process(delta: float) -> void:
	print((global_position - get_parent().get_parent().get_node("Destination").global_position).length())
