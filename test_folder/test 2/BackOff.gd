extends State


func on_enter(target) -> void:
	pass

func on_exit(target) -> void:
	pass

func on_input(target, event : InputEvent) -> void:
	pass

func on_process(target, delta : float) -> void:
	pass

func on_physics_process(target, delta : float) -> void:
	if is_instance_valid(target.target_bot) == false || target.is_backing_off == false:
		go_to("Chase")
	target.get_node("VelocityRay").look_at(target.target_bot.global_position)
	target.velocity = Vector2(0,0)
	target.velocity += Vector2(1,0).rotated(target.get_node("VelocityRay").global_rotation - deg2rad(180))
