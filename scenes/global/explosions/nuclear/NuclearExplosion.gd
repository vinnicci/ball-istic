extends "res://scenes/global/explosions/_base/_BaseExplosion.gd"


func start_explosion() -> void:
	.start_explosion()
	_flash_screen()


func _flash_screen() -> void:
	$LightFlash/ColorRect.show()
	$LightFlash/ColorRect/AnimationPlayer.play("flash")
	$Particles2D.hide()


export (float) var stun_time: = 8.0


func _apply_effect(body: Node) -> void:
	$KnockBackDirection.look_at(body.global_position)
	if body.has_method("take_damage") == true:
		body.take_damage(damage, Vector2(knockback, 0).rotated($KnockBackDirection.global_rotation))
		if body is Global.CLASS_BOT:
			body.stun_effect(stun_time)
		if is_crit == true && body is Global.CLASS_BOT:
			body.crit_effect()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	$LightFlash/ColorRect.hide()
