extends "res://scenes/level/_base/_BaseLevel.gd"


signal quest_updated
onready var _enemies: Array
onready var _explosives: Array = [
	$Bots/ExplosiveDummy, $Bots/ExplosiveDummy2, $Bots/ExplosiveDummy3,
	$Bots/ExplosiveDummy4, $Bots/ExplosiveDummy5
]


func _ready() -> void:
	$Bots/FastArtilleryBot.set_controller($Bots/ArtilleryController)
	$Bots/FastArtilleryBot2.set_controller($Bots/ArtilleryController2)
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_hidden($Nav/Secret)
	var allies: Array
	for bot in $Bots.get_children():
		if bot.destructible == false:
			continue
		if bot.current_faction == Color(0,1,0):
			allies.append(bot)
		else:
			_enemies.append(bot)
	$Follow.set_allies(allies)


func _on_bot_dead(bot) -> void:
	if _enemies.has(bot) == true:
		_enemies.erase(bot)
	if _enemies.size() == 0:
		emit_signal("quest_updated", "DACS", "A1")
		emit_signal("quest_updated", "DACS", "A2")
	._on_bot_dead(bot)


func _on_Secret_visibility_changed() -> void:
	for bot in _explosives:
		bot.take_damage(999, Vector2(0,0), false)
