extends "res://scenes/passives/_base/_BasePassive.gd"


#charge damage +0.01
#charge force factor +0.1
#knockback resist +0.12
func apply_effects() -> void:
	parent_node.current_charge_force_factor += 0.2
	parent_node.current_charge_damage_factor += 0.01
	parent_node.current_knockback_resist += 0.12
