extends "res://scenes/level/_base/_BaseLevel.gd"


onready var allies: Array = [$Bots/MadMoose]


func _ready() -> void:
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_hidden($Nav/Secret)
	$Follow.set_level(self)
