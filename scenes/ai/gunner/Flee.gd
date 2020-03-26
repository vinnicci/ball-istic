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
	if weapon_node.is_overheating == false && target.current_shield > target.shield_capacity * 0.1 == true:
		go_to("Seek")
	if ai_node.in_detection_range == false:
		go_to("Idle")


#func on_physics_process(target, delta : float) -> void:
#	pass
