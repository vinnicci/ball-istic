extends "res://scenes/level/_base/_BaseLevel.gd"


func _on_ToCP12_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER && body.state == Global.CLASS_BOT.State.ROLL:
		emit_signal("moved", "cp_12", "PlayerPos2")


func open_doors() -> void:
	.open_doors()
	
