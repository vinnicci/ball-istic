extends "res://scenes/weapons/_base/_BaseWeapon.gd"


#that nuke sprite in weapon
func _process(_delta: float) -> void:
	if _current_heat > heat_capacity && _is_overheating == false:
		_current_heat = heat_capacity + (heat_capacity*0.05)
		$SpriteProj.hide()
		_is_overheating = true
	elif _is_overheating == true && _current_heat <= heat_capacity * heat_cooled_factor:
		$SpriteProj.show()
		_is_overheating = false
