extends "res://scenes/level/_base/_BaseLevel.gd"


onready var main_door = $Doors/MainDoor
var keys: Array


func _ready() -> void:
	main_door.set_level(self)
	$Nav/Destructible.set_level(self)
	$Nav/Destructible.set_secret($Nav/Secret)


func set_keys(player_keys: Array) -> void:
	keys = player_keys


func _on_KeysDisplay_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		main_door.open()
		$CanvasLayer/KeysDisp.text = "KEYS OBTAINED: %s/3" % keys.size()
		$CanvasLayer/KeysDisp.visible = true


func _on_KeysDisplay_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$CanvasLayer/KeysDisp.visible = false
