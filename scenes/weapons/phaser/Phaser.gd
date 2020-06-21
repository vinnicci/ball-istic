extends "res://scenes/weapons/_base/_BaseWeapon.gd"


var _is_line_colliding: bool = false


func _process(delta: float) -> void:
	if _is_overheating == true:
		$Sprite/Blob.hide()
	else:
		$Sprite/Blob.show()
	if (_parent_node != null && _parent_node is Global.CLASS_PLAYER &&
		_parent_node.state == Global.CLASS_BOT.State.TURRET && _parent_node.current_weapon == self):
		$TeleLine.cast_to = get_local_mouse_position()
		if _timer_shoot_cooldown.is_stopped() == true && _is_overheating == false:
			$Line2D.show()
			$Line2D.points[1] = $TeleLine.cast_to
			if $TeleLine.get_collider() is Global.CLASS_LEVEL_OBJECT && _is_line_colliding == false:
				$Line2D/Anim.play("shift_color")
				_is_line_colliding = true
			elif ($TeleLine.get_collider() is Global.CLASS_LEVEL_OBJECT == false &&
				_is_line_colliding == true):
				$Line2D/Anim.play_backwards("shift_color")
				_is_line_colliding = false
		else:
			$Line2D.hide()
	else:
		$Line2D.hide()


func _fire_other(to_pos = null) -> void:
	if $TeleLine.get_collider() is Global.CLASS_LEVEL_OBJECT:
		current_heat -= heat_per_shot
		_timer_shoot_cooldown.stop()
		return
	to_pos = to_global($TeleLine.cast_to)
	_parent_node.teleport(to_pos)
