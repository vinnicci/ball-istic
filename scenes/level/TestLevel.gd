extends Node2D

func _on_Player_shoot(projectile, proj_position, proj_direction) -> void:
	add_child(projectile)
	projectile.travel(proj_position, proj_direction)
