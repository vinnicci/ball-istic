extends State


var ai_node: Node2D


func on_enter(target) -> void:
	ai_node = target.get_node("AI")
	ai_node.state = state_name


#func on_exit(target) -> void:
#	pass
#
#func on_input(target, event : InputEvent) -> void:
#	pass


func on_process(target, delta : float) -> void:
	if ai_node.in_detection_range == true && ai_node.in_line_of_sight == true:
		go_to("Flee")


#func on_physics_process(target, delta : float) -> void:
#	pass
