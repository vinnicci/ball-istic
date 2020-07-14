extends "res://scenes/bots/_ais/_base/_BaseAI.gd"


export (int) var max_shooting_dist: int = 500
export (int) var enemy_too_close_dist: int = 250
export (int) var max_flee_dist: int = 700


func _ready() -> void:
	_params_dict["max_shooting"] = max_shooting_dist
	_params_dict["enemy_too_close"] = enemy_too_close_dist
	_params_dict["max_flee"] = max_flee_dist
