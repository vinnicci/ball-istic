extends "res://scenes/bots/_ais/_base/_BaseAI.gd"


export (int) var back_off_flee_dist: int = 380


func _ready() -> void:
	_params_dict["back_off_flee"] = back_off_flee_dist
