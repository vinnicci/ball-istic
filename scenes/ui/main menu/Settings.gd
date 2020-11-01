extends Control


signal scene_changed


func _on_Back_pressed() -> void:
	emit_signal("scene_changed", "MainMenu")


func _on_LinkYoutube_pressed() -> void:
	OS.shell_open("https://youtube.com/channel/UCKfmrrk5hcgKiPHKN6mi4HA")


func _on_LinkTwitter_pressed() -> void:
	OS.shell_open("https://twitter.com/VicBen56028131")
