extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _ready() -> void:
	$Muzzle.position = $MuzzlePos/P0.position


var _current_pos: int = 0


func _modify_proj(proj) -> void:
	$Muzzle.transform = get_node("MuzzlePos/P" + _current_pos as String).transform
	_current_pos += 1
	if _current_pos == proj_count_per_shot:
		_current_pos = 0
		$Anim.play("rotate")
