extends Node2D


var _enemies: Array = []
var _allies: Array = []
var _enemy: Node = null
var _ally: Node = null
var _path_points: Array = []
var _next_path_point: Vector2


onready var _parent_node: = get_parent()
onready var _level_node: = _parent_node.get_parent().get_parent()


func get_path_points(start, end) -> void:
	_path_points = []
	_path_points = _level_node.get_points(start, end)
	_next_path_point = _path_points.pop_front()


func _physics_process(delta: float) -> void:
	$Rays.global_rotation = 0


func update_control(delta):
	_get_new_target_enemy()
	if _parent_node.is_in_control() == false || is_instance_valid(_enemy) == false:
		return
	$Rays/TargetRay.look_at(_enemy.global_position)


func _get_new_target_enemy() -> void:
	if _enemies.size() != 0 && _enemy == null:
		for enemy_k in _enemies:
			if is_instance_valid(enemy_k) == false:
				_enemies.erase(enemy_k)
				continue
			$Rays/LookAtRay.look_at(enemy_k.global_position)
			if $Rays/LookAtRay.get_collider() == enemy_k:
				$FoundTarget.play()
				_enemy = enemy_k
				_enemies.erase(_enemy)
				return


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body.get_parent().name == "Bots" && body.is_hostile() != _parent_node.is_hostile():
		_enemies.append(body)


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body.get_parent().name == "Bots" && body.is_hostile() != _parent_node.is_hostile():
		if _enemies.has(body) == true:
			_enemies.erase(body)


func _seek(target) -> void:
	if _parent_node.is_in_control() == false || is_instance_valid(target) == false:
		return
	if _parent_node.is_rolling() == false:
		_parent_node.switch_mode()
	if _path_points.size() == 0 || target.global_position.distance_to(_path_points.back()) < 800:
		get_path_points(_parent_node.global_position, target.global_position)
	if global_position.distance_to(_next_path_point) < 100:
		_next_path_point = _path_points.pop_front()
		$Rays/VelocityRay.look_at(_next_path_point)
	_parent_node.velocity = Vector2(1,0).rotated($Rays/VelocityRay.global_rotation)


#############
# btree tasks
#############


#############
# enemy found
#############
func task_idle(task):
	_parent_node.velocity = Vector2(0,0)
	task.succeed()


func task_is_enemy_instance_valid(task):
	if is_instance_valid(_enemy) == false:
		_enemy = null
		task.failed()
		return
	else:
		task.succeed()


func task_seek_enemy(task):
	if is_instance_valid(_enemy) == false:
		task.failed()
		return
	if global_position.distance_to(_enemy.global_position) < task.get_param(0):
		task.succeed()
	else:
		_seek(_enemy)
		task.reset()


##########
# charger
##########
func task_charge_attack(task):
	if is_instance_valid(_enemy) == false:
		task.failed()
		return
	if $Rays/TargetRay.get_collider() == _enemy && _parent_node.is_charge_roll_ready() == true:
		_parent_node.charge_roll($Rays/TargetRay.global_rotation)
		task.succeed()
	else:
		task.failed()


func task_back_off(task):
	if is_instance_valid(_enemy) == false:
		task.failed()
		return
	if _parent_node.is_charge_roll_ready() == false:
		if global_position.distance_to(_enemy.global_position) < task.get_param(0):
			$Rays/VelocityRay.global_rotation = $Rays/TargetRay.global_rotation - deg2rad(180)
		elif global_position.distance_to(_enemy.global_position) > task.get_param(0):
			$Rays/VelocityRay.global_rotation = $Rays/TargetRay.global_rotation
		if $Rays/VelocityRay.is_colliding() == true:
			_parent_node.velocity = Vector2(1,0).rotated($Rays/VelocityRay.global_rotation) + Vector2(1,0).rotated($Rays/VelocityRay.get_collision_normal().angle())
		else:
			_parent_node.velocity = Vector2(1,0).rotated($Rays/VelocityRay.global_rotation)
		task.reset()
	else:
		task.succeed()


######
# flee
######
func task_enemy_close(task):
	if is_instance_valid(_enemy) == false:
		task.failed()
		return
	if global_position.distance_to(_enemy.global_position) <= task.get_param(0):
		task.succeed()
	else:
		$Rays/VelocityRay.global_rotation = $Rays/TargetRay.global_rotation - deg2rad(180)
		task.failed()


func task_look_dir(task):
	var vector: Vector2
	if $Rays/VelocityRay.is_colliding() == true:
		vector = Vector2(1,0).rotated($Rays/VelocityRay.global_rotation) + Vector2(1,0).rotated($Rays/VelocityRay.get_collision_normal().angle())
		$Rays/VelocityRay.global_rotation = vector.angle()
		task.reset()
	task.succeed()


func task_move(task):
	if is_instance_valid(_enemy) == false:
		task.failed()
		return
	_parent_node.velocity = Vector2(1,0).rotated($Rays/VelocityRay.global_rotation)
	if global_position.distance_to(_enemy.global_position) < 150:
		$Rays/VelocityRay.global_rotation = $Rays/TargetRay.global_rotation - deg2rad(180)
	task.succeed()


#############
# fire weapon
#############
func task_shoot_enemy(task):
	if is_instance_valid(_enemy) == false:
		task.failed()
		return
	_parent_node.current_weapon.look_at(_enemy.global_position)
	if global_position.distance_to(_enemy.global_position) > task.get_param(0) || _parent_node.current_weapon.is_overheating() == true:
		if _parent_node.is_rolling() == false:
			_parent_node.switch_mode()
		task.succeed()
	if _parent_node.current_weapon.is_overheating() == false && $Rays/TargetRay.get_collider() == _enemy:
		if _parent_node.is_rolling() == true:
			_parent_node.switch_mode()
		_parent_node.shoot_weapon()
		task.reset()


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
#		if bot.is_hostile() != parent_node.is_hostile() && bot == self:
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
