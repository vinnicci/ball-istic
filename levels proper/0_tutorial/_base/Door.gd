extends "res://scenes/level/tileset/brown/DoorBrown.gd"


var _passed: bool = false


func _on_Area2D_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER && is_door_free() == true && _passed == false:
		close()
		_passed = true
