extends "res://scenes/passives/_base/_BasePassive.gd"


#health +35
func _apply_effects() -> void:
	_parent_node.current_health_cap += 35
	_parent_node.current_health += 35
	_parent_node.bar_health.max_value = _parent_node.current_health_cap
	_parent_node.bar_health.value = _parent_node.current_health
