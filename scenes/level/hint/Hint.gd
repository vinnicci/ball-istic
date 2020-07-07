extends "res://scenes/level/_base/_BaseAccess.gd"


func _on_Area2D_body_entered(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$AccessUI/Label.visible = !$AccessUI/Label.visible
		$Sprite/Anim.stop()
		$Sprite.modulate.a = 1.0


var _objective_shown: bool = false


func _animate_objective() -> void:
	if _objective_shown == false:
		$AccessUI/Label2/Anim.play("fade_in")
		_objective_shown = true


var _level: Node


func set_level(level) -> void:
	_level = level


func _on_Area2D_body_exited(body: Node) -> void:
	if body is Global.CLASS_PLAYER:
		$AccessUI/Label.visible = !$AccessUI/Label.visible
		_animate_objective()
		$Sprite/Anim.play("fading")


func _on_FadeTimer_timeout() -> void:
	$AccessUI/Label2/Anim.play_backwards("fade_in")
