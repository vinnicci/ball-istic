extends "res://scenes/bots/_base/_BaseBot.gd"


onready var _lifetime: = $Timers/Lifetime
var _glow: Node
var _shooter: Node
var _level: Node
var is_crit: bool = false


func _ready() -> void:
	_glow = _body_charge_effect.duplicate()
	$Body.add_child(_glow)


func set_shooter(shooter: Node) -> void:
	_shooter = shooter


func init_travel(pos: Vector2, dir: float, shooter_faction: Color) -> void:
	global_position = pos
	faction = shooter_faction
	if has_node("AI") == true:
		$AI.clear_enemies()
		$AI.set_master(_shooter)
	if is_crit == true:
		$Explosion.is_crit = true
	reset_bot_vars()
	apply_central_impulse(Vector2(2000, 0).rotated(dir))
	$Timers/Lifetime.start()


var _dying: bool = false


func _process(delta: float) -> void:
	#glow upon dying
	if _lifetime.time_left <= 1 && _dying == false:
		_body_tween.interpolate_property(_glow, "modulate", _glow.modulate,
			Color(1,1,1,0.75), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_body_tween.start()
		_dying = true


func _on_Lifetime_timeout() -> void:
	if state != State.DEAD:
		current_health = 0
