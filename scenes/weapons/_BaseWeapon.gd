extends Node2D

#be sure to name root node as Weapon
#however you can name the scene as anything

export (PackedScene) var Projectile
export (int) var heat_per_shot
export (int) var heat_capacity
export (float) var heat_dissipation

func get_projectile() -> Area2D:
	return Projectile.instance()
