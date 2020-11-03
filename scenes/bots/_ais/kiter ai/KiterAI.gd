extends "res://scenes/bots/_ais/_base/_BaseAI.gd"


export (int) var max_shooting_dist: int = 500
export (int) var enemy_too_close_dist: int = 250
export (int) var max_flee_dist: int = 600


func _ready() -> void:
	_params_dict["max_shooting"] = max_shooting_dist
	_params_dict["enemy_too_close"] = enemy_too_close_dist
	_params_dict["max_flee"] = max_flee_dist


var _proj_dict: Dictionary


func _process(_delta: float) -> void:
	_params_dict["max_flee"] = max_flee_dist
	if _check_if_valid_bot(_enemy) == true:
		match _enemy.state:
			Global.CLASS_BOT.State.TURRET, Global.CLASS_BOT.State.TO_TURRET, Global.CLASS_BOT.State.WEAP_COMMIT:
				var enemy_proj: PackedScene = _enemy.current_weapon.Projectile
				if is_instance_valid(enemy_proj) == false:
					return
				if _proj_dict.has(enemy_proj) == true:
					_params_dict["max_flee"] = _proj_dict[enemy_proj]
					return
				var sample_proj: Node = enemy_proj.instance()
				if sample_proj is Global.CLASS_PROJ:
					_proj_dict[enemy_proj] = sample_proj.proj_range + 300
					_params_dict["max_flee"] = _proj_dict[enemy_proj]
