extends "res://scenes/ai/_BaseAI.gd"


var is_backing_off: bool = false


func _ready() -> void:
	randomize()
	$ChargeRange/CollisionShape2D.shape.radius = rand_range(120, 220) + bot_node.bot_radius


func _on_ChargeRange_body_entered(body: Node) -> void:
	if body == target && bot_node.timer_charge_cooldown.is_stopped() == true && is_backing_off == false && is_stuck == false:
		bot_node.charge_attack($TargetRay.global_rotation)
		is_backing_off = true


func _on_BackOffRange_body_exited(body: Node) -> void:
	if body == target:
		is_backing_off = false
		is_stuck = false


func _on_BackOffRange_body_entered(body: Node) -> void:
	if body == target:
		if bot_node.timer_charge_cooldown.is_stopped() == false:
			is_backing_off = true
