extends "res://scenes/level/hint/Hint.gd"


var dummy: Node


func set_level(level) -> void:
	.set_level(level)
	dummy = _level.bot_C
	_level.get_player().connect("clashed", self, "on_bot_clashed")


var _clash_count: = 0


func on_bot_clashed() -> void:
	_clash_count += 1
	$AccessUI/Label2.text = "Deflect enemy charge rolls by clashing: (%s/3)" % _clash_count
	if _clash_count == 3:
		dummy.remove_child(dummy.get_node("AI"))
		$AccessUI/Label2.text = "Great job! Move on to the final room."
		_level.door_C.open()
		$AccessUI/Label2/FadeTimer.start()
