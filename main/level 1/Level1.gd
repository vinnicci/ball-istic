extends "res://scenes/level/_base/_BaseLevel.gd"


onready var secret_path = $Nav/Secret


func _ready() -> void:
	$Nav/Destructible.set_level(self)


signal moved


func _on_ToTutorial_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER && body.state == Global.CLASS_BOT.State.ROLL:
		emit_signal("moved", "tut", "PlayerPos2")


func _on_ToCP12_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER && body.state == Global.CLASS_BOT.State.ROLL:
		emit_signal("moved", "cp_12", "PlayerPos1")
