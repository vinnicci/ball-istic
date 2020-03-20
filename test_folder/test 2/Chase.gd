extends State


func on_enter(target) -> void:
	target.get_node("Status").get_node("Label").text = state_name

func on_exit(target) -> void:
	pass

func on_input(target, event : InputEvent) -> void:
	pass

func on_process(target, delta : float) -> void:
	if target.target_bot == null || target.in_detection_range == false:
		go_to("Idle")
	if target.is_backing_off == true:
		go_to("BackOff")
	target.chase_target(delta)

func on_physics_process(target, delta : float) -> void:
	pass
