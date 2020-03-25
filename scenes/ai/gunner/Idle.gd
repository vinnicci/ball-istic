extends State


func on_enter(target) -> void:
	target.get_node("AI").state = state_name
#
#
#func on_exit(target) -> void:
#	pass
#
#
#func on_input(target, event : InputEvent) -> void:
#	pass


func on_process(target, delta : float) -> void:
	var ai_node = target.get_node("AI")
	if ai_node.in_detection_range == true && ai_node.in_line_of_sight == true:
		go_to("Seek")
	target.velocity = Vector2(0,0)


#func on_physics_process(target, delta : float) -> void:
#	pass
