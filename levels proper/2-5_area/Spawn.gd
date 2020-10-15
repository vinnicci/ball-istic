extends "res://levels proper/main/Spawn.gd"


func _ready() -> void:
	_spawn_table = [
		preload("res://levels proper/2-5_area/Explosive.tscn"),
		preload("res://levels proper/2-5_area/StunExplosive.tscn")
	]
