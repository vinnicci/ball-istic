extends "res://scenes/level/_base/_BaseLevel.gd"


func _ready() -> void:
	var allies: Array
	for bot in $Bots.get_children():
		if bot.destructible == false:
			continue
		if bot.current_faction == Color(0,1,0):
			allies.append(bot)
	$Follow.set_allies(allies)
