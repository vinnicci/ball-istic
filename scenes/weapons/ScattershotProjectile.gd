extends "res://scenes/weapons/_BaseProjectile.gd"


func _travel(pos, dir):
	randomize()
	position = pos
	rotation = dir + rand_range(deg2rad(-10.0), deg2rad(10.0))
