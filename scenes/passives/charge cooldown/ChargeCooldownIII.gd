extends "res://scenes/passives/_base/_BasePassive.gd"


func _apply_effects() -> void:
	_parent_node.current_charge_cooldown = _parent_node.current_charge_cooldown - 0.5
