extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 0.15


func _apply_effects() -> void:
	_apply_charge_damage_rate(EFFECT)