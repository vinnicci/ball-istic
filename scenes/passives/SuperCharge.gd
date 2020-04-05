extends "res://scenes/passives/_BasePassive.gd"


#charge force factor +0.1
func _apply_passive_effects() -> void:
	parent_node.current_charge_force_factor += 0.1
