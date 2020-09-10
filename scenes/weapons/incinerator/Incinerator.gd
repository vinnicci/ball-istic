extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _modify_proj(proj_pack) -> Node:
	var proj = ._modify_proj(proj_pack)
	proj.proj_range = rand_range(500, 1300)
	return proj
