extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var _left_curve: Resource = preload("res://scenes/weapons/battery/BatteryProjLeftCurve.tres")
var _right_curve: Resource = preload("res://scenes/weapons/battery/BatteryProjRightCurve.tres")


func _ready() -> void:
	$Muzzle.position = $MuzzlePos/P0.position


func _modify_proj(proj) -> void:
	$Muzzle.transform = get_node("MuzzlePos/P" + _current_burst_count as String).transform
	var proj_behavior = proj.get_node("ProjBehavior")
	if _current_burst_count % 2 == 0:
		proj_behavior.steer_curve = _left_curve
	else:
		proj_behavior.steer_curve = _right_curve
