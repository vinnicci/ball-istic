extends "res://levels proper/main/Spawn.gd"


func _ready() -> void:
	_spawn_table = [
		preload("res://levels proper/2-4_secret/Explosive.tscn"),
		preload("res://levels proper/2-4_secret/Grenadier.tscn"),
		preload("res://levels proper/2-4_secret/Mininuke.tscn"),
		preload("res://levels proper/2-4_secret/StunExplosive.tscn"),
		preload("res://levels proper/2-4_secret/StunGrenadier.tscn")
	]
