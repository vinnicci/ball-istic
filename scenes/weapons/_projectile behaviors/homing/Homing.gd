extends "res://scenes/weapons/_projectile behaviors/_base/_BaseProjBehavior.gd"


func _ready() -> void:
	var homing_range: = 300
	_init_detector(homing_range)
	_init_target_raycast(homing_range)
