extends "res://scenes/weapons/_BaseWeapon.gd"

func _instantiate_projectile():
	return [Projectile.instance()]
