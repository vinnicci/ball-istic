extends "res://scenes/global/explosions/_base/_BaseExplosion.gd"


export (float) var stun_time: = 2.0


func _apply_effect(body: Node) -> void:
	._apply_effect(body)
	if body is Global.CLASS_BOT:
		body.timer_stun.start(stun_time)
