extends "res://scenes/passives/_base/_BasePassive.gd"


#charge cooldown -0.5
func apply_effects() -> void:
	parent_node.current_charge_cooldown -= 0.5
	parent_node.timer_charge_cooldown.wait_time = parent_node.current_charge_cooldown
