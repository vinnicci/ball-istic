extends Node2D

func _ready() -> void:
	for child_node in get_children():
		if child_node.has_method("weapon_shoot"):
			child_node.connect("shoot", self, "_on_shoot")

func _on_shoot(_projectile, _proj_position, _proj_direction) -> void:
	add_child(_projectile)
	_projectile._travel(_proj_position, _proj_direction)
