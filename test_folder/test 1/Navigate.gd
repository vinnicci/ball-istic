extends State


func on_physics_process(target, delta : float) -> void:
	if target.found == false || target.target == null:
		go_to("Idle")
	target._control(delta)
