extends State


func on_enter(target) -> void:
	pass


func on_exit(target) -> void:
	pass


func on_input(target, event : InputEvent) -> void:
	pass


func on_process(target, delta : float) -> void:
	var ai_node = target.get_node("AI")
	if is_instance_valid(ai_node.target) == false || ai_node.is_backing_off == false:
		go_to("Chase")
	ai_node.back_off(delta)


func on_physics_process(target, delta : float) -> void:
	pass
