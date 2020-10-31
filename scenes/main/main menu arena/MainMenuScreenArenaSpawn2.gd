extends "res://levels proper/main/Spawn.gd"


func _ready() -> void:
	_spawn_table = [
		preload("res://scenes/main/main menu arena/ChargerRed.tscn"),
		preload("res://scenes/main/main menu arena/FighterRed.tscn"),
		preload("res://scenes/main/main menu arena/ShotgunnerRed.tscn"),
		preload("res://scenes/main/main menu arena/SlasherRed.tscn"),
		preload("res://scenes/main/main menu arena/SniperBotRed.tscn")
	]


func _on_SpawnTimer_timeout() -> void:
	if _check_big_bots_arr_size() == 0:
		return
	_spawn_table.shuffle()
	_spawned_bot = _spawn_table.front().instance()
	_level_node.add_bot(_spawned_bot)
	_spawned_bot.global_position = global_position
