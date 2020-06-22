extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: float = 0.6


func _apply_effects() -> void:
	for weapon in _parent_node.arr_weapons:
		if weapon == null:
			continue
		if weapon.get_heat_dissipation() != 0:
			weapon.current_heat_dissipation += weapon.get_heat_dissipation() * EFFECT
