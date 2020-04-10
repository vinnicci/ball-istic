extends "res://scenes/weapons/_base/_BaseProjectile.gd"


func _travel(pos, dir):
	randomize()
	position = pos
	rotation = dir + rand_range(deg2rad(-20.0), deg2rad(20.0))
