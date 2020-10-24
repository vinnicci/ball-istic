extends "res://scenes/bots/_ais/_base/_BaseAI.gd"


export (int) var max_shooting_dist: int = 500
export (int) var enemy_too_close_dist: int = 250
export (int) var max_flee_dist: int = 600


func _ready() -> void:
	_params_dict["max_shooting"] = max_shooting_dist
	_params_dict["enemy_too_close"] = enemy_too_close_dist
	_params_dict["max_flee"] = max_flee_dist


var _current_enemy_proj: PackedScene


func _process(delta: float) -> void:
	if (_check_if_valid_bot(_enemy) == true &&
		(_enemy.state == Global.CLASS_BOT.State.TURRET ||
		_enemy.state == Global.CLASS_BOT.State.TO_TURRET ||
		_enemy.state == Global.CLASS_BOT.State.WEAP_COMMIT)):
		var enemy_proj: PackedScene = _enemy.current_weapon.Projectile
		if _current_enemy_proj == enemy_proj:
			return
		_current_enemy_proj = enemy_proj
		if is_instance_valid(enemy_proj) == true:
			var sample_proj = enemy_proj.instance()
			if sample_proj is Global.CLASS_PROJ:
				_params_dict["max_flee"] = sample_proj.proj_range + 300
				return
		_params_dict["max_flee"] = max_flee_dist
