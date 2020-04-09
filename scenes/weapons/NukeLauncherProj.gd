extends "res://scenes/weapons/_BaseProjectile.gd"


var exploded: bool = false


func _on_Projectile_body_entered(body: Node) -> void:
	if body.has_method("take_damage") == false:
		return
	if body.get_parent().name == "Bots" && body.is_hostile == proj_origin:
		return
	elif body.get_parent().name == "Bots" && body.is_hostile != proj_origin:
		$Explosion.start_explosion()
	else:
		$Explosion.start_explosion()
	velocity = Vector2(0,0)
	$Sprite.hide()
	exploded = true
	_flash_screen()
	set_deferred("monitoring", false)


func _flash_screen() -> void:
	$LightFlash/ColorRect.show()
	$LightFlash/ColorRect/AnimationPlayer.play("flash")
	$Particles2D.hide()


func _on_RangeTimer_timeout() -> void:
	velocity = Vector2(0,0)
	$Sprite.hide()
	$RemoveTimer.start()
	if exploded == false:
		$Explosion.start_explosion()
		_flash_screen()
	set_deferred("monitoring", false)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	$LightFlash/ColorRect.hide()
