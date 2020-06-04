extends "res://scenes/global/explosions/_base/_BaseExplosion.gd"


export (float) var stun_time: = 2.0


func _ready() -> void:
	$StunTimer.wait_time = stun_time


func _apply_effect(body: Node) -> void:
	._apply_effect(body)
	if body is Global.CLASS_BOT:
		if body.has_node("StunTimer") == false:
			var timer = $StunTimer.duplicate()
			body.add_child(timer)
			timer.connect("timeout", Cleaner, "_on_StunTimer_timeout", [body, timer])
		body.get_node("StunTimer").start()
		body.set_control_state(false, "stun")
