extends "res://scenes/passives/_base/_BasePassive.gd"


func _ready() -> void:
	description = ("+" + str(effect) + " to shield capacity.\n" + "+" +
		str(effect2) + " to shield regeneration.")


func apply_effect() -> void:
	_apply_shield_cap()
