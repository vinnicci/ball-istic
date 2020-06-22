extends "res://scenes/passives/_base/_BasePassive.gd"


#shield +35
func _apply_effects() -> void:
	_parent_node.current_shield_cap += 35
	_parent_node.current_shield += 35
	_parent_node.bar_shield.max_value = _parent_node.current_shield_cap
	_parent_node.bar_shield.value = _parent_node.current_shield
