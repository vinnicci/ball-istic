extends "res://scenes/level/_base/_BaseLevel.gd"


onready var _allies: Array = [
	$Bots/Fighter, $Bots/Fighter2, $Bots/Fighter3, $Bots/Charger,
	$Bots/Charger2, $Bots/Charger3, $Bots/Fighter4, $Bots/Fighter5
]


func _on_Follow_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		for bot in _allies:
			if is_instance_valid(bot) == false:
				continue
			bot.get_node("AI").set_master($Bots/Player)
