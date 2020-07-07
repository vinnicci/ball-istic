extends "res://scenes/level/tileset/DoorBrown.gd"


func _on_Area2D_body_exited(body: Node) -> void:
	if body is Global.CLASS_BOT && is_door_free() == true:
		close()
