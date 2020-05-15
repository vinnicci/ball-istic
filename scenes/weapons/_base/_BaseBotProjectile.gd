extends "res://scenes/bots/_base/_BaseBotUnarmed.gd"


func init_travel(proj_position: Vector2, proj_direction: float, origin: bool) -> void:
	global_position = proj_position
	apply_central_impulse(Vector2(2000, 0).rotated(proj_direction))
	hostile = origin
	$Timers/Lifetime.start()


func _on_Lifetime_timeout() -> void:
	if _is_alive == true:
		_explode()
