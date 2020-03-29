extends "res://scenes/ai/_BaseAI.gd"


var is_backing_off: bool = false


func _ready() -> void:
	randomize()
	escape_points = []
	has_flee_points = false
	$ChargeRange/CollisionShape2D.shape.radius = rand_range(120, 220) + bot_node.bot_radius


func _state_control(delta):
	match(state):
		"Idle": _idle(delta)
		"Seek": _seek_target(delta)
		"Flee": _flee(delta)


func _on_ChargeRange_body_entered(body: Node) -> void:
	if body == target && is_backing_off == false:
		bot_node.charge_attack($TargetRay.global_rotation)
		is_backing_off = true


func _on_FleeChargeRange_body_entered(body: Node) -> void:
	if body == target:
		if bot_node.timer_charge_cooldown.is_stopped() == true:
			is_backing_off = false
		else:
			is_backing_off = true


func _on_FleeChargeRange_body_exited(body: Node) -> void:
	if body == target:
		if bot_node.timer_charge_cooldown.is_stopped() == true:
			is_backing_off = false
		else:
			is_backing_off = true
