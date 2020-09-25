extends "res://scenes/global/explosions/_base/_BaseExplosion.gd"


export (float) var stun_time: = 3.0


func _apply_effect(body: Node) -> void:
	$KnockBackDirection.look_at(body.global_position)
	if body.has_method("take_damage") == true:
		body.take_damage(damage, Vector2(knockback, 0).rotated($KnockBackDirection.global_rotation))
		if body is Global.CLASS_BOT:
			var level_node = _level_cam.get_parent()
			body.stun_effect(stun_time)
#			body.timer_stun.start(stun_time)
#			_play_stun_effect(_level_cam.get_parent(), body.global_position)
		if is_crit == true && body is Global.CLASS_BOT:
			body.crit_effect()
#			_play_crit_effect(body.global_position)


#func _play_stun_effect(level_node, pos) -> void:
#	var stun_node = _stun_feedback.instance()
#	level_node.add_child(stun_node)
#	stun_node.global_position = pos
#	var stun_anim = stun_node.get_node("Anim")
#	stun_anim.connect("animation_finished", level_node, "_on_Anim_finished",
#		[stun_node])
#	stun_anim.play("stun")
