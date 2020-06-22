extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 25.0


func _apply_effects() -> void:
	_parent_node.current_health_cap += EFFECT
	_parent_node.current_health += EFFECT
	_parent_node.bar_health.max_value = _parent_node.current_health_cap
	_parent_node.bar_health.value = _parent_node.current_health
