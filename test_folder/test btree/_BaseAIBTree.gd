extends Node2D


onready var parent_node: = get_parent()
onready var level_node: = get_parent().get_parent().get_parent()
var enemy: WeakRef #something to attack
var ally: WeakRef #something to run to
var target_in_range: bool = false
var target_in_sight: bool = false
var path_points: Array = []
var next_path_point: Vector2
var pass_delta: float


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body.get_parent().name == "Bots" && body.is_hostile != parent_node.is_hostile:
		enemy = weakref(body)
		target_in_range = true
		$TargetRay.enabled = true


func _on_DetectionRange_body_exited(body: Node) -> void:
	pass # Replace with function body.


func get_path_points(start, end) -> void:
	path_points = []
	path_points = level_node.get_points(start, end)
	next_path_point = path_points.pop_front()


func _control(delta):
	pass_delta = delta
	if parent_node.is_in_control == false || enemy == null:
		return
	$TargetRay.look_at(enemy.get_ref().global_position)
	if $TargetRay.get_collider() == enemy.get_ref():
		target_in_sight = true
	else:
		target_in_sight = false


func task_idle(task):
	parent_node.velocity = Vector2(0,0)
	if enemy == null:
		return task.succeed()
	elif target_in_range == true && target_in_sight == true:
		return task.failed()


func task_enemy_is_far(task):
	if global_position.distance_to(enemy.get_ref().global_position) > 200:
		return task.succeed()
	else:
		return task.failed()


func task_enemy_detected(task):
	if (target_in_range && target_in_sight) == true:
		return task.succeed()


func task_seek_enemy(task):
	if parent_node.is_in_control == false:
		return
	if parent_node.roll_mode == false:
		parent_node.switch_mode()
	if path_points.size() == 0 || enemy.get_ref().global_position.distance_to(path_points.back()) < 800:
		get_path_points(parent_node.global_position, enemy.get_ref().global_position)
	if global_position.distance_to(next_path_point) < 100:
		next_path_point = path_points.pop_front()
		$VelocityRay.look_at(next_path_point)
#	parent_node.velocity = Vector2(0,0)
	parent_node.velocity = Vector2(1,0).rotated($VelocityRay.global_rotation) * pass_delta
