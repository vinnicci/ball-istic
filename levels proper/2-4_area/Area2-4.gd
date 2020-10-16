extends "res://scenes/level/_base/_BaseLevel.gd"


func _ready() -> void:
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_secret($Nav/Secret)


onready var _bot = $Bots/Berserker


func _on_Follow_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		if is_instance_valid(_bot) == false:
			return
		_bot.get_node("AI").set_master($Bots/Player)
