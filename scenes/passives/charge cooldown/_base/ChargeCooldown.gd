extends "res://scenes/passives/_base/_BasePassive.gd"


func _ready() -> void:
	description = str(effect) + " sec to charge cooldown."


func apply_effect() -> void:
	_apply_charge_cooldown()
