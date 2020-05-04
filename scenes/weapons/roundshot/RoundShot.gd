extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var _current_rotation: int = 0
var _rotation_max: int = 12


func _charge_fire() -> void:
	if _parent_node.is_rolling() == true:
		return
	_is_shooting = true
	global_rotation += deg2rad(60)
	$Timers/RotateTimer.start()


func _on_RotateTimer_timeout() -> void:
	if _current_rotation == _rotation_max:
		_is_shooting = false
		_current_rotation = 0
		return
	_fire_auto()
	_current_rotation += 1
	global_rotation += deg2rad(60)
	$Timers/RotateTimer.start()
