extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 0.18


func _apply_effects() -> void:
	_apply_charge_cooldown(EFFECT)
