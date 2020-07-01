extends Node2D


var _enemies: Array = []
var _enemy: Global.CLASS_BOT = null
var _master: Global.CLASS_BOT = null
var _path_points: Array = []
var _next_path_point
var _velocity: Vector2
var _flee_routes: Dictionary = {}
var _parent_node: Global.CLASS_BOT
var _level_node: Node = null


func _ready() -> void:
	var ray_len: = 180
	for i in range(8):
		var ray = $FleeRays.get_node("R" + i as String)
		ray.cast_to = Vector2(ray_len, 0).rotated(deg2rad(i * 45))
		ray.get_node("Pos").position = ray.cast_to


func set_parent(new_parent: Global.CLASS_BOT):
	_parent_node = new_parent


func set_master(bot: Global.CLASS_BOT) -> void:
	if _check_if_valid_bot(bot) == false:
		return
	_master = bot


func set_level(level: Node) -> void:
	_level_node = level


func clear_enemies() -> void:
	_enemies = []


func _process(delta: float) -> void:
	$FleeRays.global_rotation = 0
	$Rays.global_rotation = 0


func _check_if_valid_bot(bot: Node) -> bool:
	return is_instance_valid(bot) == true && bot.state != Global.CLASS_BOT.State.DEAD


func _get_path_points(start: Vector2, end: Vector2) -> void:
	_path_points = []
	_next_path_point = null
	_path_points = _level_node.get_points(start, end)
	_next_path_point = _path_points.pop_front()


func _get_distance(start: Vector2, end: Vector2) -> int:
	var arr: Array = _level_node.get_points(start, end)
	var arr_size: = arr.size()
	if arr_size == 2:
		return arr[0].distance_to(arr[1])
	var distance: int = arr.pop_front().distance_to(arr.front())
	for i in range(arr_size-2):
		distance += arr.pop_front().distance_to(arr.front())
	return distance


func _physics_process(delta: float) -> void:
	if _parent_node.state == Global.CLASS_BOT.State.ROLL:
		_parent_node.velocity = _velocity
	if _check_if_valid_bot(_enemy) == true && _parent_node.state != Global.CLASS_BOT.State.WEAP_COMMIT:
		$Rays/Target.look_at(_enemy.global_position)


func _get_new_target_enemy(bot) -> void:
	if _check_if_valid_bot(bot) == false:
		_enemies.erase(bot)
		return
	$Rays/LookAt.look_at(bot.global_position)
	var potential_enemy = $Rays/LookAt.get_collider()
	#if target bot is within line of sight
	if potential_enemy == bot:
		_enemy = bot
		if $FoundTarget.is_playing() == false:
			$FoundTarget.play()
		return
	#if target bot is blocked by another enemy bot,
	#engage the blocking bot instead
	if (potential_enemy is Global.CLASS_BOT &&
		potential_enemy.current_faction != _parent_node.current_faction):
		_enemies.erase(potential_enemy)
		_enemy = potential_enemy
		if $FoundTarget.is_playing() == false:
			$FoundTarget.play()
	_enemies.append(bot)


func engage_attacker(bot) -> void:
	#if attacker is dead or the same target, continue engaging current enemy
	if _check_if_valid_bot(bot) == false || _enemy == bot:
		return
	#if attacker's distance is more than the current enemy distance, return
	if (_enemy != null &&
		_get_distance(bot.global_position, global_position) >
		_get_distance(_enemy.global_position, global_position)):
		return
	if _check_if_valid_bot(_enemy) == true:
		_enemies.append(_enemy)
	if _enemies.has(bot) == true:
		_enemies.erase(bot)
	_enemy = bot
	if $FoundTarget.is_playing() == false:
		$FoundTarget.play()


func _on_DetectionRange_body_entered(body: Node) -> void:
	if (body.has_node("AI") == true &&
		body.current_faction != _parent_node.current_faction):
		_enemies.append(body)
	elif (body is Global.CLASS_PLAYER &&
		body.current_faction != _parent_node.current_faction):
		_enemies.append(body)


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body != _enemy && _enemies.has(body) == true:
		_enemies.erase(body)


func _seek(target: Global.CLASS_BOT) -> void:
	if _check_if_valid_bot(target) == false:
		return
	if _path_points.size() == 0 || target.global_position.distance_to(_path_points.back()) <= 250:
		_get_path_points(global_position, target.global_position)
	if _next_path_point == null || (_path_points.size() != 0 &&
		global_position.distance_to(_next_path_point) <= 100):
		_next_path_point = _path_points.pop_front()
	$Rays/Velocity.look_at(_next_path_point)
	_velocity = Vector2(1,0).rotated($Rays/Velocity.global_rotation)
	_next_path_point = null


func _flee() -> void:
	if _check_if_valid_bot(_enemy) == false:
		return
	if _next_path_point != null && _get_distance(global_position, _next_path_point) <= 100:
		_next_path_point = null
	if _next_path_point == null:
		_flee_routes = {}
		for ray in $FleeRays.get_children():
			var pos
			if ray.is_colliding() == true && ray.get_collider() is Global.CLASS_LEVEL_OBJECT:
				continue
			else:
				pos = ray.get_node("Pos").global_position
			_flee_routes[_get_distance(pos, _enemy.global_position)] = pos
		if _flee_routes.size() != 0:
			_next_path_point = _flee_routes[_flee_routes.keys().max()]
			$Rays/Velocity.look_at(_next_path_point)
		else:
			$Rays/Velocity.global_rotation = $Rays/Target.global_rotation - deg2rad(180)
	_velocity = Vector2(1,0).rotated($Rays/Velocity.global_rotation)
	_next_path_point = null


#coroutine signal
signal resume


func _on_ResumeTimer_timeout() -> void:
	emit_signal("resume")


#############
# btree tasks
#############


#############
# enemy found
#############
func task_get_enemy(task):
	if _enemies.size() != 0:
		_get_new_target_enemy(_enemies.pop_front())
	task.succeed()
	return


func task_is_enemy_instance_valid(task):
	if _check_if_valid_bot(_enemy) == false:
		_enemies.erase(_enemy)
		_enemy = null
		_velocity = Vector2(0,0)
		task.failed()
		return
	else:
		task.succeed()
		return


func task_seek_enemy(task):
	if _check_if_valid_bot(_enemy) == false:
		task.failed()
		return
	_seek(_enemy)
	task.succeed()
	return


func task_is_enemy_close(task):
	if _check_if_valid_bot(_enemy) == false:
		task.failed()
		return
	if _get_distance(global_position, _enemy.global_position) <= task.get_param(0):
		task.succeed()
		return
	else:
		task.failed()
		return


#time based wait task using coroutine
func task_timed_idle(task):
	$ResumeTimer.wait_time = task.get_param(0)
	if $ResumeTimer.is_stopped() == true:
		$ResumeTimer.start()
	yield(self, "resume")
	task.succeed()
	return


###########
# transform
###########
func task_to_roll(task):
	if _parent_node.state == Global.CLASS_BOT.State.ROLL:
		task.succeed()
		return
	if _parent_node.state == Global.CLASS_BOT.State.TURRET:
		_parent_node.switch_mode()


func task_to_turret(task):
	if _parent_node.state == Global.CLASS_BOT.State.TURRET:
		task.succeed()
		return
	if _parent_node.state == Global.CLASS_BOT.State.ROLL:
		_parent_node.switch_mode()
		_parent_node.current_weapon.global_rotation = $Rays/Target.global_rotation


#############
# charge roll
#############
func task_charge_roll(task):
	if _check_if_valid_bot(_enemy) == false:
		task.failed()
		return
	match task.get_param(0):
		"target":
			if $Rays/Target.get_collider() == _enemy:
				_parent_node.charge_roll($Rays/Target.global_rotation)
		"velocity":
			_parent_node.charge_roll($Rays/Velocity.global_rotation)
	task.succeed()
	return


func task_is_charge_ready(task):
	if _parent_node.is_charge_roll_ready() == true:
		task.succeed()
		return
	else:
		task.failed()
		return


##############
# flee
# needs refinement
##############
func task_flee(task):
	if _check_if_valid_bot(_enemy) == false:
		task.failed()
		return
	if $FleeRays/R0.enabled == false:
		for ray in $FleeRays.get_children():
			ray.enabled = true
	_flee()
	task.succeed()
	return


##############
# shoot weapon
##############
func task_is_weapon_overheating(task):
	if _parent_node.current_weapon.is_overheating() == true:
		task.succeed()
		return
	else:
		task.failed()
		return


func task_shoot_enemy(task):
	if _check_if_valid_bot(_enemy) == false:
		task.failed()
		return
	_parent_node.current_weapon.global_rotation = $Rays/Target.global_rotation
	if $Rays/Target.get_collider() is Global.CLASS_LEVEL_OBJECT == false:
		_parent_node.shoot_weapon()
	task.succeed()
	return


####################
# ally/master follow
####################
func task_is_master_instance_valid(task):
	if _check_if_valid_bot(_master) == false:
		_master = null
		_velocity = Vector2(0,0)
		task.failed()
		return
	else:
		task.succeed()
		return


func task_is_master_close(task):
	if _check_if_valid_bot(_master) == false:
		task.failed()
		return
	if _get_distance(global_position, _master.global_position) <= task.get_param(0):
		task.succeed()
		return
	else:
		task.failed()
		return


func task_seek_master(task):
	if _check_if_valid_bot(_master) == false:
		task.failed()
		return
	_seek(_master)
	task.succeed()
	return


###############
# special tasks
###############
func task_special(task):
	_special()
	task.succeed()
	return


#virtual func for bots with special tasks
func _special() -> void:
	pass
