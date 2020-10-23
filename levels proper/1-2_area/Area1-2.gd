extends "res://scenes/level/_base/_BaseLevel.gd"


onready var allies: Array = [
	$Bots/Fighter, $Bots/Fighter2, $Bots/Charger,
	$Bots/Charger2, $Bots/Charger3, $Bots/Charger4
]


func _ready() -> void:
	$Follow.set_level(self)
