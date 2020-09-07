extends "res://scenes/global/items/_base/_BaseItem.gd"


func _apply_effects() -> void:
	pass


func _apply_charge_cooldown(effect: float) -> void:
	_parent_node.current_charge_cooldown -= effect


func _apply_charge_damage_rate(effect: float) -> void:
	_parent_node.current_charge_damage_rate += effect


func _apply_charge_force(effect: float) -> void:
	_parent_node.current_charge_force_factor += effect


func _apply_health_cap(effect: float) -> void:
	_parent_node.current_health_cap += effect
	_parent_node.current_health = _parent_node.current_health_cap


func _apply_weap_damage_rate(effect: float) -> void:
	_parent_node.current_weap_damage_rate += effect
#	for weapon in _parent_node.arr_weapons:
#		if weapon == null || weapon.get_heat_dissipation() == 0:
#			continue
#		weapon.current_heat_dissipation += weapon.get_heat_dissipation() * effect


func _apply_knockback_resist(effect: float) -> void:
	_parent_node.current_knockback_resist += effect


func _apply_shield_cap(effect: float) -> void:
	_parent_node.current_shield_cap += effect
	_parent_node.current_shield = _parent_node.current_shield_cap


func _apply_shield_recovery(effect: float) -> void:
	_parent_node.current_shield_recovery += effect


func _apply_speed(effect: int) -> void:
	_parent_node.current_speed += effect


func _apply_transform_speed(effect: float) -> void:
	_parent_node.current_transform_speed -= effect
