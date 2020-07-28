extends "res://scenes/global/explosions/_base/_BaseExplosion.gd"


export (float) var stun_time: = 3.0
var _stun_feedback = load("res://scenes/global/feedback/Stun.tscn")


func _apply_effect(body: Node) -> void:
	$KnockBackDirection.look_at(body.global_position)
	if body.has_method("take_damage") == true:
		body.take_damage(current_damage, Vector2(knockback, 0).rotated($KnockBackDirection.global_rotation))
		if is_crit == true && body is Global.CLASS_BOT:
			body.timer_stun.start(stun_time)
			_play_crit_effect(body.global_position)


func _play_crit_effect(pos: Vector2) -> void:
	var level_node = _level_cam.get_parent()
	var crit_node = _crit_feedback.instance()
	level_node.add_child(crit_node)
	var crit_anim = crit_node.get_node("Anim")
	crit_node.global_position = pos
	crit_anim.connect("animation_finished", level_node, "_on_Anim_finished",
		[crit_node])
	crit_anim.play("critical")
	var stun_node = _stun_feedback.instance()
	level_node.add_child(stun_node)
	stun_node.global_position = pos
	var stun_anim = stun_node.get_node("Anim")
	stun_anim.connect("animation_finished", level_node, "_on_Anim_finished",
		[stun_node])
	stun_anim.play("stun")
	
