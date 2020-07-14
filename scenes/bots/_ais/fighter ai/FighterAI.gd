extends "res://scenes/bots/_ais/_base/_BaseAI.gd"


export (int) var max_shooting_dist: int = 500
export (int) var charge_seek_dist: int = 250
export (int) var charge_back_off_seek_dist: int = 350
export (int) var charge_back_off_flee_dist: int = 380
export (float) var charge_break: float = 0.5


func _ready() -> void:
	_params_dict["max_shooting"] = max_shooting_dist
	_params_dict["charge_seek"] = charge_seek_dist
	_params_dict["charge_back_off_seek"] = charge_back_off_seek_dist
	_params_dict["charge_back_off_flee"] = charge_back_off_flee_dist
	_params_dict["charge_break"] = charge_break
