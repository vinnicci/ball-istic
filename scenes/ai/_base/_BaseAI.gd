extends Node2D


var _enemies: Array = []
var _allies: Array = []
var _enemy: CLASS_BOT = null
var _ally: Node = null
var _path_points: Array = []
var _next_path_point: Vector2
var _velocity: Vector2

const CLASS_BOT = preload("res://scenes/bots/_base/_BaseBot.gd")

onready var _parent_node: = get_parent()
onready var _level_node: = _parent_node.get_parent().get_parent()


func _ready() -> void:
	for object in _level_node.get_node("Nav").get_children():
		$LookRay.add_exception(object)


func get_path_points(start, end) -> void:
	_path_points = []
	_path_points = _level_node.get_points(start, end)
	_next_path_point = _path_points.pop_front()


func control_ai(delta):
	if _parent_node.is_in_control() == true:
		_parent_node.velocity = _velocity
	if is_instance_valid(_enemy) == true:
		$TargetRay.look_at(_enemy.global_position)


func _get_new_target_enemy() -> void:
	if _enemies.size() != 0 && _enemy == null:
		if is_instance_valid(_enemies[0]) == false:
			_enemies.remove(0)
			return
		$LookRay.look_at(_enemies[0].global_position)
		if $LookRay.get_collider() == _enemies[0]:
			_enemy = _enemies[0]
			$FoundTarget.play()


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body is CLASS_BOT && body.is_hostile() != _parent_node.is_hostile():
		_enemies.append(body)


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body is CLASS_BOT && body.is_hostile() != _parent_node.is_hostile():
		if _enemies.has(body) == true:
			_enemies.erase(body)


func _seek(target) -> void:
	if is_instance_valid(target) == false:
		return
	if _path_points.size() == 0 || target.global_position.distance_to(_path_points.back()) < 300:
		get_path_points(global_position, target.global_position)
	if global_position.distance_to(_next_path_point) < 150:
		_next_path_point = _path_points.pop_front()
	$VelocityRay.look_at(_next_path_point)
	_velocity = Vector2(1,0).rotated($VelocityRay.global_rotation)


#############
# btree tasks
#############


#############
# enemy found
#############
func task_idle(task):
	if _parent_node.name == "Fighter":
		print("idle")
	_velocity = Vector2(0,0)
	task.succeed()
	return


func task_is_enemy_instance_valid(task):
	if _parent_node.name == "Fighter":
		print("find")
	if is_instance_valid(_enemy) == false || _enemy.is_alive() == false:
		_enemy = null
		_get_new_target_enemy()
		if _enemy == null:
			task.failed()
			return
	task.succeed()
	return


func task_seek_enemy(task):
	if is_instance_valid(_enemy) == false || _enemy.is_alive() == false:
		task.failed()
		return
	if _parent_node.name == "Fighter":
		print("seeking from: " + global_position as String + " to: " + _enemy.global_position as String)
	if global_position.distance_to(_enemy.global_position) < task.get_param(0):
		task.succeed()
		return
	else:
		_seek(_enemy)
		task.reset()


###########
# transform
###########
var _switched: bool = false


func task_roll_mode(task):
	if _parent_node.name == "Fighter" && _parent_node.is_transforming():
		print("to roll, transform, " + _switched as String)
	if _parent_node.name == "Fighter":
		print("rolling, " + task.get_param(0))
	if _switched == false:
		if _parent_node.is_rolling() == true:
			task.succeed()
			return
		if _parent_node.is_rolling() == false:
			_parent_node.switch_mode()
			_switched = true
	if _parent_node.is_transforming() == false && _switched == true:
		_switched = false
		task.succeed()
		return
	task.reset()


func task_shoot_mode(task):
	if _parent_node.name == "Fighter":
		print("to shoot")
	if _switched == false:
		if _parent_node.is_rolling() == false:
			task.succeed()
			return
		if _parent_node.is_rolling() == true:
			_parent_node.switch_mode()
			_switched = true
	if _parent_node.is_transforming() == false && _switched == true:
		_switched = false
		task.succeed()
		return
	task.reset()


#############
# charge roll
#############
func task_charge_attack(task):
	if _parent_node.name == "Fighter":
		print("charging")
	if is_instance_valid(_enemy) == false || _enemy.is_alive() == false:
		task.failed()
		return
	if $TargetRay.get_collider() == _enemy && _parent_node.is_charge_roll_ready() == true:
		_parent_node.charge_roll($TargetRay.global_rotation)
		task.succeed()
		return
	else:
		task.failed()


func task_back_off(task):
	if _parent_node.name == "Fighter":
		print("backing off")
	if is_instance_valid(_enemy) == false || _enemy.is_alive() == false:
		task.failed()
		return
	if _parent_node.is_charge_roll_ready() == false:
		if global_position.distance_to(_enemy.global_position) < task.get_param(0):
			$VelocityRay.global_rotation = $TargetRay.global_rotation - deg2rad(180)
		elif global_position.distance_to(_enemy.global_position) > task.get_param(0):
			$VelocityRay.global_rotation = $TargetRay.global_rotation
		if $VelocityRay.is_colliding() == true:
			_velocity = Vector2(1,0).rotated($VelocityRay.global_rotation) + Vector2(1,0).rotated($VelocityRay.get_collision_normal().angle())
		else:
			_velocity = Vector2(1,0).rotated($VelocityRay.global_rotation)
		task.reset()
	else:
		task.succeed()
		return


######
# flee
######
func task_enemy_close(task):
	if is_instance_valid(_enemy) == false || _enemy.is_alive() == false:
		task.failed()
		return
	if global_position.distance_to(_enemy.global_position) <= task.get_param(0):
		task.succeed()
		return
	else:
		$VelocityRay.global_rotation = $TargetRay.global_rotation - deg2rad(180)
		task.failed()
		return


func task_look_dir(task):
	var vector: Vector2
	if $VelocityRay.is_colliding() == true:
		vector = Vector2(1,0).rotated($VelocityRay.global_rotation) + Vector2(1,0).rotated($VelocityRay.get_collision_normal().angle())
		$VelocityRay.global_rotation = vector.angle()
		task.reset()
	task.succeed()
	return


func task_move(task):
	if is_instance_valid(_enemy) == false || _enemy.is_alive() == false:
		task.failed()
		return
	_velocity = Vector2(1,0).rotated($VelocityRay.global_rotation)
	if global_position.distance_to(_enemy.global_position) < 150:
		$VelocityRay.global_rotation = $TargetRay.global_rotation - deg2rad(180)
	task.succeed()
	return


##############
# shoot weapon
##############
func task_shoot_enemy(task):
	if _parent_node.name == "Fighter":
		print("shooting")
	if is_instance_valid(_enemy) == false || _enemy.is_alive() == false:
		task.failed()
		return
	_parent_node.current_weapon.look_at(_enemy.global_position)
	if global_position.distance_to(_enemy.global_position) > task.get_param(0):
		task.failed()
		return
	if _parent_node.current_weapon.is_overheating() == true:
		task.succeed()
		return
	if _parent_node.current_weapon.is_overheating() == false:
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
