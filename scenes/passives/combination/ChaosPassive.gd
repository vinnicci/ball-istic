extends "res://scenes/passives/combination/CombinationPassive.gd"


var _negative_effects = []


func _ready() -> void:
	_arr_eff.shuffle()
	for i in range(3):
		_effects.append(_arr_eff.pop_front())
	for i in range(2):
		_negative_effects.append(_arr_eff.pop_front())


func _apply_effects() -> void:
	._apply_effects()
	for effect in _negative_effects:
		_pick_effect(effect, -1)
	var shield = _parent_node.current_shield_cap
	if shield < 0:
		_apply_shield_cap(-shield)
	#safety measure for when health cap goes negative
	var health = _parent_node.current_health_cap
	if health <= 0:
		_apply_health_cap(-health + 1)
