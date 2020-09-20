extends "res://scenes/level/_base/_BaseAccess.gd"


signal autosaved


func _on_Access_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$AccessUI/Label.visible = !$AccessUI/Label.visible
		$EnterSound.play()
		$Sprite/Anim.stop()
		$Sprite.modulate.a = 1.0
		body.ui_inventory.accessing = "bot_station"
		body.update_player_vars()
		emit_signal("autosaved")


func _on_Access_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$AccessUI/Label.visible = !$AccessUI/Label.visible
		$ExitSound.play()
		$Sprite/Anim.play("fading")
		body.ui_inventory.accessing = ""
