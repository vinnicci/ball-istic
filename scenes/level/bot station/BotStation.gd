extends "res://scenes/level/_base/_BaseAccess.gd"


signal autosaved


func _on_Access_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$AccessUI/Label.visible = !$AccessUI/Label.visible
		$EnterSound.play()
		$Sprite/Anim.stop()
		$Sprite.modulate.a = 1.0
		body.ui_access = "bot_station"
		emit_signal("autosaved")


func _on_Access_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$AccessUI/Label.visible = !$AccessUI/Label.visible
		$ExitSound.play()
		$Sprite/Anim.play("fading")
		body.ui_access = ""
		body.reset_bot_vars()
		body.update_player_vars()
