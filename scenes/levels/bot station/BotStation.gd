extends Node2D


func _ready() -> void:
	$Sprite/Anim.play("fading")


func _on_Area2D_body_entered(body: Node) -> void:
	if body.name == "Player":
		$EnterSound.play()
		$Sprite/Anim.stop()
		$Sprite.modulate.a = 1.0
		body.is_customizable = true


func _on_Area2D_body_exited(body: Node) -> void:
	if body.name == "Player":
		$ExitSound.play()
		$Sprite/Anim.play("fading")
		body.is_customizable = false
		body.reset_bot_vars()
		body.update_player_vars()
