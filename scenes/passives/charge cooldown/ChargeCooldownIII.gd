extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 0.55


func _apply_effects() -> void:
	_parent_node.current_charge_cooldown -= EFFECT
