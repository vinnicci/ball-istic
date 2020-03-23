extends "res://scenes/ai/_BaseAI.gd"


var in_weapon_range: bool = false
var is_weapon_overheating: bool = false
var is_shield_low: bool = false #20% minimum to flee
var is_stuck: bool = false


func follow_target(delta) -> void:
	if bot_node.is_in_control == false:
		return
	if bot_node.roll_mode == false:
		bot_node.switch_mode()
	if points.size() == 0 || target.global_position.distance_to(points.back()) < 800:
		get_points(self.global_position, target.global_position)
	if global_position.distance_to(next_point) < 100:
		next_point = points.pop_front()
		$VelocityRay.look_at(next_point)
	bot_node.velocity = Vector2(0,0)
	bot_node.velocity = Vector2(1,0).rotated($VelocityRay.global_rotation) * delta


func flee(delta) -> void:
	if bot_node.is_in_control == false:
		return
	if bot_node.roll_mode == false:
		bot_node.switch_mode()
	$VelocityRay.global_rotation = $TargetRay.global_rotation - deg2rad(180)
	if is_stuck == true:
		$VelocityRay.global_rotation += $VelocityRay.get_collision_normal().angle()
	if is_stuck == true && bot_node.linear_velocity.length() > 400:
		is_stuck = false
	if bot_node.linear_velocity.length() < 100 && is_stuck == false:
		is_stuck = true
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
	if bot_node.get_node("Weapon").is_overheating == true:
		is_weapon_overheating = true
	if bot_node.current_shield < bot_node.shield_capacity * 0.2:
		is_shield_low = true


func _on_WeaponRange_body_entered(body: Node) -> void:
	if body == target && bot_node.is_hostile != body.is_hostile:
		in_weapon_range = true


func _on_WeaponRange_body_exited(body: Node) -> void:
	if body == target:
		in_weapon_range = false
