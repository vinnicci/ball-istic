extends "res://scenes/passives/_BasePassive.gd"


#transform speed -0.1
func _apply_passive_effects() -> void:
	parent_node.current_transform_speed -= 0.1
