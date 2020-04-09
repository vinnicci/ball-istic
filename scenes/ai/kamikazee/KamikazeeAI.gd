extends "res://scenes/ai/charger/ChargerAI.gd"


func _ready() -> void:
	$ChargeRange/CollisionShape2D.shape.radius = 300


func _on_ChargeRange_body_entered(body: Node) -> void:
	if body == target && is_backing_off == false:
		bot_node.charge_attack($TargetRay.global_rotation)
		bot_node.take_damage(999, Vector2(0,0))
