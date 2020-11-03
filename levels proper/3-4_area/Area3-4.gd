extends "res://scenes/level/_base/_BaseLevel.gd"


signal quest_updated
var _enemies: Array


func _ready() -> void:
	if has_node("Bots/ArtilleryController") == true:
		$Bots/LongArtilleryBot.set_controller($Bots/ArtilleryController)
	var allies: Array
	for bot in $Bots.get_children():
		if bot.destructible == false || is_instance_valid(bot) == false:
			continue
		if bot.current_faction == Color(0,1,0):
			allies.append(bot)
		else:
			_enemies.append(bot)
	$Follow.set_allies(allies)


func _on_bot_dead(bot) -> void:
	if _enemies.has(bot) == true:
		_enemies.erase(bot)
	print(_enemies.size())
	if _enemies.size() == 0:
		emit_signal("quest_updated", "DACS", "A4")
	._on_bot_dead(bot)
