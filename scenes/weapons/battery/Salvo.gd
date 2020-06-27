extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var _left_curve: Resource = preload("res://scenes/weapons/battery/BatteryProjLeftCurve.tres")
var _right_curve: Resource = preload("res://scenes/weapons/battery/BatteryProjRightCurve.tres")


func _ready() -> void:
	$Muzzle.position = $MuzzlePos/P0.position


var _current_pos: int = 0


func _modify_proj(proj) -> void:
	var proj_behavior = proj.get_node("ProjBehavior")
	if _current_pos % 2 == 0:
		proj_behavior.steer_curve = _left_curve
	else:
		proj_behavior.steer_curve = _right_curve
	$Muzzle.transform = get_node("MuzzlePos/P" + _current_pos as String).transform
	_current_pos += 1
	if _current_pos == proj_count_per_shot:
		_current_pos = 0
