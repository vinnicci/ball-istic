extends "res://scenes/passives/_base/_BasePassive.gd"


func _ready() -> void:
	description = ("+" + str((effect - 1) * 100) + "% to weapon heat capacity.")


func apply_effect() -> void:
	_apply_heat_capacity()
