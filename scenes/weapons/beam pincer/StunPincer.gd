extends "res://scenes/weapons/beam pincer/Pincer.gd"


export var stun_time: float = 3


func _on_HurtBox_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT:
		if body.current_faction == _parent_node.current_faction:
			return
		elif body.current_faction != _parent_node.current_faction && body.state == Global.CLASS_BOT.State.DEAD:
			return
		else:
			body.take_damage(damage * proj_damage_rate, Vector2(knockback, 0).rotated(rotation))
			body.timer_stun.start(stun_time)
	else:
		body.take_damage(damage * proj_damage_rate, Vector2(knockback, 0).rotated(rotation))


func _on_Anim_animation_finished(anim_name: String) -> void:
	weap_commit = false
