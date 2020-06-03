extends "res://scenes/global/explosions/_base/_BaseExplosion.gd"


func start_explosion() -> void:
	.start_explosion()
	_flash_screen()


func _flash_screen() -> void:
	$LightFlash/ColorRect.show()
	$LightFlash/ColorRect/AnimationPlayer.play("flash")
	$Particles2D.hide()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	$LightFlash/ColorRect.hide()
