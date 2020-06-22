extends "res://scenes/passives/combination/CombinationPassive.gd"


func _ready() -> void:
	_arr_eff.shuffle()
	for i in range(3):
		_effects.append(_arr_eff.pop_front())
