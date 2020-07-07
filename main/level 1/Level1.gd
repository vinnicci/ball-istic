extends "res://scenes/level/_base/_BaseLevel.gd"


onready var secret_path = $Nav/Secret


func _ready() -> void:
	$Nav/Destructible.set_level(self)
