extends "res://scenes/level/_base/_BaseLevel.gd"


onready var spawns: Array = [$Spawn, $Spawn2]
onready var big_bot: = $Bots/HeavyFighterBig


func _ready() -> void:
	for spawn in spawns:
		spawn.set_level(self)


func _on_bot_engaged(bot: Node) -> void:
	if bot == big_bot:
		_trigger_spawn()
	._on_bot_engaged(bot)


func _on_bot_dead(bot: Node) -> void:
	_trigger_spawn()
	._on_bot_dead(bot)


func _trigger_spawn() -> void:
	if is_instance_valid(big_bot) == true:
		for spawn in spawns:
			spawn.spawn_bot()
