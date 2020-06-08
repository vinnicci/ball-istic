extends "res://scenes/bots/_base/_BaseBotRolling.gd"


onready var _lifetime: = $Timers/Lifetime
var _dying: bool = false


func init_travel(proj_position: Vector2, proj_direction: float, origin: bool) -> void:
	global_position = proj_position
	hostile = origin
	apply_central_impulse(Vector2(2000, 0).rotated(proj_direction))
	if hostile:
		_body_outline.modulate = HOSTILE_COLOR
	else:
		_body_outline.modulate = NON_HOSTILE_COLOR
	$Timers/Lifetime.start()


func _process(delta: float) -> void:
	if _lifetime.time_left <= _lifetime.wait_time*0.2 && _dying == false:
		_body_tween.interpolate_property(_body_charge_effect, "modulate", _body_charge_effect.modulate,
			Color(1,1,1,0.5), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_body_tween.start()
		_dying = true


func _on_Lifetime_timeout() -> void:
	if state != State.DEAD:
		current_health = 0
