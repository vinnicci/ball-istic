extends "res://scenes/passives/_base/_BasePassive.gd"


#charge force factor +0.05
func apply_effects() -> void:
	parent_node.current_charge_force_factor += 0.15
