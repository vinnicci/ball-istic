extends "res://scenes/passives/_base/_BasePassive.gd"


func _ready() -> void:
	description = "+" + str(effect) + " to shield regeneration rate."


func apply_effect() -> void:
	_apply_shield_regen()
