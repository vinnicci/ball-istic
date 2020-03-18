extends State


func on_enter(target) -> void:
	target.get_node("Status").get_node("Label").text = state_name
	target.points = []

func on_exit(target) -> void:
	pass

func on_input(target, event : InputEvent) -> void:
	pass

func on_process(target, delta : float) -> void:
	pass

func on_physics_process(target, delta : float) -> void:
	target.velocity = Vector2(0,0)
	if target.in_line_of_sight == true && target.in_detection_range == true:
		go_to("Chase")
