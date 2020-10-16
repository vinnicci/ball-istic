extends "res://scenes/passives/_base/_BasePassive.gd"


func _ready() -> void:
	description = ("+" + str(effect * 100) + "% to weapon rate damage")


func apply_effect() -> void:
	_apply_weap_damage_rate()
