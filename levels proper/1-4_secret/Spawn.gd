extends "res://levels proper/main/Spawn.gd"


func _ready() -> void:
	_spawn_table = [
		preload("res://levels proper/1-4_secret/Shotgunner.tscn"),
		preload("res://levels proper/1-4_secret/Slasher.tscn")
	]
