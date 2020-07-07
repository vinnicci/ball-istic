extends "res://scenes/bots/dummy/Dummy.gd"


signal dead


func explode() -> void:
	.explode()
	emit_signal("dead")
