extends "res://scenes/bots/_base/_BaseBot.gd"


func _ready() -> void:
	_switch_to_roll()
	$Sounds/ChangeMode.stop()
	state = State.ROLL


func _on_SwitchTween_tween_all_completed() -> void:
	._on_SwitchTween_tween_all_completed()
	current_transform_speed = 0.6
