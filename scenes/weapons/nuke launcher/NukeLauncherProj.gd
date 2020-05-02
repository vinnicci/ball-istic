extends "res://scenes/weapons/_base/_BaseExplosiveProjectile.gd"


func _on_Projectile_body_entered(body: Node) -> void:
	._on_Projectile_body_entered(body)
	if body is Global.CLASS_PLAYER == false:
		_flash_screen()


func _flash_screen() -> void:
	$LightFlash/ColorRect.show()
	$LightFlash/ColorRect/AnimationPlayer.play("flash")
	$Particles2D.hide()


func _on_RangeTimer_timeout() -> void:
	if _exploded == false:
		$Explosion.start_explosion()
		_flash_screen()
	$RemoveTimer.start()
	_stop_projectile()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	$LightFlash/ColorRect.hide()
