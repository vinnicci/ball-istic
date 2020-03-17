extends State


func on_physics_process(target, delta : float) -> void:
	if target.found == true:
		go_to("Navigate")
