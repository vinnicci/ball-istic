extends "res://scenes/levels/_base/_BaseLevel.gd"


func _physics_process(delta: float) -> void:
	if is_instance_valid(Globals.player) == false:
		$Camera2D.global_position = Vector2(190, 190)
