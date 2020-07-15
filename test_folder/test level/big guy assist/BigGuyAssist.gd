extends "res://scenes/level/_base/_BaseLevel.gd"


func _on_ToCP12_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		emit_signal("moved", "Checkpoint1-2", "PlayerPos2")


func open_doors() -> void:
	.open_doors()
