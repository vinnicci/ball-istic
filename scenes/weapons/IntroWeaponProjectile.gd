extends "res://scenes/weapons/BaseProjectile.gd"

func _on_Projectile_body_entered(body: Node) -> void:
	if body.name != "Player":
		queue_free()
		return
