extends "res://scenes/level/_base/_BaseLevel.gd"


signal quest_updated


func _ready() -> void:
	emit_signal("quest_updated", "SECRETS", name)
