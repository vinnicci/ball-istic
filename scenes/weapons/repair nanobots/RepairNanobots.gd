extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _fire_other() -> void:
	if _parent_node.current_health == _parent_node.current_health_cap:
		current_heat -= current_heat_per_shot
		$ShootingSound.stop()
		return
	$ShootingSound.play()
	var tween = $WeaponTween
	tween.interpolate_property($Sprite/Glow, "scale", Vector2(3,3), Vector2(0.8, 0.8),
		0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	_parent_node.set_current_health(_parent_node.current_health_cap)
