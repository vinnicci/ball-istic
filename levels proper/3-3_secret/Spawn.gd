extends "res://levels proper/main/Spawn.gd"


func _ready() -> void:
	_spawn_table = [
		preload("res://levels proper/3-3_secret/RocketBarrageBot.tscn"),
		preload("res://levels proper/3-3_secret/RocketBarrageEcoBot.tscn"),
		preload("res://levels proper/3-3_secret/RocketSalvoBot.tscn"),
		preload("res://levels proper/3-3_secret/RocketSalvoEcoBot.tscn")
	]
