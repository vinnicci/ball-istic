extends State


func on_enter(target) -> void:
	target.get_node("Status").get_node("Label").text = state_name

func on_exit(target) -> void:
	pass

func on_input(target, event : InputEvent) -> void:
	pass

func on_process(target, delta : float) -> void:
	pass

func on_physics_process(target, delta : float) -> void:
	if is_instance_valid(target.target_bot) == false || target.is_backing_off == false:
		go_to("Chase")
	target.back_off(delta)
