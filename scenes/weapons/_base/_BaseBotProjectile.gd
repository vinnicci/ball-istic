extends "res://scenes/bots/_base/_BaseBotRolling.gd"


onready var _lifetime: = $Timers/Lifetime
var _dying: bool = false
var _glow: Node


func _ready() -> void:
	_glow = _body_charge_effect.duplicate()
	$Body.add_child(_glow)


func init_travel(proj_position: Vector2, proj_direction: float, origin: bool, shooter: Node) -> void:
	global_position = proj_position
	hostile = origin
	if has_node("AI") == true:
		$AI.clear_enemies()
		$AI.set_master(shooter)
		$AI.set_level(Global.current_level)
	if hostile:
		_body_outline.modulate = HOSTILE_COLOR
	else:
		_body_outline.modulate = NON_HOSTILE_COLOR
	apply_central_impulse(Vector2(2000, 0).rotated(proj_direction))
	$Timers/Lifetime.start()


func _process(delta: float) -> void:
	#glow upon dying
	if _lifetime.time_left <= _lifetime.wait_time*0.2 && _dying == false:
		_body_tween.interpolate_property(_glow, "modulate", _glow.modulate,
			Color(1,1,1,0.75), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_body_tween.start()
		_dying = true


func _on_Lifetime_timeout() -> void:
	if state != State.DEAD:
		current_health = 0
