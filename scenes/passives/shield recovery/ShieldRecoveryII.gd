extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 3.5


func _apply_effects() -> void:
	_apply_shield_recovery(EFFECT)
