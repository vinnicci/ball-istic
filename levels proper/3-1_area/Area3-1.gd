extends "res://scenes/level/_base/_BaseLevel.gd"


func _ready() -> void:
	$Bots/LongArtilleryBot.set_controller($Bots/ArtilleryController)
	$Bots/LongArtilleryBot2.set_controller($Bots/ArtilleryController2)
	$Bots/FastArtilleryBot.set_controller($Bots/ArtilleryController3)
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_hidden($Nav/Secret)


onready var door: = $Nav/BarredGate
var destroyed_bots: Array


func set_destroyed(i_destroyed_bots: Array):
	destroyed_bots = i_destroyed_bots


func _on_BarredDoorDisp_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		door.open()
		$CanvasLayer/GateDisp.text = "ENEMY ARTILLERIES DISABLED: %s/5" % destroyed_bots.size()
		$CanvasLayer/GateDisp.visible = true


func _on_BarredDoorDisp_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$CanvasLayer/GateDisp.visible = false


func _on_bot_dead(body) -> void:
	if body == $Bots/ExplosiveDummy:
		$Nav/Destructible.destructible = true
	._on_bot_dead(body)


func _on_Secret_visibility_changed() -> void:
	$Bots/ExplosiveDummy.queue_free()
