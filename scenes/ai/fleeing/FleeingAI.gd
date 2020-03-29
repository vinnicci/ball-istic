extends "res://scenes/ai/_BaseAI.gd"


func _state_control(delta) -> void:
	match(state):
		"Idle": _idle(delta)
		"Flee": _flee(delta)


func _on_DetectionRange_body_exited(body: Node) -> void:
	if body == target:
		$TargetRay.enabled = false
		in_detection_range = false
		detection_sound_ready = true
