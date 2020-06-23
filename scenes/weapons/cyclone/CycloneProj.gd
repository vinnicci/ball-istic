extends "res://scenes/weapons/_base/_BaseProjectile.gd"


func _ready() -> void:
	proj_range = rand_range(1500, 2500)
