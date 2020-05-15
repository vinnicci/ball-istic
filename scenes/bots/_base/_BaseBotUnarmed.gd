extends "res://scenes/bots/_base/_BaseBot.gd"


func _ready() -> void:
	switch_mode()
	$Sounds/ChangeMode.stop()


func _on_WeaponHatchTween_tween_all_completed() -> void:
	._on_WeaponHatchTween_tween_all_completed()
	transform_speed = 0.5
