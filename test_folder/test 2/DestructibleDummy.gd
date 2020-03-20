extends "res://scenes/bots/DestructibleDummy.gd"


onready var GPS = get_parent().get_parent()
var points: Array = []
var next_point: Vector2
var target_bot: Node
var in_detection_range: bool = false
var in_line_of_sight: bool = false
var is_backing_off: bool = false


func _ready() -> void:
	randomize()
	$ChargeRange/CollisionShape2D.shape.radius = rand_range(150, 200)


func get_new_points() -> void:
	points = GPS.get_points(self, target_bot)
	next_point = points.pop_front()


func _control(delta) -> void:
	$Status.global_rotation = 0
	if is_instance_valid(target_bot) == false:
		return
	$TargetRay.look_at(target_bot.global_position)
	if $TargetRay.get_collider() == target_bot:
		in_line_of_sight = true
	else:
		in_line_of_sight = false


func chase_target(delta) -> void:
	if is_in_control == false:
		return
	if points.size() == 0 || (target_bot.global_position - points.back()).length() < 1000:
		get_new_points()
	if (global_position - next_point).length() < 100:
		next_point = points.pop_front()
		$VelocityRay.look_at(next_point)
	velocity = Vector2(0,0)
	velocity = Vector2(1,0).rotated($VelocityRay.global_rotation) * delta


func back_off(delta) -> void:
	#wip!!
	if is_in_control == false:
		return
	$VelocityRay.look_at(target_bot.global_position)
	velocity = Vector2(0,0)
	velocity += Vector2(1,0).rotated($VelocityRay.global_rotation - 180) * delta


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body.get_parent().name == "Bots" && is_hostile != body.is_hostile:
		target_bot = body
		get_new_points()
		$TargetRay.enabled = true
		in_detection_range = true


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body == target_bot:
		$TargetRay.enabled = false
		in_detection_range = false


func _on_ChargeRange_body_entered(body: Node) -> void:
	if body == target_bot:
		if timer_charge_cooldown.is_stopped() == true && is_backing_off == false:
			charge_attack($TargetRay.global_rotation)
			is_backing_off = true


func _on_BackOffRange_body_exited(body: Node) -> void:
	if body == target_bot:
		is_backing_off = false


func _on_BackOffRange_body_entered(body: Node) -> void:
	if body == target_bot:
		if timer_charge_cooldown.is_stopped() == false:
			is_backing_off = true
