extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 1.25


func _apply_effects() -> void:
	_apply_heat_dissipation(EFFECT)
