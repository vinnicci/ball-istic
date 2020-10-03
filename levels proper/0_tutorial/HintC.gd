extends "res://scenes/level/hint/Hint.gd"


var dummy: Node


func set_level(level) -> void:
	.set_level(level)
	dummy = _level.bot_C


var _clear_count: int = 0
var _done: bool = false


func on_bullet_clear() -> void:
	if _done == true:
		return
	_clear_count += 1
	$AccessUI/Label2.text = "Clear out enemy bullets: (%s/15)" % _clear_count
	if _clear_count >= 15:
		dummy.remove_child(dummy.get_node("AI"))
		$AccessUI/Label2.text = "Great job! Move on to the final room."
		_level.door_C.open()
		$AccessUI/Label2/FadeTimer.start()
		_done = true
