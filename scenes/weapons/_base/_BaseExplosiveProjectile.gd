extends "res://scenes/weapons/_base/_BaseProjectile.gd"


var _exploded: bool = false


func _on_Projectile_body_entered(body: Node) -> void:
	if body is CLASS_BOT && body.is_hostile == _origin:
		return
	elif body is CLASS_BOT && body.is_hostile != _origin:
		$Explosion.start_explosion()
	else:
		$Explosion.start_explosion()
	_exploded = true
	_proj_velocity = Vector2(0,0)
	$Sprite.hide()
	set_deferred("monitoring", false)


func _on_RangeTimer_timeout() -> void:
	_proj_velocity = Vector2(0,0)
	if _exploded == false:
		$Explosion.start_explosion()
	$Sprite.hide()
	$RemoveTimer.start()
	set_deferred("monitoring", false)
