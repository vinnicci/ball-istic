extends "res://scenes/ai/_BaseAI.gd"


var in_weapon_range: bool = false


func shoot_target(delta) -> void:
	if bot_node.is_in_control == false:
		return
	if bot_node.roll_mode == true:
		bot_node.switch_mode()
	bot_node.get_node("Weapon").look_at(target.global_position)
	if in_line_of_sight == true:
		bot_node.shoot_weapon()


func _on_WeaponRange_body_entered(body: Node) -> void:
	if body == target && bot_node.is_hostile != body.is_hostile:
		in_weapon_range = true


func _on_WeaponRange_body_exited(body: Node) -> void:
	if body == target:
		in_weapon_range = false
