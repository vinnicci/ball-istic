extends "res://scenes/ai/_BaseAI.gd"


var is_backing_off: bool = false


func _ready() -> void:
	randomize()
	$ChargeRange/CollisionShape2D.shape.radius = rand_range(120, 220) + bot_node.bot_radius
	$VelocityRay.cast_to.x += bot_node.bot_radius


func chase_target(delta) -> void:
	if bot_node.is_in_control == false:
		return
	if points.size() == 0 || target.global_position.distance_to(points.back()) < 800:
		get_points(self.global_position, target.global_position)
	if global_position.distance_to(next_point) < 100:
		next_point = points.pop_front()
		$VelocityRay.look_at(next_point)
	bot_node.velocity = Vector2(0,0)
	bot_node.velocity = Vector2(1,0).rotated($VelocityRay.global_rotation) * delta


func _on_ChargeRange_body_entered(body: Node) -> void:
	if body == target && bot_node.timer_charge_cooldown.is_stopped() == true && is_backing_off == false:
		bot_node.charge_attack($TargetRay.global_rotation)
		is_backing_off = true


func _on_BackOffRange_body_exited(body: Node) -> void:
	if body == target:
		is_backing_off = false
		is_stuck = false


func _on_BackOffRange_body_entered(body: Node) -> void:
	if body == target:
		if bot_node.timer_charge_cooldown.is_stopped() == false:
			is_backing_off = true
