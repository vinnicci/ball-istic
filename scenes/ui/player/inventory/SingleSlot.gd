extends TextureButton


func _on_Slot_mouse_entered() -> void:
	$Highlight.visible = true


func _on_Slot_mouse_exited() -> void:
	$Highlight.visible = false


func _on_Slot_hide() -> void:
	$Highlight.visible = false
