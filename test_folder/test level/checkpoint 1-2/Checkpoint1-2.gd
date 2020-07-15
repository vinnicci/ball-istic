extends "res://scenes/level/_base/_BaseLevel.gd"


func _on_ToLvl1_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		emit_signal("moved", "Level1", "PlayerPos2")


func _on_ToEnd_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		emit_signal("moved", "BigGuyAssist", "PlayerPos1")
