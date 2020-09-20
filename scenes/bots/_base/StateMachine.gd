extends Node


#states
var _st_roll = Global.CLASS_BOT.State.ROLL
var _st_to_turret = Global.CLASS_BOT.State.TO_TURRET
var _st_turret = Global.CLASS_BOT.State.TURRET
var _st_to_roll = Global.CLASS_BOT.State.TO_ROLL
var _st_weap_commit = Global.CLASS_BOT.State.WEAP_COMMIT
var _st_charge_roll = Global.CLASS_BOT.State.CHARGE_ROLL
var _st_stun = Global.CLASS_BOT.State.STUN
var _st_dead = Global.CLASS_BOT.State.DEAD


var _bot: Node
var before_stun
var switching: bool
var charge_roll = null


func set_bot(bot_node) -> void:
	_bot = bot_node


#state checker
func task_is_in_state(task):
	var get_state
	match task.get_param(0):
		"TURRET": get_state = _st_turret
		"ROLL": get_state = _st_roll
		"TO_TURRET": get_state = _st_to_turret
		"TO_ROLL": get_state = _st_to_roll
		"WEAP_COMMIT": get_state = _st_weap_commit
		"CHARGE_ROLL": get_state = _st_charge_roll
		"STUN": get_state = _st_stun
		"DEAD": get_state = _st_dead
	if _bot.state == get_state:
		task.succeed()
	else:
		task.failed()
	return


#states enter and process tasks
func task_turret_process(task):
	if _bot.current_health <= 0 || _bot.timer_stun.is_stopped() == false:
		before_stun = _bot.state
		_bot.state = _st_stun
		task.succeed()
		return
	if switching == true:
		_bot.state = _st_to_roll
		task.succeed()
		return
	if _bot.current_weapon.weap_commit == true:
		_bot.state = _st_weap_commit
		task.succeed()
		return


func task_roll_process(task):
	if _bot.current_health <= 0 || _bot.timer_stun.is_stopped() == false:
		before_stun = _bot.state
		_bot.state = _st_stun
		task.succeed()
		return
	if switching == true:
		_bot.state = _st_to_turret
		task.succeed()
		return
	if charge_roll != null:
		_bot.state = _st_charge_roll
		task.succeed()
		return


func task_to_turret_enter(task):
	_bot.switch_to_turret()
	task.succeed()
	return


func task_to_turret_process(task):
	if _bot.current_health <= 0 || _bot.timer_stun.is_stopped() == false:
		before_stun = _bot.state
		_bot.state = _st_stun
		task.succeed()
		return
	if switching == false:
		_bot.state = _st_turret
		task.succeed()
		return


func task_to_roll_enter(task):
	_bot.switch_to_roll()
	task.succeed()
	return


func task_to_roll_process(task):
	if _bot.current_health <= 0 || _bot.timer_stun.is_stopped() == false:
		before_stun = _bot.state
		_bot.state = _st_stun
		task.succeed()
		return
	if switching == false:
		_bot.state = _st_roll
		task.succeed()
		return


func task_weap_commit_process(task):
	if _bot.current_health <= 0 || _bot.timer_stun.is_stopped() == false:
		before_stun = _bot.state
		_bot.state = _st_stun
		task.succeed()
		return
	if _bot.current_weapon.weap_commit == false:
		_bot.state = _st_turret
		task.succeed()
		return


func task_charge_roll_process(task):
	if _bot.current_health <= 0:
		_bot.state = _st_dead
		task.succeed()
		return
	if charge_roll == null:
		_bot.state = _st_roll
		task.succeed()
		return
	if _bot.timer_stun.is_stopped() == false:
		_bot.timer_stun.stop()


func task_stun_process(task):
	if _bot.current_health <= 0:
		_bot.state = _st_dead
		task.succeed()
		return
	if _bot.timer_stun.is_stopped() == true:
		match before_stun:
			_st_roll, _st_to_roll:
				_bot.state = _st_roll
			_st_turret, _st_to_turret, _st_weap_commit:
				_bot.state = _st_turret
		before_stun = null
		task.succeed()
		return


func task_dead_enter(task):
	_bot.current_health = 0
	_bot.explode()
	task.succeed()
	return


func task_dead_process(task):
	task.reset()
