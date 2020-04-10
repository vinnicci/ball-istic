extends Node2D

#don't forget to set target node on FSM
#recommended to set state names
onready var level_node: = get_parent().get_parent().get_parent()
onready var bot_node: = get_parent()
onready var state: String = $FSM.initial_state
var target = null
var points: Array
var next_point: Vector2
var detection_sound_ready: bool = true
var escape_points: Array = []
var escape_route: int = 0
var in_detection_range: bool = false #both must be true to seek
var in_line_of_sight: bool = false
var has_flee_points: bool = true


func _ready() -> void:
	$VelocityRay.cast_to.x += bot_node.bot_radius
	var i = 0
	for escape_point in level_node.get_node("Nav").get_node("EscapePoints").get_children():
		escape_points.append(escape_point.global_position)
		i += 1


func get_points(start: Vector2, end: Vector2) -> void:
	points = []
	if is_instance_valid(target) == false:
		return
	points = level_node.get_points(start, end)
	next_point = points.pop_front()


#for all states
func _control(delta) -> void:
	if is_instance_valid(target) == false:
		in_detection_range = false
		return
	
	#line of sight detection
	_check_if_in_line_of_sight()
	
	if bot_node.is_in_control == false:
		return
	
	#in specific state func
	_state_control(delta)


func _check_if_in_line_of_sight() -> void:
	$TargetRay.look_at(target.global_position)
	if $TargetRay.get_collider() == target:
		if in_line_of_sight == false && detection_sound_ready == true:
			$Detect.play()
			detection_sound_ready = false
		in_line_of_sight = true
	else:
		in_line_of_sight = false


#for specific states
func _state_control(delta):
	pass


func _idle(delta):
	bot_node.velocity = Vector2(0,0)


#default seek func
func _seek_target(delta) -> void:
	if bot_node.roll_mode == false:
		bot_node.switch_mode()
	if points.size() == 0 || target.global_position.distance_to(points.back()) < 800:
		get_points(global_position, target.global_position)
	if global_position.distance_to(next_point) < 100:
		next_point = points.pop_front()
		$VelocityRay.look_at(next_point)
	bot_node.velocity = Vector2(0,0)
	bot_node.velocity = Vector2(1,0).rotated($VelocityRay.global_rotation) * delta


#default flee func -- blind fleeing still wip
func _flee(delta):
	if bot_node.roll_mode == false:
		bot_node.switch_mode()
	if has_flee_points == true && escape_points.size() > 1:
		#fill in the EscapePoints node with position2d in the level node
		_flee_with_escape_route(delta)
	else:
		#blind fleeing, wip
		#easily gets cornered
		_flee_blind(delta)
	bot_node.velocity = Vector2(0,0)
	bot_node.velocity = Vector2(1,0).rotated($VelocityRay.global_rotation) * delta


func _flee_with_escape_route(delta) -> void:
	if escape_points[escape_route].distance_to(target.global_position) > 600:
		get_points(global_position, escape_points[escape_route])
	else:
		escape_route += 1
		if escape_route == escape_points.size():
			escape_route = 0
		return
	if global_position.distance_to(next_point) < 100:
		next_point = points.pop_front()
		$VelocityRay.look_at(next_point)


func _flee_blind(delta) -> void:
	$VelocityRay.global_rotation = $TargetRay.global_rotation - deg2rad(180)


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body.get_parent().name == "Bots" && bot_node.is_hostile != body.is_hostile:
		target = body
		$TargetRay.enabled = true
		in_detection_range = true


func _on_DetectionRange_body_exited(body: Node) -> void:
	pass
#	if body == target:
#		$TargetRay.enabled = false
#		in_detection_range = false
#		is_idle = true


func _on_FleeChargeRange_body_entered(body: Node) -> void:
	if body == target && state == "Flee":
		bot_node.charge_attack($VelocityRay.global_rotation)
