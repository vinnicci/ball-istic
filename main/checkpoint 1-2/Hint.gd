extends "res://scenes/level/hint/Hint.gd"


func _on_Area2D_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$AccessUI/Label.visible = true
		$Sprite/Anim.stop()
		$Sprite.modulate.a = 1.0


func _on_Area2D_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$AccessUI/Label.visible = false
		$Sprite/Anim.play("fading")
