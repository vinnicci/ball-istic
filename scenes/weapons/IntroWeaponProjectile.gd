extends "res://scenes/weapons/_BaseProjectile.gd"


func _travel(pos, dir):
	position = pos
	rotation = dir
