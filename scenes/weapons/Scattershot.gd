extends "res://scenes/weapons/_BaseWeapon.gd"


func _instantiate_projectile():
	var count = 10
	var projectiles = []
	for i in count:
		projectiles.append(Projectile.instance())
	return projectiles
