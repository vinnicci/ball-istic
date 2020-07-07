extends "res://scenes/level/hint/Hint.gd"


var dummy: Node


func set_level(level) -> void:
	.set_level(level)
	dummy = _level.bot_D
	dummy.connect("parried", self, "on_bot_parried")


var _parry_count: = 0


func on_bot_parried() -> void:
	_parry_count += 1
	$AccessUI/Label2.text = "Perform discharge parries: (%s/3)" % _parry_count
	if _parry_count == 3:
		dummy.remove_child(dummy.get_node("AI"))
		$AccessUI/Label2.text = "Congratulations! You completed the tutorial."
		_level.door_A.get_node("Area2D").monitoring = false
		_level.door_A.open()
		_level.door_B.get_node("Area2D").monitoring = false
		_level.door_B.open()
		_level.door_C.get_node("Area2D").monitoring = false
		_level.door_C.open()
		_level.door_D.open()
		$AccessUI/Label2/FadeTimer.start()
