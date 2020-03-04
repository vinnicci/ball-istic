extends "res://scenes/level/BaseLevel.gd"

func _on_Player_shoot(projectile, proj_position, proj_direction) -> void:
	add_child(projectile)
	projectile._travel(proj_position, proj_direction)
