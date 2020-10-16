extends "res://scenes/passives/_base/_BasePassive.gd"


func _ready() -> void:
	description = "+" + str(effect*100) + "% to charge damage rate."


func apply_effect() -> void:
	_apply_charge_damage_rate()
