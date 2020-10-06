extends "res://scenes/level/_base/_BaseLevel.gd"


onready var _bot = $Bots/MadMoose


func _ready() -> void:
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_secret($Nav/Secret)


func _on_Follow_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		if is_instance_valid(_bot) == false:
			return
		_bot.get_node("AI").set_master($Bots/Player)
