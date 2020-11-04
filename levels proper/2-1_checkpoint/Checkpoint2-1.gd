extends "res://scenes/level/_base/_BaseLevel.gd"


func _ready() -> void:
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_hidden($Nav/Secret)
	$Nav/Destructible2.set_level(self)
	$Nav/Destructible2.set_hidden($Nav/Secret2)
	$Nav/Destructible3.set_level(self)
	$Nav/Destructible3.set_hidden($Nav/Secret3)
	$Nav/DestructibleLow.set_level(self)
	$Nav/DestructibleLow.set_hidden($Nav/SecretLow)


func _on_bot_dead(body) -> void:
	if body == $Bots/ExplosiveDummyInv:
		$Nav/Destructible3.destructible = true
		$Nav/DestructibleLow.destructible = true
	._on_bot_dead(body)


func _on_Destructible_path_found() -> void:
	if ($Nav/Secret.visible == true && $Nav/Secret2.visible == true &&
		$Nav/Secret3.visible == false):
		$Bots/Explosive/AI.engage($Bots/ExplosiveDummyInv)
