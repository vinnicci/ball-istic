extends "res://scenes/levels/_base/_BaseAccess.gd"


func _on_Area2D_body_entered(body: Node) -> void:
	if body.name == "Player":
		$Sprite/Anim.stop()
		$Sprite.modulate.a = 1.0


func _on_Area2D_body_exited(body: Node) -> void:
	if body.name == "Player":
		$Sprite/Anim.play("fading")
