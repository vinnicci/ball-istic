extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 0.05


func _apply_effects() -> void:
	_apply_knockback_resist(EFFECT)
