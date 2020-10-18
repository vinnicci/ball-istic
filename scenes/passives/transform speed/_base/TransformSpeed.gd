extends "res://scenes/passives/_base/_BasePassive.gd"


func _ready() -> void:
	description = str(effect) + " sec to transform cooldown."


func apply_effect() -> void:
	_apply_transform_speed()
