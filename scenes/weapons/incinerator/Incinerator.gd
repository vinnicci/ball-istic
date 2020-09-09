extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _modify_proj(proj) -> void:
	._modify_proj(proj)
	proj.proj_range = rand_range(500, 1300)
