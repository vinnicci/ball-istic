extends "res://scenes/level/_base/_BaseLevel.gd"


func _ready() -> void:
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_hidden($Nav/Secret)
	$Follow.set_allies([$Bots/Berserker])


func _on_Knock_body_entered(body: Node) -> void:
	if (body is Global.CLASS_PLAYER &&
		body.state == Global.CLASS_BOT.State.CHARGE_ROLL &&
		is_instance_valid($Bots/Berserker) == true):
		$Bots/Berserker.get_node("AI").set_master(body)
