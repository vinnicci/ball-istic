extends Node2D


var enemies: Dictionary = {}
var allies: Dictionary = {}
var enemy: Node = null
var ally: Node = null
var path_points: Array = []
var next_path_point: Vector2

var enemy_in_range: bool = false
var enemy_in_sight: bool = false
var enemy_within_range: bool = false
var ally_within_range: bool = false

onready var parent_node: = get_parent()
onready var level_node: = parent_node.get_parent().get_parent()


func get_path_points(start, end) -> void:
	path_points = []
	path_points = level_node.get_points(start, end)
	next_path_point = path_points.pop_front()


func _control(delta):
	if parent_node.is_in_control == false || is_instance_valid(enemy) == false:
		return
	$TargetRay.look_at(enemy.global_position)
	if $TargetRay.get_collider() == enemy && enemy_in_sight == false:
		$FoundTarget.play()
		enemy_in_sight = true


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body.get_parent().name == "Bots" && body.is_hostile != parent_node.is_hostile:
		if enemy == null:
			enemy = body
		enemy_in_range = true
		$TargetRay.enabled = true


func _on_DetectionRange_body_exited(body: Node) -> void:
	pass


func _on_WithinRange_body_entered(body: Node) -> void:
	if enemy != null && body == enemy:
		enemy_within_range = true
	if ally != null && body == ally:
		ally_within_range = true


func _on_WithinRange_body_exited(body: Node) -> void:
	if enemy != null && body == enemy:
		enemy_within_range = false
	if ally != null && body == ally:
		ally_within_range = false


func flee_blind() -> void:
	pass


#seek area with allies within and decent distance from enemy
func find_ally() -> bool:
	var dict_dist_ally = {}
	var arr_dist = []
	for bot in parent_node.get_parent().get_children():
		if bot.is_hostile != parent_node.is_hostile && bot == self:
			continue
		var dist = get_dist(global_position, bot.global_position)
		if dist < 500:
			continue
		dict_dist_ally[dist] = bot
		arr_dist.append(dist)
	if arr_dist.size() == 0:
		return false
	arr_dist.sort()
	ally = dict_dist_ally[arr_dist.pop_front()]
	return true


func get_dist(from: Vector2, to: Vector2) -> float:
	var points = level_node.get_points(from, to)
	var total_dist: float
	while(points.size() != 1):
		total_dist += points.pop_front().distance_to(points.front())
	return total_dist


func seek(target) -> void:
	if parent_node.is_in_control == false || is_instance_valid(target) == false:
		return
	if parent_node.roll_mode == false:
		parent_node.switch_mode()
	if path_points.size() == 0 || target.global_position.distance_to(path_points.back()) < 800:
		get_path_points(parent_node.global_position, target.global_position)
	if global_position.distance_to(next_path_point) < 100:
		next_path_point = path_points.pop_front()
		$VelocityRay.look_at(next_path_point)
	parent_node.velocity = Vector2(1,0).rotated($VelocityRay.global_rotation)


#############
# btree tasks
#############


func task_enemy_found(task):
	if enemy_in_sight == true:
		task.succeed()
	else:
		task.failed()


func task_enemy_within_range(task):
	if (enemy_in_sight && enemy_within_range) == true:
		task.succeed()
	else:
		task.failed()


func task_idle(task):
	parent_node.velocity = Vector2(0,0)
	task.succeed()


func task_seek_enemy(task):
	seek(enemy)
	task.succeed()


func task_get_nearest_ally(task):
	if parent_node.get_parent().get_children().size() == 2:
		task.failed()
	if find_ally() == false:
		task.failed()
		return
	task.succeed()


func task_ally_within_range(task):
	if ally_within_range == true:
		task.succeed()
	else:
		task.failed()


func task_seek_ally(task):
	seek(ally)
	task.succeed()


func task_flee_blind(task):
	return
