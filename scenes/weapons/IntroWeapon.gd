extends "res://scenes/weapons/_BaseWeapon.gd"


func _instantiate_projectile():
	var projectiles = []
	projectiles.append(Projectile.instance())
	return projectiles
