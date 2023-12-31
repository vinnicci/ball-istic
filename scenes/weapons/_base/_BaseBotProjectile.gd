extends "res://scenes/bots/_base/_BaseBot.gd"


export (float) var lifetime_timer: float = 15

var _glow: Node
var _shooter: Node
var is_crit: bool = false

onready var _lifetime: = $Timers/Lifetime


func _ready() -> void:
	_glow = _body_charge_effect.duplicate()
	$Body.add_child(_glow)
	_lifetime.start(lifetime_timer)


func set_shooter(shooter: Node, shooter_faction: Color) -> void:
	_shooter = shooter
	if has_node("AI") == true:
		$AI.clear_enemies()
		$AI.set_master(_shooter)
	faction = shooter_faction


func init_travel(pos: Vector2, dir: float) -> void:
	global_position = pos
	if is_crit == true:
		$Explosion.is_crit = true
	reset_bot_vars()
	apply_central_impulse(Vector2(2000, 0).rotated(dir))


var _dying: bool = false


func _process(_delta: float) -> void:
	#glow upon dying
	if _dying == true:
		return
	if _lifetime.time_left <= 1 || state == State.DEAD:
		_switch_tween.interpolate_property(_glow, "modulate", _glow.modulate,
			Color(1,1,1,0.75), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_switch_tween.start()
		_dying = true


func _on_Lifetime_timeout() -> void:
	if state != State.DEAD:
		take_damage(999, Vector2(0,0), false)
