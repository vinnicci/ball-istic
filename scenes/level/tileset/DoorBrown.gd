extends Node2D


var _arr_objects_within: int = 0
var is_open: bool = false


func is_door_free():
	return _arr_objects_within == 0


func open() -> void:
	if is_open == false:
		$Anim.play("open")
		is_open = true


func close() -> void:
	if is_open == true:
		$Anim.play_backwards("open")
		is_open = false


func _on_Within_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT:
		_arr_objects_within += 1


func _on_Within_body_exited(body: Node) -> void:
	if body is Global.CLASS_BOT:
		_arr_objects_within -= 1
