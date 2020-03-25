extends "res://scenes/ai/_BaseAI.gd"


var in_weapon_range: bool = false


func _seek_target(delta) -> void:
	if bot_node.is_in_control == false:
		return
	if bot_node.roll_mode == false:
		bot_node.switch_mode()
	if points.size() == 0 || target.global_position.distance_to(points.back()) < 800:
		get_points(self.global_position, target.global_position)
	if global_position.distance_to(next_point) < 100:
		next_point = points.pop_front()
		$VelocityRay.look_at(next_point)
	if bot_node.timer_charge_cooldown.is_stopped() == true && in_line_of_sight == true:
		bot_node.charge_attack($VelocityRay.global_rotation)
	bot_node.velocity = Vector2(0,0)
	bot_node.velocity = Vector2(1,0).rotated($VelocityRay.global_rotation) * delta


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
