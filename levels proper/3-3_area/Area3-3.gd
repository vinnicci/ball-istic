extends "res://scenes/level/_base/_BaseLevel.gd"


func _ready() -> void:
	$Bots/LongArtilleryBot.set_controller($Bots/ArtilleryController)
	$Follow.set_level(self)


onready var _enemies: Array = [
	$Bots/ArtilleryController, $Bots/SniperBot, $Bots/Balladin, $Bots/Balladin2,
	$Bots/Cannoneer
]
onready var allies: Array = [
	$Bots/Charger, $Bots/Charger2, $Bots/Fighter
]


func _on_bot_dead(bot) -> void:
	if _enemies.has(bot) == true:
		_enemies.erase(bot)
	if _enemies.size() == 0:
		emit_signal("quest_updated", "DACS", "A3")
	._on_bot_dead(bot)
