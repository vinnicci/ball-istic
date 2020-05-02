extends "res://scenes/weapons/_base/_BaseProjectile.gd"


var _exploded: bool = false


func _on_Projectile_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT && body.is_hostile() == _origin:
		return
	elif body is Global.CLASS_BOT && body.is_hostile() != _origin:
		$Explosion.start_explosion()
	else:
		$Explosion.start_explosion()
	_exploded = true
	_stop_projectile()


func _on_RangeTimer_timeout() -> void:
	if _exploded == false:
		$Explosion.start_explosion()
	$RemoveTimer.start()
	_stop_projectile()
