extends Node2D


func _ready() -> void:
	$Sprite/Anim.play("fading")


func _on_Area2D_body_entered(body: Node) -> void:
	if body.name == "Player":
		print("ready to customize")


func _on_Area2D_body_exited(body: Node) -> void:
	if body.name == "Player":
		print("customization done")
