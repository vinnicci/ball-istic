extends "res://scenes/weapons/_base/_BaseWeapon.gd"


func _on_ProximityRadius_body_entered(body: Node) -> void:
	if _parent_node.current_faction != body.current_faction:
		_fire_other()


func _fire_other() -> void:
	$ShootingSound.play()
	var timer = _parent_node.get_node("Timers/Lifetime")
	timer.paused = false
	timer.start(1)
