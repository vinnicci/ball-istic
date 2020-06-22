extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 0.6


func _apply_effects() -> void:
	_apply_heat_dissipation(EFFECT)
