extends "res://scenes/bots/_base/_BaseBotRolling.gd"


func init_travel(proj_position: Vector2, proj_direction: float, origin: bool) -> void:
	global_position = proj_position
	hostile = origin
	apply_central_impulse(Vector2(2000, 0).rotated(proj_direction))
	if is_hostile():
		_body_outline.modulate = HOSTILE_COLOR
	else:
		_body_outline.modulate = NON_HOSTILE_COLOR
	$Timers/Lifetime.start()


func _on_Lifetime_timeout() -> void:
	if state != State.DEAD:
		explode()
