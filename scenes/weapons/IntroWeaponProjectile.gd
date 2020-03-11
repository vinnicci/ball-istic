extends "res://scenes/weapons/_BaseProjectile.gd"


func _travel(pos, dir):
	position = pos
	rotation = dir + rand_range(deg2rad(-5), deg2rad(5))
