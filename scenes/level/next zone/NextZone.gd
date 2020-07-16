extends "res://scenes/level/_base/_BaseAccess.gd"


export var to_level: String = ""
export var position_node: String = ""
signal moved


func _on_Access_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER == true:
		emit_signal("moved", to_level, position_node)
