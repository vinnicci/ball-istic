extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 1.5


func _apply_effects() -> void:
	_parent_node.current_shield_recovery += EFFECT
