extends "res://scenes/level/_base/_BaseLevel.gd"


func _ready() -> void:
	door.set_level(self)
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_hidden($Nav/Secret)


onready var door = $Nav/MainDoor
var keys: Array


func set_quest(player_keys: Array) -> void:
	keys = player_keys


func _on_KeysDisplay_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		door.open()
		$CanvasLayer/KeysDisp.text = "KEYS OBTAINED: %s/3" % keys.size()
		$CanvasLayer/KeysDisp.visible = true


func _on_KeysDisplay_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$CanvasLayer/KeysDisp.visible = false
