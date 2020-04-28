extends Node2D


var enemies: Array = []
var allies: Array = []
var enemy: Node = null
var ally: Node = null
var path_points: Array = []
var next_path_point: Vector2


onready var parent_node: = get_parent()
onready var level_node: = parent_node.get_parent().get_parent()


func get_path_points(start, end) -> void:
	path_points = []
	path_points = level_node.get_points(start, end)
	next_path_point = path_points.pop_front()


func _physics_process(delta: float) -> void:
	$Rays.global_rotation = 0


func _control(delta):
	get_new_target_enemy()
	if parent_node.is_in_control == false || is_instance_valid(enemy) == false:
		return
	$Rays/TargetRay.look_at(enemy.global_position)


func get_new_target_enemy() -> void:
	if enemies.size() != 0 && enemy == null:
		for enemy_k in enemies:
			if is_instance_valid(enemy_k) == false:
				enemies.erase(enemy_k)
				continue
			$Rays/LookAtRay.look_at(enemy_k.global_position)
			if $Rays/LookAtRay.get_collider() == enemy_k:
				$FoundTarget.play()
				enemy = enemy_k
				enemies.erase(enemy)
				return


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body.get_parent().name == "Bots" && body.is_hostile != parent_node.is_hostile:
		enemies.append(body)


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body.get_parent().name == "Bots" && body.is_hostile != parent_node.is_hostile:
		if enemies.has(body) == true:
			enemies.erase(body)


func seek(target) -> void:
	if parent_node.is_in_control == false || is_instance_valid(target) == false:
		return
	if parent_node.roll_mode == false:
		parent_node.switch_mode()
	if path_points.size() == 0 || target.global_position.distance_to(path_points.back()) < 800:
		get_path_points(parent_node.global_position, target.global_position)
	if global_position.distance_to(next_path_point) < 100:
		next_path_point = path_points.pop_front()
		$Rays/VelocityRay.look_at(next_path_point)
	parent_node.velocity = Vector2(1,0).rotated($Rays/VelocityRay.global_rotation)


#############
# btree tasks
#############


func task_idle(task):
	parent_node.velocity = Vector2(0,0)
	task.succeed()


func task_seek_enemy(task):
	if is_instance_valid(enemy) == false:
		task.failed()
		return
	if global_position.distance_to(enemy.global_position) < task.get_param(0):
		task.succeed()
	else:
		seek(enemy)
		task.reset()


func task_is_enemy_instance_valid(task):
	if is_instance_valid(enemy) == false:
		enemy = null
		task.failed()
	else:
		task.succeed()


func task_back_off(task):
	if is_instance_valid(enemy) == false:
		task.failed()
		return
	if parent_node.timer_charge_cooldown.is_stopped() == false:
		if global_position.distance_to(enemy.global_position) < 300:
			$Rays/VelocityRay.global_rotation = $Rays/TargetRay.global_rotation - deg2rad(180)
		elif global_position.distance_to(enemy.global_position) > 300:
			$Rays/VelocityRay.global_rotation = $Rays/TargetRay.global_rotation
		if $Rays/VelocityRay.is_colliding() == true:
			parent_node.velocity = Vector2(1,0).rotated($Rays/VelocityRay.global_rotation) + Vector2(1,0).rotated($Rays/VelocityRay.get_collision_normal().angle())
		else:
			parent_node.velocity = Vector2(1,0).rotated($Rays/VelocityRay.global_rotation)
		task.reset()
	else:
		task.succeed()


func task_charge_attack(task):
	if is_instance_valid(enemy) == false:
		task.failed()
		return
	if $Rays/TargetRay.get_collider() == enemy && parent_node.timer_charge_cooldown.is_stopped() == true:
		parent_node.charge_roll($Rays/TargetRay.global_rotation)
		task.succeed()
	else:
		task.failed()


#func task_get_nearest_ally(task):
#	if parent_node.get_parent().get_children().size() == 2:
#		task.failed()
#	if find_ally() == false:
#		task.failed()
#		return
#	task.succeed()
#
#
#func task_ally_within_range(task):
#	if ally_within_range == true:
#		task.succeed()
#	else:
#		task.failed()
#
#
#func task_seek_ally(task):
#	seek(ally)
#	task.succeed()
#
#
#func task_flee_blind(task):
#	return
#func flee_blind() -> void:
#	pass


#seek area with allies within and decent distance from enemy
#func find_ally() -> bool:
#	var dict_dist_ally = {}
#	var arr_dist = []
#	for bot in parent_node.get_parent().get_children():
#		if bot.is_hostile != parent_node.is_hostile && bot == self:
#			continue
#		var dist = get_dist(global_position, bot.global_position)
#		if dist < 500:
#			continue
#		dict_dist_ally[dist] = bot
#		arr_dist.append(dist)
#	if arr_dist.size() == 0:
#		return false
#	arr_dist.sort()
#	ally = dict_dist_ally[arr_dist.pop_front()]
#	return true
#
#
#func get_dist(from: Vector2, to: Vector2) -> float:
#	var points = level_node.get_points(from, to)
#	var total_dist: float
#	while(points.size() != 1):
#		total_dist += points.pop_front().distance_to(points.front())
#	return total_dist
