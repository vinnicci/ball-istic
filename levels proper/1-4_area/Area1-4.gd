extends "res://scenes/level/_base/_BaseLevel.gd"


func _ready() -> void:
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_hidden($Nav/Secret)
	$Follow.set_allies([$Bots/MadMoose])
