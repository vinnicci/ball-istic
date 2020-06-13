extends Node2D


func _ready() -> void:
	for i in range(24):
		print(i as String + " " + Vector2(1,0).rotated(deg2rad(i*15)) as String)
