extends "res://scenes/level/BaseLevel.gd"

func _on_Player_shoot(_projectile, _proj_position, _proj_direction) -> void:
	add_child(_projectile)
	_projectile._travel(_proj_position, _proj_direction)
