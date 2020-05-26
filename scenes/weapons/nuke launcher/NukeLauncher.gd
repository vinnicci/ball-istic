extends "res://scenes/weapons/_base/_BaseWeapon.gd"


#that nuke projectile sprite
func _process(_delta: float) -> void:
	if current_heat > heat_capacity && _is_overheating == false:
		$SpriteProj.hide()
	elif _is_overheating == true && current_heat <= heat_capacity * heat_below_threshold:
		$SpriteProj.show()
