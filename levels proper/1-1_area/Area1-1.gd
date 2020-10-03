extends "res://scenes/level/_base/_BaseLevel.gd"


func _ready() -> void:
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_secret($Nav/Secret)


func _on_Secret_visibility_changed() -> void:
	$"Access/Secret1-1".visible = true
