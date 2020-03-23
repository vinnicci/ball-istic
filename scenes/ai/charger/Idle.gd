extends State


func on_enter(target) -> void:
	pass


func on_exit(target) -> void:
	pass


func on_input(target, event : InputEvent) -> void:
	pass


func on_process(target, delta : float) -> void:
	target.velocity = Vector2(0,0)
	var ai_node = target.get_node("AI")
	if ai_node.in_line_of_sight == true && ai_node.in_detection_range == true:
		go_to("Chase")


func on_physics_process(target, delta : float) -> void:
	pass
