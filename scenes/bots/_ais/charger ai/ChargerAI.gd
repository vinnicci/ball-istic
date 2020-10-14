extends "res://scenes/bots/_ais/_base/_BaseAI.gd"


export (int) var back_off_flee_dist: int = 380
export (float) var charge_break: float = 0.5


func _ready() -> void:
	_params_dict["back_off_flee"] = back_off_flee_dist
	_params_dict["charge_break"] = charge_break
