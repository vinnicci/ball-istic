extends Node2D


var _parent_node: Area2D
var _level_node: Node


func _init_detector(radius) -> void:
	$DetectionRange/CollisionShape2D.shape = CircleShape2D.new()
	$DetectionRange/CollisionShape2D.shape.radius = radius
	$DetectionRange.monitoring = true
	$DetectionRange.connect("body_entered", self, "_on_DetectionRange_body_entered")
	$DetectionRange.connect("body_exited", self, "_on_DetectionRange_body_exited")


func _init_target_raycast(cast_to) -> void:
	$TargetRay.cast_to = Vector2(cast_to, 0)


func _init_reflect_raycast(cast_to) -> void:
	$ReflectRay.cast_to = Vector2(cast_to, 0)


func _init_timer() -> void:
	$SplitTimer.connect("timeout", self, "_on_SplitTimer_timeout")


func set_parent(new_parent: Area2D) -> void:
	_parent_node = new_parent
	$ReflectRay.global_rotation = _parent_node.global_rotation


func set_level(new_level: Node) -> void:
	_level_node = new_level


func _physics_process(_delta: float) -> void:
	#only used by homing effect
	if _detected.size() != 0 && is_instance_valid(_target_bot) == false:
		var target = _detected.pop_front()
		if is_instance_valid(target) == false || target.state == Global.CLASS_BOT.State.DEAD:
			_detected.erase(target)
			return
		$TargetRay.look_at(target.global_position)
		if $TargetRay.get_collider() == target:
			_target_bot = target
		else:
			_detected.append(target)


func _seek(target_pos: Vector2) -> Vector2:
	var target_v = (target_pos - global_position).normalized() * _parent_node.speed
	var steer_v = (target_v - _parent_node.velocity).normalized() * homing_steer_magnitude
	return _parent_node.velocity + steer_v


#############
# btree tasks
#############


########
# homing
########
export (float) var homing_steer_magnitude: float = 100
var _detected: Array = []
var _target_bot: Node


func task_homing(task):
	if is_instance_valid(_target_bot) == false || _target_bot.state == Global.CLASS_BOT.State.DEAD:
		_target_bot = null
		task.succeed()
		return
	if _parent_node.is_stopped == true:
		task.failed()
		return
	_parent_node.acceleration = _seek(_target_bot.global_position)
	task.succeed()
	return


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT && _parent_node.shooter_faction() != body.current_faction:
		_detected.append(body)


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body == _target_bot:
		return
	if _detected.has(body) == true:
		_detected.erase(body)


################
# cursor seeking
################
func task_cursor_seek(task):
	if _parent_node.is_stopped == true:
		task.failed()
		return
	_parent_node.acceleration = _seek(get_global_mouse_position())
	task.succeed()
	return


#######
# split
#######
export var split_count: int = 2
export var split_delay: float = 0.5
var _is_split: bool = false


func task_split(task):
	if _parent_node.is_stopped == true || split_count == 0:
		task.failed()
		return
	if _is_split == false:
		$SplitTimer.wait_time = split_delay
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
		_level_node.spawn_projectile(_clone_proj(_parent_node), _parent_node.global_position, 
			_parent_node.global_rotation + deg2rad(spread))
	_parent_node.queue_free()


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
export var steer_curve_randomize_dir: bool = false
onready var _random_dir = rand_range(0, 1.0)
var _old_v = null


func task_curve_steer(task):
	# for compatibility with homing, this behavior will stop if homing target is detected
	if is_instance_valid(_target_bot) == true || _parent_node.is_stopped == true:
		task.failed()
		return
	if _old_v == null:
		_old_v = _parent_node.velocity
	var r_timer = _parent_node.get_node("RangeTimer")
	var x_val = (r_timer.wait_time - r_timer.time_left) / r_timer.wait_time
	var y_val = steer_curve.interpolate(x_val)
	if steer_curve_randomize_dir == true && _random_dir <= 0.5:
		y_val *= -1
	_parent_node.velocity = _old_v.rotated(deg2rad(90*y_val))
	task.succeed()
	return


#########
# reflect
#########
export var reflect_count: int = 3


func task_reflect(task):
	if _parent_node.is_stopped == true || reflect_count == 0:
		task.failed()
		return
	if is_instance_valid($ReflectRay.get_collider()) == true:
		_level_node.spawn_projectile(_clone_proj(_parent_node),
			_parent_node.global_position, _rotate_by_reflection())
		_parent_node.queue_free()
	task.succeed()
	return


func _rotate_by_reflection() -> float:
	return (Vector2(1,0).rotated($ReflectRay.global_rotation).reflect(
			$ReflectRay.get_collision_normal()).angle() - deg2rad(180))


########
# modify
########
func _clone_proj(proj) -> Node:
	var proj_inst = load(proj.filename).instance()
	var proj_behavior = proj_inst.get_node("ProjBehavior")
	match self.get_script():
		Global.PROJ_BHVR_SPLIT:
			proj_behavior.split_count = split_count - 1
		Global.PROJ_BHVR_REFLECT:
			proj_behavior.reflect_count = reflect_count - 1
	proj_inst.set_level(_level_node)
	proj_inst.set_shooter(_parent_node.shooter(), _parent_node.shooter_faction())
	return proj_inst
