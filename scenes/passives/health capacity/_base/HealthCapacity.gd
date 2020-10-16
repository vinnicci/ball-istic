extends "res://scenes/passives/_base/_BasePassive.gd"


func _ready() -> void:
	description + "+" + str(effect) + " to health capacity."


func apply_effect() -> void:
	_apply_health_cap()
