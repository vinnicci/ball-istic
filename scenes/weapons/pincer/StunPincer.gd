extends "res://scenes/weapons/pincer/_base/Pincer.gd"


func _apply_melee_crit_effect(body) -> void:
	body.timer_stun.start(melee_crit_stun_time)
