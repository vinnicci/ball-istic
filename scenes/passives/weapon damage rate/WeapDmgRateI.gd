extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 1.0


func _apply_effects() -> void:
	_apply_weap_damage_rate(EFFECT)
