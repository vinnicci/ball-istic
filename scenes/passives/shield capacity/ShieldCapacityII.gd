extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 25.0


func _apply_effects() -> void:
	_apply_shield_cap(EFFECT)
