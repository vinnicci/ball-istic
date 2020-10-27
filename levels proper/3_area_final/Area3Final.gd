extends "res://scenes/level/_base/_BaseLevel.gd"


signal quest_updated


func _ready() -> void:
	$Follow.set_allies([
		$Bots/Charger4, $Bots/Fighter2, $Bots/HeavyFighter2, $Bots/FighterBig
	])
	$Follow2.set_allies([
		$Bots/Charger3, $Bots/Fighter, $Bots/HeavyFighter3, $Bots/HeavyFighter
	])
	$Follow3.set_allies([
		$Bots/Charger2, $Bots/Charger, $Bots/Fighter3, $Bots/FighterBig2
	])
	$Access/Key.connect("quest_updated", self, "_on_key_get")


func _on_key_get() -> void:
	emit_signal("quest_updated", "KEYS", name + "Key")
