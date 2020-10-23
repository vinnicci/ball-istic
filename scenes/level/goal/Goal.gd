extends "res://scenes/level/_base/_BaseAccess.gd"


signal quest_updated


func _on_Access_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$Sprite/Anim.stop()
		var tween = $Sprite/Tween
		tween.interpolate_property($Sprite, "modulate", $Sprite.modulate,
			Color(0.96, 0.24, 0.62, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		emit_signal("quest_updated")


func _on_Tween_tween_all_completed() -> void:
	queue_free()
