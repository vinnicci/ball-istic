extends Node2D


var _arr_objects_within: int = 0
#var _level_node: Node


#func set_level(new_level: Node) -> void:
#	_level_node = new_level


func is_door_free():
	return _arr_objects_within == 0


func open() -> void:
	$Anim.play("open")


func close() -> void:
	$Anim.play_backwards("open")


func _on_Within_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT:
		_arr_objects_within += 1


func _on_Within_body_exited(body: Node) -> void:
	if body is Global.CLASS_BOT:
		_arr_objects_within -= 1
