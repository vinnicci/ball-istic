extends Node2D


export (int) var detection_range: int = 1000
export (int) var master_seek_dist: int = 300
export (int) var enemy_seek_dist: int = 300
export (float) var charge_break: float = 0.5
export (float) var weap_heat_cooldown: float = 0

var _params_dict: Dictionary
var _enemies: Array
var _enemy: Global.CLASS_BOT = null setget , get_enemy
var _master: Global.CLASS_BOT = null
var _path_points: Array
var _next_path_point
var _flee_routes: Dictionary
#enum actions that uses the physics process loop
var _current_act = Action.NONE
enum Action {
	NONE,
	IDLE,
	SEEK_ENEMY,
	SEEK_MASTER,
	FLEE
}
var _parent_node: Global.CLASS_BOT
var _level_node: Node


func get_enemy():
	return _enemy


func _ready() -> void:
	if has_node("BTREE") == false:
		push_error(_parent_node.name + " AI has no BTREE node. Please attach one.")
	$DetectionRange/CollisionShape2D.shape = CircleShape2D.new()
	$DetectionRange/CollisionShape2D.shape.radius = detection_range
	$Rays/Target.cast_to = Vector2(detection_range, 0)
	$Rays/LookAt.cast_to = Vector2(detection_range, 0)
	var ray_len: = 175
	for i in range(8):
		var ray = $FleeRays.get_node("R" + i as String)
		ray.cast_to = Vector2(ray_len, 0)
		ray.get_node("Pos").position = ray.cast_to
		ray.global_rotation = deg2rad(i * 45)
	$Rays/Velocity.cast_to = Vector2(ray_len, 0)
	#export vars in dictionary
	_params_dict["master_seek"] = master_seek_dist
	_params_dict["enemy_seek"] = enemy_seek_dist
	_params_dict["charge_break"] = charge_break


func set_parent(new_parent: Global.CLASS_BOT):
	_parent_node = new_parent
	#ai has weapon heat dissipation advantage/cheat
	if weap_heat_cooldown != 0:
		for weap in _parent_node.get_node("Weapons").get_children():
			weap.current_heat_disspation = ((round(weap.get_heat_cap()) + 1)
				/ weap_heat_cooldown)
	_parent_node.connect("dead", self, "_on_parent_dead")


func set_master(bot: Global.CLASS_BOT) -> void:
	_master = bot


func set_level(level: Node) -> void:
	_level_node = level


func _physics_process(_delta: float) -> void:
	if _check_if_valid_bot(_enemy) == false:
		_get_new_target_enemy()
	if (_check_if_valid_bot(_enemy) == true &&
		_parent_node.state != Global.CLASS_BOT.State.WEAP_COMMIT):
		$Rays/Target.look_at(_enemy.global_position)
	match _current_act:
		Action.NONE:
			return
		Action.IDLE:
			_parent_node.velocity = Vector2(0,0)
		Action.SEEK_ENEMY:
			_seek(_enemy)
		Action.SEEK_MASTER:
			_seek(_master)
		Action.FLEE:
			_flee()


func _process(_delta: float) -> void:
	$FleeRays.global_rotation = 0
	$Rays.global_rotation = 0


func _on_parent_dead() -> void:
	clear_enemies()


func clear_enemies() -> void:
	_enemies = []
	_enemy = null


func _check_if_valid_bot(bot: Node) -> bool:
	return (_level_node.get_node("Bots").get_children().has(bot) &&
		bot.state != Global.CLASS_BOT.State.DEAD)


func _clear_path_points() -> void:
	_path_points = []
	_next_path_point = null
	_flee_routes = {}


func _get_path_points(start: Vector2, end: Vector2) -> void:
	_clear_path_points()
	_path_points = _level_node.get_points(start, end)
	_next_path_point = _path_points.pop_front()


func _get_distance(start_node: Node, target_node: Node) -> int:
	if _check_if_valid_bot(target_node) == false:
		return 0
	var start: Vector2 = start_node.global_position
	var end: Vector2 = target_node.global_position
	var arr: Array = _level_node.get_points(start, end)
	if arr.size() <= 1:
		return 0
	var dist: int = arr.pop_front().distance_to(arr.front())
	while arr.size() != 1:
		dist += arr.pop_front().distance_to(arr.front())
	return dist


func _get_new_target_enemy() -> void:
	if _enemies.size() == 0:
		return
	var bot = _enemies.front()
	if _check_if_valid_bot(bot) == false:
		return
	$Rays/LookAt.look_at(bot.global_position)
	var potential_enemy = $Rays/LookAt.get_collider()
	#if target bot is in line of sight
	if (potential_enemy is Global.CLASS_LEVEL_WALL ||
		potential_enemy is Global.CLASS_LEVEL_RIGID ||
		potential_enemy == null):
		_enemies.erase(bot)
		_enemies.append(bot)
		return
	if potential_enemy == bot:
		engage(potential_enemy)
	#if target bot is blocked by another enemy bot,
	#engage the blocking bot instead
	elif (potential_enemy is Global.CLASS_BOT &&
		potential_enemy.current_faction != _parent_node.current_faction):
		if (potential_enemy is Global.CLASS_PLAYER ||
			potential_enemy.has_node("AI") == true):
			engage(potential_enemy)


func engage(bot) -> void:
	#if attacker's distance is less than the current enemy distance,
	#engage attacker
	if _check_if_valid_bot(_enemy) != false:
		if _get_distance(bot, self) > _get_distance(_enemy, self):
			return
	_set_enemy(bot)


signal engaged


func _set_enemy(bot) -> void:
	if _parent_node.state == Global.CLASS_BOT.State.DEAD || _enemy == bot:
		return
	_enemy = bot
	emit_signal("engaged")
	if $FoundTarget.is_playing() == false:
		$FoundTarget.play()


func _seek(target: Global.CLASS_BOT) -> void:
	if _check_if_valid_bot(target) == false:
		return
	if (_path_points.size() == 0 ||
		target.global_position.distance_to(_path_points.back()) > 250):
		_get_path_points(global_position, target.global_position)
	var seek_dist_min: int = 150
	if global_position.distance_to(_next_path_point) > seek_dist_min:
		$Rays/Velocity.look_at(_next_path_point)
		_parent_node.velocity = Vector2(1,0).rotated($Rays/Velocity.global_rotation)
		return
	_next_path_point = _path_points.pop_front()
	$Rays/Velocity.look_at(_next_path_point)
	_parent_node.velocity = Vector2(1,0).rotated($Rays/Velocity.global_rotation)


func _flee() -> void:
	if _check_if_valid_bot(_enemy) == false:
		return
	_parent_node.velocity = Vector2(1,0).rotated($Rays/Velocity.global_rotation)


func _on_FleeEvaluate_timeout() -> void:
	if _check_if_valid_bot(_enemy) == false:
		return
	_flee_routes = {}
	for ray in $FleeRays.get_children():
		#skip ray that is colliding with walls or a physics object
		if ray.get_collider() != null:
			continue
		var flee_points: int = _enemy.global_position.distance_to(ray.get_node("Pos").global_position)
		_flee_routes[flee_points] = ray
	if _flee_routes.keys().size() != 0:
		$Rays/Velocity.global_rotation = _flee_routes[_flee_routes.keys().max()].global_rotation
	else:
		$Rays/Velocity.global_rotation = $Rays/Target.global_rotation - deg2rad(180)


func _on_DetectionRange_body_entered(body: Node) -> void:
	if _parent_node.state == Global.CLASS_BOT.State.DEAD:
		return
	if body.current_faction != _parent_node.current_faction:
		if (_enemies.has(body) == false &&
			(body.has_node("AI") == true || body is Global.CLASS_PLAYER)):
			_enemies.append(body)
			if body.is_connected("dead", self, "_erase_enemy") == false:
				body.connect("dead", self, "_erase_enemy", [body])


func _on_DetectionRange_body_exited(body: Node) -> void:
	if _parent_node.state == Global.CLASS_BOT.State.DEAD:
		return
	if _enemies.has(body) == true && body != _enemy:
		_erase_enemy(body)


func _erase_enemy(bot: Node) -> void:
	if _enemies.has(bot) == true:
		_enemies.erase(bot)


#############
# btree tasks
#############


#############
# enemy found
#############
func task_cond_is_enemy_instance_valid(task):
	if _check_if_valid_bot(_enemy) == false:
		task.failed()
	else:
		task.succeed()
	return


func task_act_seek_enemy(task):
	if _current_act != Action.SEEK_ENEMY:
		_current_act = Action.SEEK_ENEMY
	task.succeed()
	return


func task_cond_is_enemy_close(task):
	if _get_distance(self, _enemy) <= _params_dict[task.get_param(0)]:
		task.succeed()
	else:
		task.failed()
	return


func task_cond_get_enemy_state(task):
	if _check_if_valid_bot(_enemy) == false:
		task.failed()
		return
	if _convert_enum(task.get_param(0)) == _enemy.state:
		task.succeed()
	else:
		task.failed()
	return


func _convert_enum(state: String) -> int:
	var output: int
	match state:
		"TURRET": output = Global.CLASS_BOT.State.TURRET
		"TO_TURRET": output = Global.CLASS_BOT.State.TO_TURRET
		"ROLL": output = Global.CLASS_BOT.State.ROLL
		"TO_ROLL": output = Global.CLASS_BOT.State.TO_ROLL
		"CHARGE_ROLL": output = Global.CLASS_BOT.State.CHARGE_ROLL
		"WEAP_COMMIT": output = Global.CLASS_BOT.State.WEAP_COMMIT
		"STUN": output = Global.CLASS_BOT.State.STUN
		"DEAD": output = Global.CLASS_BOT.State.DEAD
	return output


######
# idle
######
var _paused: bool = false
signal resume


#time based wait task using coroutine
func task_act_timed_idle(task):
	if _paused == true:
		task.reset()
		return
	if _paused == false && $Resume.is_stopped() == true:
		_paused = true
		$Resume.start(_params_dict[task.get_param(0)])
	yield(self, "resume")
	task.succeed()
	return


func _on_Resume_timeout() -> void:
	_paused = false
	emit_signal("resume")


func task_act_idle(task):
	if _current_act != Action.IDLE:
		_current_act = Action.IDLE
	task.succeed()
	return


func task_act_none(task):
	if _current_act != Action.NONE:
		_current_act = Action.NONE
	task.succeed()
	return


###########
# transform
###########
func task_act_to_roll(task):
	if _parent_node.state == Global.CLASS_BOT.State.ROLL:
		task.succeed()
		return
	if _parent_node.state == Global.CLASS_BOT.State.TURRET:
		_parent_node.switch_mode()


func task_act_to_turret(task):
	if _parent_node.state == Global.CLASS_BOT.State.TURRET:
		task.succeed()
		return
	if _parent_node.state == Global.CLASS_BOT.State.ROLL:
		_parent_node.switch_mode()
		_parent_node.current_weapon.global_rotation = $Rays/Target.global_rotation


#############
# charge roll
#############
func task_act_charge_roll(task):
	match task.get_param(0):
		"target":
			if $Rays/Target.get_collider() == _enemy:
				_parent_node.charge_roll($Rays/Target.global_rotation)
		"velocity":
			_parent_node.charge_roll($Rays/Velocity.global_rotation)
	task.succeed()
	return


func task_cond_is_charge_ready(task):
	if _parent_node.is_charge_roll_ready() == true:
		task.succeed()
	else:
		task.failed()
	return


#######
# flee
#######
func task_act_flee(task):
	if _check_if_valid_bot(_enemy) == false:
		$FleeEvaluate.stop()
		task.failed()
		return
	if $FleeEvaluate.is_stopped() == true:
		_on_FleeEvaluate_timeout()
		$FleeEvaluate.start()
	_current_act = Action.FLEE
	task.succeed()
	return


###############
# switch weapon
###############
func task_act_switch_weapon(task):
	if _parent_node.change_weapon(task.get_param(0)) == true:
		task.succeed()
		return


#################
# discharge parry
#################
func task_act_discharge_parry(task):
	_parent_node.discharge_parry()
	task.succeed()
	return


##############
# shoot weapon
##############
func task_cond_is_weapon_overheating(task):
	if _parent_node.current_weapon.is_overheating() == true:
		task.succeed()
	else:
		task.failed()
	return


func task_act_shoot_enemy(task):
	if _check_if_valid_bot(_enemy) == false:
		task.failed()
		return
	var ray_collider = $Rays/Target.get_collider()
	if _valid_shooting_target(ray_collider) == true:
		$Rays/Target.look_at(_enemy.global_position)
		_parent_node.current_weapon.global_rotation = $Rays/Target.global_rotation
		_parent_node.shoot_weapon()
	task.succeed()
	return


func _valid_shooting_target(ray_collider) -> bool:
	#ai can only shoot when
	#not stunned & aiming at the enemy
	return (_parent_node.state != Global.CLASS_BOT.State.STUN &&
		(ray_collider != null &&
		((ray_collider is Global.CLASS_LEVEL_WALL ||
		ray_collider is Global.CLASS_LEVEL_RIGID) == false) &&
		(ray_collider is Global.CLASS_BOT &&
		ray_collider.current_faction != _parent_node.current_faction)))


####################
# ally/master follow
####################
func task_cond_is_master_instance_valid(task):
	if _check_if_valid_bot(_master) == false:
		task.failed()
	else:
		task.succeed()
	return


func task_cond_is_master_close(task):
	if _get_distance(self, _master) <= _params_dict[task.get_param(0)]:
		task.succeed()
	else:
		task.failed()
	return


func task_act_seek_master(task):
	if _current_act != Action.SEEK_MASTER:
		_current_act = Action.SEEK_MASTER
	task.succeed()
	return


###############
# special tasks
###############
func task_act_special(task):
	_special()
	task.succeed()
	return


#virtual func for bots with special tasks(self destruct and such)
func _special() -> void:
	pass
