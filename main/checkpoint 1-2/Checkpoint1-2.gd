extends "res://scenes/level/_base/_BaseLevel.gd"


signal moved


func _on_ToLvl1_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER && body.state == Global.CLASS_BOT.State.ROLL:
		emit_signal("moved", "lvl_1", "PlayerPos2")
