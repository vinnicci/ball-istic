extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 0.12


func _apply_effects() -> void:
	_apply_transform_speed(EFFECT)
