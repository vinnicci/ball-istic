extends State


func on_enter(target) -> void:
	print("navigating")


func on_physics_process(target, delta : float) -> void:
	target._control(delta)
