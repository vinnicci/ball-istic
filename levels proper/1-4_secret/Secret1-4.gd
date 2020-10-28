extends "res://scenes/level/_base/_BaseLevel.gd"


onready var _spawns: Array = [$Spawn, $Spawn2]
onready var _big_bot: = $Bots/ShotgunnerBig


func _ready() -> void:
	for spawn in _spawns:
		spawn.set_level(self)
		spawn.set_big_bot(_big_bot)


func _on_bot_engaged(bot: Node) -> void:
	if bot == _big_bot:
		_trigger_spawn()
	._on_bot_engaged(bot)


func _on_bot_dead(bot: Node) -> void:
	_trigger_spawn()
	._on_bot_dead(bot)


func _trigger_spawn() -> void:
	if is_instance_valid(_big_bot) == true:
		for spawn in _spawns:
			spawn.spawn_bot()
