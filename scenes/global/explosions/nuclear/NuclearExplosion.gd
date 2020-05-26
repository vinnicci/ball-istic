extends "res://scenes/global/explosions/_base/_BaseExplosion.gd"


func start_explosion() -> void:
	_flash_screen()
	.start_explosion()


func _flash_screen() -> void:
	$LightFlash/ColorRect.show()
	$LightFlash/ColorRect/AnimationPlayer.play("flash")
	$Particles2D.hide()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	$LightFlash/ColorRect.hide()
