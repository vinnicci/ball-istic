extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _charge_fire() -> void:
	._charge_fire()
	_fire_burst()
