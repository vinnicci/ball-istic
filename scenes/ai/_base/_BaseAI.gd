extends Node2D


var _enemies: Array = []
var _allies: Array = []
var _enemy: Global.CLASS_BOT = null
var _ally: Global.CLASS_BOT = null
var _path_points: Array = []
var _next_path_point: Vector2
var _velocity: Vector2

onready var _parent_node: = get_parent()
onready var _level_node: = _parent_node.get_parent().get_parent()


func _ready() -> void:
	for object in _level_node.get_node("Nav").get_children():
		$Rays/LookAt.add_exception(object)


func _process(delta: float) -> void:
	$Rays.global_rotation = 0


func get_path_points(start, end) -> void:
	_path_points = []
	_path_points = _level_node.get_points(start, end)
	_next_path_point = _path_points.pop_front()


func control_ai(delta):
	if _parent_node.is_in_control() == true:
		_parent_node.velocity = _velocity
	if is_instance_valid(_enemy) == true:
		$Rays/Target.look_at(_enemy.global_position)


#func _process(delta: float) -> void:
#	if _parent_node.name == "Fighter":
#		print("transforming: " + _parent_node.is_transforming() as String + "\nswitched: " + _switched as String)


func _get_new_target_enemy() -> void:
	if _enemies.size() != 0 && _enemy == null:
		if is_instance_valid(_enemies.front()) == false:
			_enemies.pop_front()
			return
		$Rays/LookAt.look_at(_enemies.front().global_position)
		if $Rays/LookAt.get_collider() == _enemies.front():
			_enemy = _enemies.pop_front()
			$FoundTarget.play()


func _on_DetectionRange_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT && body.is_hostile() != _parent_node.is_hostile():
		_enemies.append(body)


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body is Global.CLASS_BOT && body.is_hostile() != _parent_node.is_hostile():
		if _enemies.has(body) == true:
			_enemies.erase(body)


func _seek(target) -> void:
	if is_instance_valid(target) == false:
		return
	if _path_points.size() == 0 || target.global_position.distance_to(_path_points.back()) < 300:
		get_path_points(global_position, target.global_position)
	if global_position.distance_to(_next_path_point) < 200:
		_next_path_point = _path_points.pop_front()
	$Rays/Velocity.look_at(_next_path_point)
	_velocity = Vector2(1,0).rotated($Rays/Velocity.global_rotation)


#############
# btree tasks
#############


#############
# enemy found
#############
func task_idle(task):
	_velocity = Vector2(0,0)
	task.succeed()
	return


func task_get_enemy(task):
	_get_new_target_enemy()
	task.succeed()
	return


func task_is_enemy_instance_valid(task):
	if is_instance_valid(_enemy) == false || _enemy.is_alive() == false:
		_enemy = null
		task.failed()
		return
	else:
		task.succeed()
		return


func task_seek_enemy(task):
	if is_instance_valid(_enemy) == false || _enemy.is_alive() == false:
		task.failed()
		return
	if global_position.distance_to(_enemy.global_position) < task.get_param(0):
		task.succeed()
		return
	else:
		_seek(_enemy)


###########
# transform
###########
var _switched: bool = false


func task_transformed(task):
	if _parent_node.is_transforming() == false && _switched == true:
		_switched = false
		task.succeed()
		return


func task_roll_mode(task):
	if _switched == false:
		if _parent_node.is_rolling() == true:
			_switched = true
		if _parent_node.is_rolling() == false:
			_switched = true
			_parent_node.switch_mode()
		task.succeed()
		return


func task_turret_mode(task):
	if _switched == false:
		if _parent_node.is_rolling() == false:
			_switched = true
		if _parent_node.is_rolling() == true:
			_switched = true
			_parent_node.current_weapon.global_rotation = $Rays/Target.global_rotation
			_parent_node.switch_mode()
		task.succeed()
		return


#############
# charge roll
#############
func task_charge_attack(task):
	if is_instance_valid(_enemy) == false || _enemy.is_alive() == false:
		task.failed()
		return
	if $Rays/Target.get_collider() == _enemy && _parent_node.is_charge_roll_ready() == true:
		_parent_node.charge_roll($Rays/Target.global_rotation)
		task.succeed()
		return
	else:
		task.failed()
		return


func task_back_off(task):
	if is_instance_valid(_enemy) == false || _enemy.is_alive() == false:
		task.failed()
		return
	if _parent_node.is_charge_roll_ready() == false:
		if global_position.distance_to(_enemy.global_position) < task.get_param(0):
			$Rays/Velocity.global_rotation = $Rays/Target.global_rotation - deg2rad(180)
		elif global_position.distance_to(_enemy.global_position) > task.get_param(0):
			$Rays/Velocity.global_rotation = $Rays/Target.global_rotation
		if $Rays/Velocity.is_colliding() == true:
			_velocity = Vector2(1,0).rotated($Rays/Velocity.global_rotation) + Vector2(1,0).rotated($Rays/Velocity.get_collision_normal().angle())
		else:
			_velocity = Vector2(1,0).rotated($Rays/Velocity.global_rotation)
		task.reset()
		return
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
		$Rays/Velocity.global_rotation = $Rays/Target.global_rotation - deg2rad(180)
		task.failed()
		return


func task_look_dir(task):
	var vector: Vector2
	if $Rays/Velocity.is_colliding() == true:
		vector = Vector2(1,0).rotated($Rays/Velocity.global_rotation) + Vector2(1,0).rotated($Rays/Velocity.get_collision_normal().angle())
		$Rays/Velocity.global_rotation = vector.angle()
		task.reset()
		return
	task.succeed()
	return


func task_move(task):
	if is_instance_valid(_enemy) == false || _enemy.is_alive() == false:
		task.failed()
		return
	_velocity = Vector2(1,0).rotated($Rays/Velocity.global_rotation)
	if global_position.distance_to(_enemy.global_position) < 150:
		$Rays/Velocity.global_rotation = $Rays/Target.global_rotation - deg2rad(180)
	task.succeed()
	return


##############
# shoot weapon
##############
func task_shoot_enemy(task):
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
	if _parent_node.current_weapon.is_overheating() == false && _level_node.get_node("Nav").get_children().has($Rays/Target.get_collider()) == false:
		_parent_node.shoot_weapon()


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
