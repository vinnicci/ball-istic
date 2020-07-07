extends "res://scenes/level/hint/Hint.gd"


var _current_bot_count: int = 3


func set_level(level) -> void:
	.set_level(level)
	var bots: Array = level.bots_A
	for bot in bots:
		bot.connect("dead", self, "on_bot_dead")


func on_bot_dead() -> void:
	_current_bot_count -= 1
	$AccessUI/Label2.text = "Destroy three bots with weapon: (%s/3)" % (3 - _current_bot_count)
	if _current_bot_count == 0:
		$AccessUI/Label2.text = "Great job! Move on to the next room."
		$AccessUI/Label2/FadeTimer.start()
