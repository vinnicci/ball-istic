extends State


var ai_node: Node


func on_enter(target) -> void:
	ai_node = target.get_node("AI")
	ai_node.points = []
	ai_node.state = state_name


#func on_exit(target) -> void:
#	pass
#
#
#func on_input(target, event : InputEvent) -> void:
#	pass


func on_process(target, delta : float) -> void:
	if is_instance_valid(ai_node.target) == false || ai_node.in_detection_range == false:
		go_to("Idle")
	if ai_node.is_backing_off == true:
		go_to("Flee")


#func on_physics_process(target, delta : float) -> void:
#	pass
