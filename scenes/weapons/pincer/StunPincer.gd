extends "res://scenes/weapons/pincer/Pincer.gd"


export var stun_time: float = 3


func _apply_melee_crit_effect(body) -> void:
	body.timer_stun.start(stun_time)


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
