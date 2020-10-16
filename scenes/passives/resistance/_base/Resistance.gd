extends "res://scenes/passives/_base/_BasePassive.gd"


func _ready() -> void:
	description = ("+" + str((effect/2) * 100) + "% to damage resistance\n+" +
		str(effect * 100) + "% to knockback resistance.")


func apply_effect() -> void:
	_apply_resistance()
