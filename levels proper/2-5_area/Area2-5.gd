extends "res://scenes/level/_base/_BaseLevel.gd"


onready var _spawns: Array = [$Spawn, $Spawn2]
onready var _big_bots: Array


func _ready() -> void:
	for bot in $Bots.get_children():
		if bot.current_faction != Color(1,0,0) || bot.destructible == false:
			continue
		_big_bots.append(bot)
	for spawn in _spawns:
		spawn.set_level(self)
		spawn.set_big_bots(_big_bots)


func _on_bot_engaged(bot: Node) -> void:
	if _big_bots.has(bot) == true:
		_trigger_spawn()
	._on_bot_engaged(bot)


func _on_bot_dead(bot: Node) -> void:
	_trigger_spawn()
	._on_bot_dead(bot)


func _trigger_spawn() -> void:
	for spawn in _spawns:
		spawn.spawn_bot()
