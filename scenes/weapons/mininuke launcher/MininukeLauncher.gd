extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _process(delta: float) -> void:
	match heat_state:
		HeatStates.OVERHEATING:
			$Sprite/Nuke.hide()
		_:
			$Sprite/Nuke.show()


func _modify_proj(proj_pack) -> Node:
	var proj = ._modify_proj(proj_pack)
	proj.z_index = 2
	return proj
