extends Control


signal moved


func _on_New_pressed() -> void:
	emit_signal("moved", "NewGame")


func _on_Load_pressed() -> void:
	emit_signal("moved", "Load")


func _on_Settings_pressed() -> void:
	emit_signal("moved", "Settings")


func _on_Credits_pressed() -> void:
	emit_signal("moved", "Credits")


func _on_Exit_pressed() -> void:
	get_tree().quit()
