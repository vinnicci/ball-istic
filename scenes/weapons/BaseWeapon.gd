extends Node2D

export (PackedScene) var Projectile

func get_projectile() -> Area2D:
	return Projectile.instance()

func _on_Cooldown_timeout() -> void:
	$Cooldown.stop()
