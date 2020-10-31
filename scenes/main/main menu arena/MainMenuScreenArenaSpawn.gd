extends "res://levels proper/main/Spawn.gd"


func _ready() -> void:
	_spawn_table = [
		preload("res://scenes/main/main menu arena/ChargerGreen.tscn"),
		preload("res://scenes/main/main menu arena/FighterGreen.tscn"),
		preload("res://scenes/main/main menu arena/ShotgunnerGreen.tscn"),
		preload("res://scenes/main/main menu arena/SlasherGreen.tscn"),
		preload("res://scenes/main/main menu arena/SniperBotGreen.tscn")
	]


func _on_SpawnTimer_timeout() -> void:
	if _check_big_bots_arr_size() == 0:
		return
	_spawn_table.shuffle()
	_spawned_bot = _spawn_table.front().instance()
	_level_node.add_bot(_spawned_bot)
	_spawned_bot.global_position = global_position
