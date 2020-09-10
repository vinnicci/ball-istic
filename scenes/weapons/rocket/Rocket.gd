extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var _left_curve: Resource = preload("res://scenes/weapons/rocket/RocketProjLeftCurve.tres")
var _right_curve: Resource = preload("res://scenes/weapons/rocket/RocketProjRightCurve.tres")


func _ready() -> void:
	$Muzzle.transform = $MuzzlePos/P0.transform


var _current_pos: int = 0


func _modify_proj(proj_pack) -> Node:
	var proj = ._modify_proj(proj_pack)
	var proj_behavior = proj.get_node("ProjBehavior")
	if _current_pos % 2 == 0:
		proj_behavior.steer_curve = _left_curve
	else:
		proj_behavior.steer_curve = _right_curve
	$Muzzle.transform = get_node("MuzzlePos/P" + _current_pos as String).transform
	_current_pos += 1
	if _current_pos == 10:
		_current_pos = 0
	return proj
