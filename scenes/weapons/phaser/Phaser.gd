extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var _is_line_colliding: bool = false


func _process(_delta: float) -> void:
	#blob sprite
	if _is_overheating == true:
		_animate_glow(false)
		$Sprite/Anim.stop(false)
	else:
		_animate_glow(true)
		$Sprite/Anim.play("rotate")
	
	#line
	if (_parent_node != null && _parent_node is Global.CLASS_PLAYER &&
		_parent_node.state == Global.CLASS_BOT.State.TURRET && _parent_node.current_weapon == self):
		$TeleLine.cast_to = get_local_mouse_position()
		if _timer_shoot_cooldown.is_stopped() == true && _is_overheating == false:
			$Line2D.show()
			$Line2D.points[1] = $TeleLine.cast_to
			if $TeleLine.get_collider() != null && _is_line_colliding == false:
				$Line2D/Anim.play("shift_color")
				_is_line_colliding = true
			elif $TeleLine.get_collider() == null && _is_line_colliding == true:
				$Line2D/Anim.play_backwards("shift_color")
				_is_line_colliding = false
		else:
			$Line2D.hide()
	else:
		$Line2D.hide()


var _glowing: bool = true
const VISIBLE_COLOR: Color = Color(0.6, 1, 1, 1)
const INVISIBLE_COLOR: Color = Color(0.6, 1, 1, 0)


func _animate_glow(to_show: bool) -> void:
	var from_value: Color
	var to_value: Color
	if to_show == false && _glowing == true:
		from_value = VISIBLE_COLOR
		to_value = INVISIBLE_COLOR
		_glowing = false
	elif to_show == true && _glowing == false:
		from_value = INVISIBLE_COLOR
		to_value = VISIBLE_COLOR
		_glowing = true
	else:
		return
	$WeaponTween.interpolate_property($Sprite/Glow, "modulate", from_value,
		to_value, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$WeaponTween.start()


func _fire_other(to_pos = null) -> void:
	$TeleLine.cast_to = get_local_mouse_position()
	if $TeleLine.get_collider() != null:
		current_heat -= heat_per_shot
		_timer_shoot_cooldown.stop()
		return
	to_pos = to_global($TeleLine.cast_to)
	_parent_node.teleport(to_pos)
