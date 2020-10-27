extends Control


signal scene_changed


func _on_Back_pressed() -> void:
	emit_signal("scene_changed", "MainMenu")
