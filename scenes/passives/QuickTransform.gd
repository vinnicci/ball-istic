extends "res://scenes/passives/_BasePassive.gd"


#transform speed -0.1
#knockback resist -0.1
func apply_effects() -> void:
	parent_node.current_transform_speed -= 0.1
	parent_node.current_knockback_resist -= 0.1
