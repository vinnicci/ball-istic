extends "res://scenes/level/_base/_BaseLevel.gd"


onready var _spawns: Array = [$Spawn, $Spawn2]
onready var _big_bot_1: = $Bots/ChargerSpawner
onready var _big_bot_2: = $Bots/FighterSpawner


func _ready() -> void:
	for spawn in _spawns:
		spawn.set_level(self)
	_spawns[0].set_big_bot(_big_bot_1)
	_spawns[1].set_big_bot(_big_bot_2)


func _on_bot_engaged(bot: Node) -> void:
	match bot:
		_big_bot_1, _big_bot_2:
			_trigger_spawn()
	._on_bot_engaged(bot)


func _on_bot_dead(bot: Node) -> void:
	_trigger_spawn()
	._on_bot_dead(bot)


func _trigger_spawn() -> void:
	if (is_instance_valid(_big_bot_1) == true ||
		is_instance_valid(_big_bot_2) == true):
		for spawn in _spawns:
			spawn.spawn_bot()
