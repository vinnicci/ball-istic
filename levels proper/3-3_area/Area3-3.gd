extends "res://scenes/level/_base/_BaseLevel.gd"


signal quest_updated
var _enemies: Array
var allies: Array


func _ready() -> void:
	$Bots/LongArtilleryBot.set_controller($Bots/ArtilleryController)
	$Follow.set_level(self)
	for bot in $Bots.get_children():
		if bot.destructible == false:
			continue
		if bot.current_faction == Color(0,1,0):
			allies.append(bot)
		else:
			_enemies.append(bot)


func _on_bot_dead(bot) -> void:
	if _enemies.has(bot) == true:
		_enemies.erase(bot)
	if _enemies.size() == 0:
		emit_signal("quest_updated", "DACS", "A3")
	._on_bot_dead(bot)
