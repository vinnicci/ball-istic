extends State


func on_enter(target) -> void:
	print("flee")


func on_exit(target) -> void:
	pass


func on_input(target, event : InputEvent) -> void:
	pass


func on_process(target, delta : float) -> void:
	var ai_node = target.get_node("AI")
	if ai_node.is_weapon_overheating == true && ai_node.is_shield_low == true:
		go_to("Follow")
	if ai_node.in_detection_range == false:
		go_to("Idle")
	ai_node.flee(delta)


func on_physics_process(target, delta : float) -> void:
	pass