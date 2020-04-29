extends "res://scenes/passives/_base/_BasePassive.gd"


#charge cooldown -0.5
func _apply_effects() -> void:
	_parent_node.set_current_charge_cooldown(_parent_node.get_current_charge_cooldown() - 0.5)
