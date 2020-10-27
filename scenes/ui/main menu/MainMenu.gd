extends Control


signal scene_changed


func _on_New_pressed() -> void:
	emit_signal("scene_changed", "NewGame")


func _on_Load_pressed() -> void:
	emit_signal("scene_changed", "Load")


func _on_Settings_pressed() -> void:
	emit_signal("scene_changed", "Settings")


func _on_Credits_pressed() -> void:
	emit_signal("scene_changed", "Credits")


func _on_Exit_pressed() -> void:
	get_tree().quit()
