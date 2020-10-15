extends "res://scenes/level/_base/_BaseLevel.gd"


func _ready() -> void:
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_secret($Nav/Secret)


func _on_bot_dead(body) -> void:
	if body == $Bots/Explosive:
		$Nav/Destructible.destructible = true
	._on_bot_dead(body)


func _on_ChargeArea_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER && body.state == Global.CLASS_BOT.State.CHARGE_ROLL:
		$Bots/Fighter/AI.set_master(body)
