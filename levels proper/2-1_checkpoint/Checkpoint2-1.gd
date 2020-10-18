extends "res://scenes/level/_base/_BaseLevel.gd"


func _ready() -> void:
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_secret($Nav/Secret)
	$Nav/DestructibleLow.set_level(self)
	$Nav/DestructibleLow.set_secret($Nav/SecretLow)


func _on_bot_dead(body) -> void:
	if body == $Bots/ExplosiveDummy:
		$Nav/DestructibleLow.destructible = true
	._on_bot_dead(body)
