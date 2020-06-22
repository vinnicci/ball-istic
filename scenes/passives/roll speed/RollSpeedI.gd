extends "res://scenes/passives/_base/_BasePassive.gd"


const EFFECT: int = 135


func _apply_effects() -> void:
	_parent_node.current_speed += EFFECT
