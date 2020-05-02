extends "res://scenes/weapons/_base/_BaseWeapon.gd"


#that nuke projectile sprite
func _process(_delta: float) -> void:
	if _current_heat > heat_capacity && _is_overheating == false:
		$SpriteProj.hide()
	elif _is_overheating == true && _current_heat <= heat_capacity * heat_cooled_factor:
		$SpriteProj.show()
