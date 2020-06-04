extends Node


#stun effect removal and cleanup
func _on_StunTimer_timeout(body: Global.CLASS_BOT, timer_obj: Timer) -> void:
	body.set_control_state(true, "stun")
	timer_obj.queue_free()


#trail effect cleanup
func _on_Trail_RemoveTimer_timeout(trail_obj: Node) -> void:
	trail_obj.queue_free()
