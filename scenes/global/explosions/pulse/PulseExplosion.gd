extends "res://scenes/global/explosions/_base/_BaseExplosion.gd"


export (float) var stun_time: = 3.0


func _apply_effect(body: Node) -> void:
	$KnockBackDirection.look_at(body.global_position)
	if body.has_method("take_damage") == true:
		body.take_damage(damage, Vector2(knockback, 0).rotated($KnockBackDirection.global_rotation))
		if body is Global.CLASS_BOT:
			var level_node = _level_cam.get_parent()
			body.stun_effect(stun_time)
		if is_crit == true && body is Global.CLASS_BOT:
			body.crit_effect()
