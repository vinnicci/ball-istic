extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _ready() -> void:
	$Muzzle.transform = $MuzzlePos/P0.transform


var _current_pos: int = 0


func _modify_proj(proj) -> void:
	._modify_proj(proj)
	_current_pos += 1
	if _current_pos == 5:
		_current_pos = 0
		$Anim.play("rotate")
	$Muzzle.transform = get_node("MuzzlePos/P" + str(_current_pos)).transform
