extends "res://scenes/weapons/_base/_BaseProjectile.gd"


var _exploded: bool = false


func _on_Projectile_body_entered(body: Node) -> void:
	if body is Global.CLASS_BOT:
		if body.is_hostile() == _origin:
			return
		elif body.is_hostile() != _origin && body.is_alive() == false:
			return
		else:
			$Explosion.start_explosion()
	else:
		$Explosion.start_explosion()
	_exploded = true
	_stop_projectile()


func _on_RangeTimer_timeout() -> void:
	if _exploded == false:
		$Explosion.start_explosion()
	._on_RangeTimer_timeout()
