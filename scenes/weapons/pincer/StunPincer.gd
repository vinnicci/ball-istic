extends "res://scenes/weapons/pincer/Pincer.gd"


export var stun_time: float = 3


func _on_HurtBox_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT:
		if body.current_faction == _parent_node.current_faction:
			return
		elif body.current_faction != _parent_node.current_faction && body.state == Global.CLASS_BOT.State.DEAD:
			return
		else:
			body.take_damage(_apply_crit_a(body), Vector2(knockback, 0).rotated(rotation))
	else:
		body.take_damage(damage, Vector2(knockback, 0).rotated(rotation))


func _apply_crit_a(body) -> float:
	var dmg: float
	if rand_range(0, 1.0) <= crit_chance:
		dmg = damage * proj_damage_rate * crit_mult
		body.timer_stun.start(stun_time)
		_play_crit_effect(body.global_position)
	else:
		dmg = damage * proj_damage_rate
	return dmg


var _stun_feedback = load("res://scenes/global/feedback/Stun.tscn")


func _play_crit_effect(pos) -> void:
	._play_crit_effect(pos)
	var stun_node = _stun_feedback.instance()
	level_node.add_child(stun_node)
	stun_node.global_position = pos
	var stun_anim = stun_node.get_node("Anim")
	stun_anim.connect("animation_finished", level_node, "_on_Anim_finished",
		[stun_node])
	stun_anim.play("stun")


func _on_Anim_animation_finished(anim_name: String) -> void:
	weap_commit = false
