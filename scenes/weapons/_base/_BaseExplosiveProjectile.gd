extends "res://scenes/weapons/_base/_BaseProjectile.gd"


var exploded: bool = false


func _on_Projectile_body_entered(body: Node) -> void:
	if body.get_parent().name == "Bots" && body.is_hostile == self.origin:
		return
	elif body.get_parent().name == "Bots" && body.is_hostile != self.origin:
		$Explosion.start_explosion()
	else:
		$Explosion.start_explosion()
	exploded = true
	velocity = Vector2(0,0)
	$Sprite.hide()
	set_deferred("monitoring", false)


func _on_RangeTimer_timeout() -> void:
	velocity = Vector2(0,0)
	if exploded == false:
		$Explosion.start_explosion()
	$Sprite.hide()
	$RemoveTimer.start()
	set_deferred("monitoring", false)
