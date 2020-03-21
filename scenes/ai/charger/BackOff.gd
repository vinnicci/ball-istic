extends State


func on_enter(target) -> void:
	target.get_node("AI").get_node("Status").text = state_name

func on_exit(target) -> void:
	pass

func on_input(target, event : InputEvent) -> void:
	pass

func on_process(target, delta : float) -> void:
	if is_instance_valid(target.get_node("AI").target_bot) == false || target.get_node("AI").is_backing_off == false:
		go_to("Chase")
	target.get_node("AI").back_off(delta)

func on_physics_process(target, delta : float) -> void:
	pass
