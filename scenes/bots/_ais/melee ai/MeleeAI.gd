extends "res://scenes/bots/_ais/_base/_BaseAI.gd"


export (int) var max_melee_dist: int = 250
export (float) var charge_break: float = 0.5


func _ready() -> void:
	_params_dict["max_shooting"] = max_melee_dist
	_params_dict["charge_break"] = charge_break
