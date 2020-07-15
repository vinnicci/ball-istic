extends "res://scenes/level/_base/_BaseLevel.gd"


onready var secret_path = $Nav/Secret


func _ready() -> void:
	$Nav/Destructible.set_level(self)


func _on_ToTutorial_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		emit_signal("moved", "TutorialLevel", "PlayerPos1")


func _on_ToCP12_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		emit_signal("moved", "Checkpoint1-2", "PlayerPos1")
