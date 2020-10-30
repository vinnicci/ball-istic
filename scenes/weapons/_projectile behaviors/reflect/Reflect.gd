extends "res://scenes/weapons/_projectile behaviors/_base/_BaseProjBehavior.gd"


func set_parent(new_parent) -> void:
	.set_parent(new_parent)
	var ray_dist = _parent_node.get_node("CollisionShape").shape.radius
	_init_reflect_raycast(ray_dist * 4)
