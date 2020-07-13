extends Node2D


func _on_Anim_started(anim_name: String) -> void:
	$Sound.play()
