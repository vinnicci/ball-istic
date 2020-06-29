extends Node2D


var _detected: Array = []
var _target_bot: Global.CLASS_BOT = null
var _parent_node: Area2D
var _level_node: Node = null


func _init_detector(radius: float) -> void:
	$DetectionRange/CollisionShape2D.shape.radius = radius
	$DetectionRange.monitoring = true
	$DetectionRange.connect("body_entered", self, "_on_DetectionRange_body_entered")


func _init_raycast(cast_to: float) -> void:
	$TargetRay.cast_to = Vector2(cast_to, 0)
	$TargetRay.enabled = true


func _init_timer() -> void:
	$SplitTimer.connect("timeout", self, "_on_SplitTimer_timeout")


func set_parent(new_parent: Area2D) -> void:
	_parent_node = new_parent


func set_level(new_level: Node) -> void:
	_level_node = new_level


func _physics_process(delta: float) -> void:
	#only used by homing effect
	if $TargetRay.enabled == true && _detected.size() != 0 && _target_bot == null:
		for target in _detected:
			if is_instance_valid(target) == false:
				_detected.erase(target)
				continue
			$TargetRay.look_at(target.global_position)
			if $TargetRay.get_collider() == target:
				_target_bot = target
				return


#refactor?? to simply get values rather than recalculating
#############
# btree tasks
#############


########
# homing
########
func task_homing(task):
	if is_instance_valid(_target_bot) == false || _target_bot.state == Global.CLASS_BOT.State.DEAD:
		_target_bot = null
		task.succeed()
		return
	if _parent_node.is_stopped == true:
		task.failed()
		return
	var target_v = (_target_bot.global_position - global_position).normalized() * _parent_node.speed
	var steer_v = (target_v - _parent_node.velocity).normalized() * task.get_param(0)
	var final_v = _parent_node.velocity + steer_v
	_parent_node.acceleration = final_v
	task.succeed()
	return


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT && _parent_node.shooter_faction() != body.current_faction:
		_detected.append(body)


################
# split to three
################
var split_count: int = 2
var _is_split: bool = false


func task_split(task):
	if _parent_node.is_stopped == true || split_count == 0:
		task.failed()
		return
	if _is_split == false:
		$SplitTimer.wait_time = task.get_param(0)
		$SplitTimer.start()
		_is_split = true
	task.succeed()
	return


func _on_SplitTimer_timeout() -> void:
	if _parent_node.is_stopped == true:
		return
	var spread: = 5
	for i in range(2):
		spread *= -1
		_level_node.spawn_projectile(_split(split_count - 1), _parent_node.global_position, 
			_parent_node.global_rotation + deg2rad(spread), _parent_node.shooter_faction(), null)
	_parent_node.queue_free()


func _split(count: int) -> Node:
	var clone = _parent_node.duplicate()
	clone.get_node("ProjBehavior").split_count = count
	return clone


#############
# speed curve
#############
export var speed_curve: Curve


func task_curve_speed(task):
	if _parent_node.is_stopped == true:
		task.failed()
		return
	var range_timer = _parent_node.get_node("RangeTimer")
	_parent_node.current_speed = speed_curve.interpolate((range_timer.wait_time -
		range_timer.time_left)/range_timer.wait_time) * _parent_node.speed
	if _parent_node.current_speed == 0:
		_parent_node.current_speed = 1
	task.succeed()
	return


#############
# steer curve
#############
export var steer_curve: Curve
export var randomize_direction: bool = false
onready var _random_dir = rand_range(0, 1.0)
var _old_v = null


func task_curve_steer(task):
	# for compatibility with homing, this behavior will stop if homing target is detected
	if _target_bot != null || _parent_node.is_stopped == true:
		task.failed()
		return
	if _old_v == null:
		_old_v = _parent_node.velocity
	var r_timer = _parent_node.get_node("RangeTimer")
	var x_val = (r_timer.wait_time - r_timer.time_left) / r_timer.wait_time
	var y_val = steer_curve.interpolate(x_val)
	if randomize_direction == true && _random_dir <= 0.5:
		y_val *= -1
	_parent_node.velocity = _old_v.rotated(deg2rad(90*y_val))
	task.succeed()
	return


#########
# reflect
#########
var reflect_count: int = 3


func task_reflect(task):
	if _parent_node.is_stopped == true || reflect_count == 0:
		task.failed()
		return
	$TargetRay.global_rotation = _parent_node.global_rotation
	var body = $TargetRay.get_collider()
	if body is Global.CLASS_LEVEL_OBJECT:
		_level_node.spawn_projectile(_reflect(reflect_count - 1), _parent_node.global_position, 
			Vector2(1,0).rotated($TargetRay.global_rotation).reflect($TargetRay.get_collision_normal()).angle() - deg2rad(180),
			_parent_node.shooter_faction(), null)
		_parent_node.queue_free()
	task.succeed()


func _reflect(count: int) -> Node:
	var clone = _parent_node.duplicate()
	clone.get_node("ProjBehavior").reflect_count = count
	return clone
