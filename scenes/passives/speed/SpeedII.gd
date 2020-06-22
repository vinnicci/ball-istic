extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: int = 265


func _apply_effects() -> void:
	_apply_speed(EFFECT)
