extends "res://scenes/weapons/_base/_BaseExplosiveProjectile.gd"


func _on_Projectile_body_entered(body: Node) -> void:
	if body.has_method("take_damage") == false:
		return
	if body.get_parent().name == "Bots" && body.is_hostile == _origin:
		return
	elif body.get_parent().name == "Bots" && body.is_hostile != _origin:
		$Explosion.start_explosion()
	else:
		$Explosion.start_explosion()
	_proj_velocity = Vector2(0,0)
	$Sprite.hide()
	_exploded = true
	_flash_screen()
	set_deferred("monitoring", false)


func _flash_screen() -> void:
	$LightFlash/ColorRect.show()
	$LightFlash/ColorRect/AnimationPlayer.play("flash")
	$Particles2D.hide()


func _on_RangeTimer_timeout() -> void:
	_proj_velocity = Vector2(0,0)
	$Sprite.hide()
	$RemoveTimer.start()
	if _exploded == false:
		$Explosion.start_explosion()
		_flash_screen()
	set_deferred("monitoring", false)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	$LightFlash/ColorRect.hide()
