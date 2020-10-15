extends "res://levels proper/main/Spawn.gd"


func _ready() -> void:
	_spawn_table = [
		preload("res://levels proper/1-5_area/Charger.tscn"),
		preload("res://levels proper/1-5_area/SniperBot.tscn")
	]
