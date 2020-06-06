extends "res://scenes/bots/_base/_BaseBotRolling.gd"


func init_travel(proj_position: Vector2, proj_direction: float, origin: bool) -> void:
	global_position = proj_position
	apply_central_impulse(Vector2(2000, 0).rotated(proj_direction))
	hostile = origin
	$Timers/Lifetime.start()


func _on_Lifetime_timeout() -> void:
	if bot_state != BotState.DEAD:
		emit_signal("control_state_changed", false)
		emit_signal("bot_state_changed", BotState.DEAD)
		explode()
