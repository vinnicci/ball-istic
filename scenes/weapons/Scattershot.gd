extends "res://scenes/weapons/_BaseWeapon.gd"


func _instantiate_projectile():
	var count = 10
	var projectiles = []
	var projectile = Projectile.instance()
	for i in count:
		projectiles.append(projectile.duplicate(DUPLICATE_USE_INSTANCING))
	return projectiles
