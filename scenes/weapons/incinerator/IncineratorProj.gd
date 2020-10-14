extends "res://scenes/weapons/_base/_BaseProjectile.gd"


const WHITE: = Color(1, 1, 1)
const ORANGE: = Color(0.9, 0.5, 0)
var _is_shifting: bool = false


func _process(_delta: float) -> void:
	if $RangeTimer.is_stopped() == false && _is_shifting == false:
		$ColorTween.interpolate_property($Sprite, "modulate", WHITE, ORANGE,
			(float(proj_range) / float(current_speed)) * 0.1, Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT)
		$ColorTween.start()
		_is_shifting = true
