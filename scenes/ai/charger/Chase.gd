extends State


func on_enter(target) -> void:
	target.get_node("AI").get_node("Status").text = state_name

func on_exit(target) -> void:
	pass

func on_input(target, event : InputEvent) -> void:
	pass

func on_process(target, delta : float) -> void:
	if target.get_node("AI").target_bot == null || target.get_node("AI").in_detection_range == false:
		go_to("Idle")
	if target.get_node("AI").is_backing_off == true:
		go_to("BackOff")
	target.get_node("AI").chase_target(delta)

func on_physics_process(target, delta : float) -> void:
	pass
