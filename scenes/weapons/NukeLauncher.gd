extends "res://scenes/weapons/_BaseWeapon.gd"


func _process(_delta: float) -> void:
	if current_heat > heat_capacity && is_overheating == false:
		current_heat = heat_capacity + (heat_capacity*0.05)
		$SpriteProj.hide()
		is_overheating = true
	elif is_overheating == true && current_heat <= heat_capacity * heat_cooled_factor:
		$SpriteProj.show()
		is_overheating = false
