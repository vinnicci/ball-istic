extends "res://scenes/level/_base/_BaseLevel.gd"


signal quest_updated


func _ready() -> void:
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_hidden($Nav/Secret)
	$Access/Key.connect("quest_updated", self, "_on_key_get")


func _on_bot_dead(body) -> void:
	if body == $Bots/ExplosiveDummyInv:
		$Nav/Destructible.destructible = true
	._on_bot_dead(body)


func _on_ChargeArea_body_entered(body: Node) -> void:
	if (body is Global.CLASS_PLAYER && body.state == Global.CLASS_BOT.State.CHARGE_ROLL &&
		$Nav/Secret.visible == false):
		$Bots/Explosive/AI.engage($Bots/ExplosiveDummyInv)


func _on_key_get() -> void:
	emit_signal("quest_updated", "KEYS", name + "Key")
