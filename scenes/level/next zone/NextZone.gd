extends "res://scenes/level/_base/_BaseAccess.gd"


export var to_level: String = ""
export var position_node: String = ""
signal moved

var _entered: bool = false


func _on_Access_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER == true && _entered == false:
		emit_signal("moved", to_level, position_node)
		_entered = true
