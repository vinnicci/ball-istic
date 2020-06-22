extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 0.16


func _apply_effects() -> void:
	_parent_node.current_charge_force_factor += EFFECT
