extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 40.0


func _apply_effects() -> void:
	_apply_health_cap(EFFECT)
