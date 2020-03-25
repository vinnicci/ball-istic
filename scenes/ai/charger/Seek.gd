extends State


func on_enter(target) -> void:
	target.get_node("AI").points = []


#func on_exit(target) -> void:
#	pass
#
#
#func on_input(target, event : InputEvent) -> void:
#	pass


func on_process(target, delta : float) -> void:
	var ai_node = target.get_node("AI")
	if is_instance_valid(ai_node.target) == false || ai_node.in_detection_range == false:
		go_to("Idle")
	if ai_node.is_backing_off == true:
		go_to("Flee")
	ai_node._seek_target(delta)


#func on_physics_process(target, delta : float) -> void:
#	pass
