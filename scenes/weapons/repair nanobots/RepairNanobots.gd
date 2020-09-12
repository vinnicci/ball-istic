extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _fire_other() -> void:
	if _parent_node.current_health == _parent_node.current_health_cap:
		current_heat -= current_heat_per_shot
		$ShootingSound.stop()
		return
	_parent_node.current_health = _parent_node.current_health_cap
	_parent_node.bar_health.value = _parent_node.current_health
