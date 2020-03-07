extends Node2D

func _ready() -> void:
	for child_node in get_children():
		if child_node.has_method("weapon_shoot"):
			child_node.connect("shoot", self, "_on_shoot")

func _on_shoot(projectile, proj_position, proj_direction, hostile_proj) -> void:
	add_child(projectile)
	projectile._travel(proj_position, proj_direction, hostile_proj)
