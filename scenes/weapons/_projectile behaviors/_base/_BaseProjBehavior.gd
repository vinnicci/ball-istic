extends Node2D


var _detected: Array = []
var _target_bot: Global.CLASS_BOT = null

onready var _parent_node: Area2D = get_parent()


func _physics_process(delta: float) -> void:
	if _detected.size() != 0 && _target_bot == null:
		for target in _detected:
			if is_instance_valid(target) == false:
				_detected.erase(target)
				continue
			$TargetRay.look_at(target.global_position)
			if $TargetRay.get_collider() == target:
				_target_bot = target
				return


func _init_detector(radius: float) -> void:
	$DetectionRange/CollisionShape2D.shape.radius = radius
	$DetectionRange.connect("body_entered", self, "_on_DetectionRange_body_entered")

func _init_raycast(cast_to: float) -> void:
	$TargetRay.cast_to = Vector2(cast_to, 0)
	$TargetRay.enabled = true


#############
# btree tasks
#############


########
# homing
########
func task_homing(task):
	if is_instance_valid(_target_bot) == false || _target_bot.is_alive() == false:
		_target_bot = null
		task.succeed()
		return
	var target_vector = (_target_bot.global_position - global_position).normalized() * _parent_node.speed
	var steer_vector = (target_vector - _parent_node.velocity).normalized() * task.get_param(0)
	var final_vector = _parent_node.velocity + steer_vector
	_parent_node.acceleration = final_vector
	_parent_node.get_node("Sprite").global_rotation = final_vector.angle()
	task.succeed()
	return


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT && _parent_node.origin() != body.is_hostile():
		_detected.append(body)


################
# split to three
################
var is_split: bool = false


func task_split_to_three(task):
	if _parent_node.is_stopped() == true || is_split == true:
		return
	is_split = true
	$SplitToThreeTimer.wait_time = task.get_param(0)
	$SplitToThreeTimer.start()
	task.succeed()
	return


func _on_SplitToThreeTimer_timeout() -> void:
	if _parent_node.is_stopped() == true:
		return
	var spread: = 10
	for i in range(2):
		spread *= -1
		Global.current_level.spawn_projectile(_split(), _parent_node.global_position, 
			_parent_node.global_rotation + deg2rad(spread), _parent_node.origin())


func _split() -> Node:
	var clone = _parent_node.duplicate(DUPLICATE_USE_INSTANCING)
	clone.get_node("ProjBehavior").is_split = true
	return clone


#############
# curve speed
#############
export var curve: Curve


func task_curve_speed(task):
	var range_timer = _parent_node.get_node("RangeTimer")
	_parent_node.current_speed = curve.interpolate((range_timer.wait_time - range_timer.time_left)/range_timer.wait_time) * _parent_node.speed
	if _parent_node.current_speed == 0:
		_parent_node.current_speed = 1
	task.succeed()
	return
