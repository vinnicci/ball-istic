extends "res://scenes/passives/_base/_BasePassive.gd"


#knockback resist +0.08
func _apply_effects() -> void:
	_parent_node.current_knockback_resist += 0.08
