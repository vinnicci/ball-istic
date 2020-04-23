extends "res://scenes/passives/_base/_BasePassive.gd"


#roll speed +300
func apply_effects() -> void:
	.apply_effects()
	parent_node.current_roll_speed += 300
