extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _process(delta: float) -> void:
	if _is_overheating == true:
		$Sprite/Nuke.hide()
	else:
		$Sprite/Nuke.show()


func _modify_proj(proj_pack) -> Node:
	var proj = ._modify_proj(proj_pack)
	proj.z_index = 2
	return proj
