extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _physics_process(delta: float) -> void:
	if (_parent_node is Global.CLASS_BOT && _parent_node.state == Global.CLASS_BOT.State.TURRET &&
		_parent_node.current_weapon == self):
		$FrontShield.monitoring = true
	else:
		$FrontShield.monitoring = false


func _on_FrontShield_area_entered(area: Area2D) -> void:
	if (area is Global.CLASS_PROJ == false || area.shooter_faction() == _parent_node.current_faction ||
		_is_overheating == true):
		return
	if area.has_node("Explosion"):
		current_heat += area.get_node("Explosion").get_damage()
	else:
		current_heat += area.damage
	area.queue_free()
