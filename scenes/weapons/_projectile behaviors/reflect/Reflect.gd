extends "res://scenes/weapons/_projectile behaviors/_base/_BaseProjBehavior.gd"


func _ready() -> void:
	var ray_dist = 40
	_init_raycast(ray_dist)
