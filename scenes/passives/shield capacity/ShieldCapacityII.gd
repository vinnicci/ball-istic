extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 25.0


func _apply_effects() -> void:
	_parent_node.current_shield_cap += EFFECT
	_parent_node.current_shield += EFFECT
	_parent_node.bar_shield.max_value = _parent_node.current_shield_cap
	_parent_node.bar_shield.value = _parent_node.current_shield
