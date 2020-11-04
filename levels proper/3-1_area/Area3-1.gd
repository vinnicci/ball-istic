extends "res://scenes/level/_base/_BaseLevel.gd"


func _ready() -> void:
	$Bots/LongArtilleryBot.set_controller($Bots/ArtilleryController)
	$Bots/LongArtilleryBot2.set_controller($Bots/ArtilleryController2)
	$Bots/FastArtilleryBot.set_controller($Bots/ArtilleryController3)
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_hidden($Nav/Secret)
	$Nav/BarredGate.set_level(self)
	$Bots/Explosive.connect("body_entered", self, "_on_Explosive_body_entered")


onready var door: = $Nav/BarredGate
var destroyed_bots: Array


func set_quest(i_destroyed_bots: Array):
	destroyed_bots = i_destroyed_bots


func _on_BarredDoorDisp_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		door.open()
		$CanvasLayer/GateDisp.text = "ENEMY CANNONS DISABLED: %s/5" % destroyed_bots.size()
		$CanvasLayer/GateDisp.visible = true


func _on_BarredDoorDisp_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$CanvasLayer/GateDisp.visible = false


func _on_Explosive_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER && $Nav/Secret.visible == false:
		$Bots/Explosive/AI.engage($Bots/ExplosiveDummyInv)


func _on_bot_dead(body) -> void:
	if body == $Bots/ExplosiveDummyInv:
		$Nav/Destructible.destructible = true
	._on_bot_dead(body)
