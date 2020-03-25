extends Node2D

#don't forget to set target node on FSM
#recommended to set state names
onready var level_node: = get_parent().get_parent().get_parent()
onready var bot_node: = get_parent()
var target = null
var points: Array
var next_point: Vector2
var in_detection_range: bool = false
var in_line_of_sight: bool = false
var is_stuck: bool = false
var is_idle: bool = true


func _ready() -> void:
	$VelocityRay.cast_to.x += bot_node.bot_radius


func get_points(start: Vector2, end: Vector2) -> void:
	points = []
	if is_instance_valid(target) == false:
		return
	points = level_node.get_points(start, end)
	next_point = points.pop_front()


func _control(delta) -> void:
	if is_instance_valid(target) == false:
		return
	$TargetRay.look_at(target.global_position)
	if $TargetRay.get_collider() == target:
		if in_line_of_sight == false && is_idle == true:
			$Detect.play()
			is_idle = false
		in_line_of_sight = true
	else:
		in_line_of_sight = false


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
	bot_node.velocity = Vector2(0,0)
	bot_node.velocity = Vector2(1,0).rotated($VelocityRay.global_rotation) * delta


func _flee(delta) -> void:
	if bot_node.is_in_control == false:
		return
	if bot_node.roll_mode == false:
		bot_node.switch_mode()
	$VelocityRay.global_rotation = $TargetRay.global_rotation - deg2rad(180)
	if is_stuck == true:
		$VelocityRay.global_rotation += $VelocityRay.get_collision_normal().angle()
	if is_stuck == true && bot_node.linear_velocity.length() > 400:
		is_stuck = false
	elif is_stuck == false && bot_node.linear_velocity.length() < 70:
		is_stuck = true
	bot_node.velocity = Vector2(0,0)
	bot_node.velocity = Vector2(1,0).rotated($VelocityRay.global_rotation) * delta


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body.get_parent().name == "Bots" && bot_node.is_hostile != body.is_hostile:
		target = body
		$TargetRay.enabled = true
		in_detection_range = true


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body == target:
		$TargetRay.enabled = false
		in_detection_range = false
		is_idle = true
