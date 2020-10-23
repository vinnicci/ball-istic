extends "res://scenes/bots/self destruct/Explosive.gd"


func _on_Bot_body_entered(body: Node) -> void:
	if (body is Global.CLASS_PLAYER &&
		_level_node.get_node("Nav/Secret").visible == false):
		get_node("AI").engage(_level_node.get_node("Bots/ExplosiveDummy"))
	._on_Bot_body_entered(body)
