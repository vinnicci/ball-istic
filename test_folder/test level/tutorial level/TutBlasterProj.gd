extends "res://scenes/weapons/_base/_BaseProjectile.gd"


const DUMMY_B = preload("res://test_folder/test level/tutorial level/DummyB.gd")


func _on_Projectile_body_entered(body: Node) -> void:
	if body is DUMMY_B:
		return
	._on_Projectile_body_entered(body)
