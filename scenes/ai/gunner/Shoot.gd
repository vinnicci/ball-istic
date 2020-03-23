extends State


#func on_enter(target) -> void:
#	pass
#
#
#func on_exit(target) -> void:
#	pass
#
#
#func on_input(target, event : InputEvent) -> void:
#	pass


func on_process(target, delta : float) -> void:
	var ai_node = target.get_node("AI")
	if ai_node.in_weapon_range == false:
		go_to("Seek")
	if target.get_node("Weapon").is_overheating == true || target.current_shield < target.shield_capacity * 0.05 == true:
		go_to("Flee")
	ai_node.shoot_target(delta)


#func on_physics_process(target, delta : float) -> void:
#	pass
