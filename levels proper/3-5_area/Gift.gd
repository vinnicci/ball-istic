extends "res://scenes/passives/_base/_BasePassive.gd"


func _ready() -> void:
	description = "A small upgrade to everything"


func apply_effect() -> void:
	_parent_node.current_charge_cooldown -= 1.1
	_parent_node.current_charge_dmg_rate += 0.45
	_parent_node.current_charge_force_mult += 0.25
	_parent_node.current_health_cap += 65
	_parent_node.set_current_health(_parent_node.current_health_cap)
	_parent_node.current_dmg_resist += 0.1875
	_parent_node.current_knockback_resist += 0.25
	_parent_node.current_shield_cap += 65
	_parent_node.set_current_shield(_parent_node.current_shield_cap)
	_parent_node.current_shield_regen += 3.5
	_parent_node.current_speed += 240
	_parent_node.current_transform_speed -= 0.2333
	for weapon in _parent_node.get_node("Weapons").get_children():
		weapon.current_heat_cap += weapon.current_heat_cap
	_parent_node.current_weap_dmg_rate += 1
