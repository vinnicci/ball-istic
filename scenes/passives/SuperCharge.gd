extends "res://scenes/passives/_BasePassive.gd"


#charge damage +0.01
#charge force factor +0.1
func apply_effects() -> void:
	parent_node.current_charge_force_factor += 0.1
	parent_node.current_charge_damage_factor += 0.01
