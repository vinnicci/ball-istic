extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _process(delta: float) -> void:
	if _is_overheating == true:
		$Sprite/Nuke.hide()
	else:
		$Sprite/Nuke.show()


func _modify_proj(proj) -> void:
	._modify_proj(proj)
	proj.z_index = 1
