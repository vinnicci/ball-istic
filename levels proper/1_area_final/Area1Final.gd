extends "res://scenes/level/_base/_BaseLevel.gd"


signal quest_updated


func _ready() -> void:
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_hidden($Nav/Secret)
	$Access/Key.connect("quest_updated", self, "_on_key_get")


func _on_key_get() -> void:
	emit_signal("quest_updated", "KEYS", name + "Key")
