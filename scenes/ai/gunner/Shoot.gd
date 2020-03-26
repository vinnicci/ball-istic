extends State


func on_enter(target) -> void:
	target.get_node("AI").state = state_name
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
	var weapon_node = target.current_weapon
	if ai_node.in_weapon_range == false:
		go_to("Seek")
	if weapon_node.is_overheating == true || target.current_shield < target.shield_capacity * 0.05:
		go_to("Flee")


#func on_physics_process(target, delta : float) -> void:
#	pass
