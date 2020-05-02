extends "res://scenes/levels/_base/_BaseAccess.gd"


func _on_Area2D_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$AccessUI/Label.visible = !$AccessUI/Label.visible
		$EnterSound.play()
		$Sprite/Anim.stop()
		$Sprite.modulate.a = 1.0
		body.is_using_bot_station = true


func _on_Area2D_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$AccessUI/Label.visible = !$AccessUI/Label.visible
		$ExitSound.play()
		$Sprite/Anim.play("fading")
		body.is_using_bot_station = false
		body.reset_bot_vars()
		body.update_player_vars()
