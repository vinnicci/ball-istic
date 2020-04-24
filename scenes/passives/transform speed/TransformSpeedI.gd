extends "res://scenes/passives/_base/_BasePassive.gd"


#transform speed -0.03
func _apply_effects() -> void:
	parent_node.current_transform_speed -= 0.03
