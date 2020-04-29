extends "res://scenes/passives/_base/_BasePassive.gd"


#roll speed +300
func _apply_effects() -> void:
	_parent_node.current_roll_speed += 300
