extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _fire_other() -> void:
	if _parent_node.current_shield == _parent_node.current_shield_cap:
		current_heat -= current_heat_per_shot
		$ShootingSound.stop()
		return
	_parent_node.current_shield = _parent_node.current_shield_cap
	_parent_node.bar_shield.value = _parent_node.current_shield
