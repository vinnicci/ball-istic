extends Control


func _ready() -> void:
	$Buttons.set_confirm($QuitConfirm)
	$QuitConfirm.set_buttons($Buttons)


func set_parent(new_parent) -> void:
	$Buttons.set_parent(new_parent)
	$QuitConfirm.set_parent(new_parent)
