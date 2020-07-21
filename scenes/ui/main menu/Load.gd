extends Control


signal moved


func _on_Back_pressed() -> void:
	emit_signal("moved", "MainMenu")
