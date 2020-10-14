extends Node2D


func _on_Anim_started(_anim_name: String) -> void:
	$Sound.play()
