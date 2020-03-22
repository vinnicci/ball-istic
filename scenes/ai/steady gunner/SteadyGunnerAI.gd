extends "res://scenes/ai/_BaseAI.gd"


var in_weapon_range: bool = false
var is_weapon_overheating: bool = false
var is_shield_low: bool = false #20% minimum to flee


func _on_WeaponRange_body_entered(body: Node) -> void:
	if body == targeting && bot_node.is_hostile != body.is_hostile:
		in_weapon_range = true


func _on_WeaponRange_body_exited(body: Node) -> void:
	if body == targeting:
		in_weapon_range = false
