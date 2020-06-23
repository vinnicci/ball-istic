extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _physics_process(delta: float) -> void:
	if (_parent_node is Global.CLASS_BOT && _parent_node.state == Global.CLASS_BOT.State.TURRET &&
		_parent_node.current_weapon == self):
		$FrontShield.monitoring = true
	else:
		$FrontShield.monitoring = false


func animate_transform(transform_speed: float) -> void:
	if modulate == Color(1,1,1,1):
		$WeaponTween.interpolate_property(self, 'modulate', Color(1,1,1,1), Color(1,1,1,0),
			transform_speed*0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	elif modulate == Color(1,1,1,0):
		$WeaponTween.interpolate_property(self, 'modulate', Color(1,1,1,0), Color(1,1,1,1),
			transform_speed*0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$WeaponTween.start()


func _on_FrontShield_area_entered(area: Area2D) -> void:
	if (area is Global.CLASS_PROJ == false || area.origin() == _parent_node.current_faction ||
		_is_overheating == true):
		return
	area.queue_free()
	if area.has_node("Explosion"):
		current_heat += area.get_node("Explosion").get_damage()
	else:
		current_heat += area.damage
